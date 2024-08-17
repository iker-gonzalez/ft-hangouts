import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isSent;

  ChatMessage({required this.text, required this.isSent});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: isSent ? Colors.blue : Colors.grey,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Text(text),
        ),
      ],
    );
  }
}