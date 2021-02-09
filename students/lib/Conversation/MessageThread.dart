import 'package:ccsga_comments/Conversation/MessageCard.dart';
import 'package:flutter/material.dart';

class MessageThread extends StatelessWidget {
  List<MessageCard> messages;

  MessageThread(List<MessageCard> messages) {
    this.messages = messages;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: messages.length,
      shrinkWrap: true,
      padding: EdgeInsets.only(top: 10, bottom: 10),
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return messages[index];
      },
    );
  }
}
