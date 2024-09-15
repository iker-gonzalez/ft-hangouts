import 'package:telephony/telephony.dart';
import 'package:flutter/material.dart';
import 'package:ft_hangouts/database/database.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ft_hangouts/models/chat_message.dart';
import 'package:logger/logger.dart';

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
  late Stream<List<ChatMessage>> _messagesStream;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeMessagesStream();
    listenForSMS();
  }

  void _initializeMessagesStream() {
    final initialMessagesStream = Stream.fromFuture(
      _dbHelper.queryChatMessagesByContactId(widget.contactPhoneNumber).then(
            (event) => event.map((e) => ChatMessage.fromMap(e)).toList(),
      ),
    ).asBroadcastStream();

    final updateMessagesStream = _dbHelper.chatMessageUpdateStream.asyncMap((_) => _dbHelper.queryChatMessagesByContactId(widget.contactPhoneNumber).then(
          (event) => event.map((e) => ChatMessage.fromMap(e)).toList(),
    ));

    _messagesStream = Rx.merge([initialMessagesStream, updateMessagesStream]);
  }

  void _sendMessage(String text) {
    _controller.clear();
    _dbHelper.insertChatMessage(ChatMessage(
      contactId: widget.contactPhoneNumber,
      message: text,
      isSent: true,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    ).toMap());
    sendSMS(text, widget.contactPhoneNumber);
  }

  final logger = Logger();

  void sendSMS(String message, String recipient) async {
    bool? permissionsGranted = await telephony.requestSmsPermissions;
    if (permissionsGranted != null && permissionsGranted) {
      try {
        await telephony.sendSms(to: recipient, message: message);
      } catch (e) {
        logger.e("Failed to send SMS: $e");
      }
    } else {
      logger.w("SMS permissions not granted");
    }
  }

  void listenForSMS() {
    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) async {
        final contactPhoneNumber = message.address ?? '';
        final contactExists = await _dbHelper.queryChatMessagesByContactId(contactPhoneNumber);

        if (contactExists.isEmpty) {
          logger.i("Contact does not exist, creating new contact");
          await _dbHelper.insert({
            DatabaseHelper.columnName: contactPhoneNumber,
            DatabaseHelper.columnPhoneNumber: contactPhoneNumber,
            DatabaseHelper.columnEmail: '',
            DatabaseHelper.columnAddress: '',
            DatabaseHelper.columnCompany: '',
            DatabaseHelper.columnImagePath: '',
          });
        }

        _dbHelper.insertChatMessage(ChatMessage(
          contactId: contactPhoneNumber,
          message: message.body ?? '',
          isSent: false,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ).toMap());
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
            child: StreamBuilder<List<ChatMessage>>(
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
                      final isSent = message.isSent;
                      return Align(
                        alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: isSent ? Colors.blue[100] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.message,
                                style: TextStyle(
                                  color: isSent ? Colors.black : Colors.black87,
                                ),
                              ),
                              Text(
                                DateTime.fromMillisecondsSinceEpoch(
                                  message.timestamp,
                                ).toString(),
                                style: const TextStyle(
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
    dbHelper.insertChatMessage(ChatMessage(
      contactId: message.address ?? '',
      message: message.body ?? '',
      isSent: false,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    ).toMap());
  }
}