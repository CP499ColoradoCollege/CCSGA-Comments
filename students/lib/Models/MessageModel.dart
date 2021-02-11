class MessageModel {
  final String senderName;
  final String body;
  final DateTime time;
  final bool isSender;

  MessageModel(this.senderName, this.body, this.time, this.isSender);
}
