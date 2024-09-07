import 'package:telephony/telephony.dart';
import 'package:flutter/material.dart';
import 'package:ft_hangouts/database/database.dart';
import '../main.dart';

class ChatPage extends StatefulWidget {
  final String contactPhoneNumber;
  final String contactName;

  const ChatPage({
    super.key,
    required this.contactPhoneNumber,
    required this.contactName,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final _dbHelper = DatabaseHelper.instance;
  final Telephony telephony = Telephony.instance;
  late Stream<List<Map<String, dynamic>>> _messagesStream;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _messagesStream = _dbHelper.getMessagesStream(widget.contactPhoneNumber);
    listenForSMS();
  }

  void _sendMessage(String text) {
    final String myPhoneNumber = "+34662236995";
    _controller.clear();
    _dbHelper.insertChatMessage({
      DatabaseHelper.columnMessage: text,
      DatabaseHelper.columnIsSent: 1,
      DatabaseHelper.columnTimestamp: DateTime.now().millisecondsSinceEpoch,
      DatabaseHelper.columnContactId: widget.contactPhoneNumber,
    });
    sendSMS(text, widget.contactPhoneNumber);
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
        if (message.address == widget.contactPhoneNumber) {
          _dbHelper.insertChatMessage({
            DatabaseHelper.columnMessage: message.body ?? '',
            DatabaseHelper.columnIsSent: 0,
            DatabaseHelper.columnTimestamp: DateTime.now().millisecondsSinceEpoch,
            DatabaseHelper.columnContactId: widget.contactPhoneNumber,
          });
        }
      },
      onBackgroundMessage: backgroundMessageHandler,
    );
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contactName),
      ),
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
                  _scrollDown();
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isSent = message[DatabaseHelper.columnIsSent] == 1;
                      return Align(
                        alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: isSent ? Colors.blue[100] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message[DatabaseHelper.columnMessage],
                                style: TextStyle(
                                  color: isSent ? Colors.black : Colors.black87,
                                ),
                              ),
                              Text(
                                DateTime.fromMillisecondsSinceEpoch(
                                  message[DatabaseHelper.columnTimestamp],
                                ).toString(),
                                style: TextStyle(
                                  fontSize: 10.0,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
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

void backgroundMessageHandler(SmsMessage message) async {
  final dbHelper = DatabaseHelper.instance;

  if (message.address == message.address) {
    dbHelper.insertChatMessage({
      DatabaseHelper.columnMessage: message.body ?? '',
      DatabaseHelper.columnIsSent: 0,
      DatabaseHelper.columnTimestamp: DateTime.now().millisecondsSinceEpoch,
      DatabaseHelper.columnContactId: message.address,
    });
  }
}