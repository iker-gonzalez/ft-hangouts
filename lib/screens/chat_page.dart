import 'package:flutter/material.dart';
import 'package:ft_hangouts/widgets/chat_message_widget.dart';
import 'package:ft_hangouts/database/database.dart';

class ChatPage extends StatefulWidget {
  final int contactId;

  ChatPage({required this.contactId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<ChatMessage> _messages = [];
  final _controller = TextEditingController();
  final _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  void _fetchMessages() async {
    final messages = await _dbHelper.queryChatMessagesByContactId(widget.contactId);
    setState(() {
      _messages.addAll(messages.map((message) => ChatMessage(
        text: message[DatabaseHelper.columnMessage],
        isSent: message[DatabaseHelper.columnIsSent] == 1,
      )).toList());
    });
  }

  void _sendMessage(String text) {
    _controller.clear();
    final message = ChatMessage(text: text, isSent: true);
    setState(() {
      _messages.insert(0, message);
    });
    _dbHelper.insertChatMessage({
      DatabaseHelper.columnMessage: message.text,
      DatabaseHelper.columnIsSent: message.isSent ? 1 : 0,
      DatabaseHelper.columnTimestamp: DateTime.now().millisecondsSinceEpoch,
      DatabaseHelper.columnContactId: widget.contactId,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (_, index) => _messages[index],
            ),
          ),
          TextField(
            controller: _controller,
            onSubmitted: _sendMessage,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter message',
              suffixIcon: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => _sendMessage(_controller.text),
              ),
            ),
          ),
        ],
      ),
    );
  }
}