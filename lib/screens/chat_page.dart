import 'package:telephony/telephony.dart';
import 'package:flutter/material.dart';
import 'package:ft_hangouts/database/database.dart';

// Place this at the top of your Dart file, outside of any class
void backgroundMessageHandler(SmsMessage message) {
  // Handle background message
  print("Received SMS in background: ${message.body}");
  // Assuming you have access to the database helper instance
  DatabaseHelper.instance.insertChatMessage({
    DatabaseHelper.columnMessage: message.body ?? '',
    DatabaseHelper.columnIsSent: 0,
    DatabaseHelper.columnTimestamp: DateTime.now().millisecondsSinceEpoch,
    DatabaseHelper.columnContactId: message.address, // Adjust as needed
  });
}

class ChatPage extends StatefulWidget {
  final int contactId;

  const ChatPage({super.key, required this.contactId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final _dbHelper = DatabaseHelper.instance;
  final Telephony telephony = Telephony.instance;
  late Stream<List<Map<String, dynamic>>> _messagesStream;

  @override
  void initState() {
    super.initState();
    _messagesStream = _dbHelper.getMessagesStream(widget.contactId);
    listenForSMS();
  }

  void _sendMessage(String text) {
    _controller.clear();
    _dbHelper.insertChatMessage({
      DatabaseHelper.columnMessage: text,
      DatabaseHelper.columnIsSent: 1,
      DatabaseHelper.columnTimestamp: DateTime.now().millisecondsSinceEpoch,
      DatabaseHelper.columnContactId: widget.contactId,
    });
    sendSMS(text, "recipient_phone_number"); // Replace with actual recipient number
  }

  void sendSMS(String message, String recipient) async {
    bool? permissionsGranted = await telephony.requestSmsPermissions;
    if (permissionsGranted != null && permissionsGranted) {
      try {
        await telephony.sendSms(to: recipient, message: message);
      } catch (e) {
        print("Failed to send SMS: $e");
      }
    } else {
      print("SMS permissions not granted");
    }
  }

  void listenForSMS() {
    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        _dbHelper.insertChatMessage({
          DatabaseHelper.columnMessage: message.body ?? '',
          DatabaseHelper.columnIsSent: 0,
          DatabaseHelper.columnTimestamp: DateTime.now().millisecondsSinceEpoch,
          DatabaseHelper.columnContactId: widget.contactId,
        });
      },
      onBackgroundMessage: backgroundMessageHandler,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading messages'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No messages'));
                } else {
                  final messages = snapshot.data!;
                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return ListTile(
                        title: Text(message[DatabaseHelper.columnMessage]),
                        subtitle: Text(DateTime.fromMillisecondsSinceEpoch(
                            message[DatabaseHelper.columnTimestamp])
                            .toString()),
                      );
                    },
                  );
                }
              },
            ),
          ),
          TextField(
            controller: _controller,
            onSubmitted: _sendMessage,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: 'Enter message',
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _sendMessage(_controller.text),
              ),
            ),
          ),
        ],
      ),
    );
  }
}