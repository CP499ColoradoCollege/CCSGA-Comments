import 'package:ccsga_comments/NewMessage/Conversation.dart';

class Message {
  double id;
  //Conversation conversation;
  //double conversationId;
  double fromUserId;
  double toUserId;
  String body;
  DateTime dateTime;

  Message(this.fromUserId, this.toUserId, this.body) {
    // init goes here
  }
}
