import 'package:ft_hangouts/database/database.dart';

class ChatMessage {
  int id;
  int contactId;
  String message;
  DateTime timestamp;
  bool isSent;

  ChatMessage({
    required this.id,
    required this.contactId,
    required this.message,
    required this.timestamp,
    required this.isSent,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map[DatabaseHelper.columnId],
      contactId: map[DatabaseHelper.columnContactId],
      message: map[DatabaseHelper.columnMessage],
      timestamp: DateTime.parse(map[DatabaseHelper.columnTimestamp]),
      isSent: map[DatabaseHelper.columnIsSent] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnContactId: contactId,
      DatabaseHelper.columnMessage: message,
      DatabaseHelper.columnTimestamp: timestamp.toIso8601String(),
      DatabaseHelper.columnIsSent: isSent ? 1 : 0,
    };
  }
}