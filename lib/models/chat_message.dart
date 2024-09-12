class ChatMessage {
  final int? id; // Make id nullable
  final String contactId;
  final String message;
  final bool isSent;
  final int timestamp;

  ChatMessage({
    this.id, // Make id optional
    required this.contactId,
    required this.message,
    required this.isSent,
    required this.timestamp,
  });

  // Convert a ChatMessage into a Map. The keys must correspond to the names of the columns in the database.
  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'contact_id': contactId,
      'message': message,
      'is_sent': isSent ? 1 : 0,
      'timestamp': timestamp,
    };
  }

  // Create a ChatMessage from a Map.
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['_id'],
      contactId: map['contact_id'],
      message: map['message'],
      isSent: map['is_sent'] == 1,
      timestamp: map['timestamp'],
    );
  }
}