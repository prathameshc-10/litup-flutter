class ChatMessage {
  final String sender;
  final String message;
  final String time;
  final String avatarUrl;
  final bool isMe;

  ChatMessage({
    required this.sender,
    required this.message,
    required this.time,
    required this.avatarUrl,
    this.isMe = false,
  });
}