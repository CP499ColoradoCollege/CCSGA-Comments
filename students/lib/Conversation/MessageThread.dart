import 'package:ccsga_comments/Conversation/MessageCard.dart';
import 'package:ccsga_comments/Models/Message.dart';
import 'package:flutter/material.dart';

class MessageThread extends StatefulWidget {
  const MessageThread({Key key}) : super(key: key);

  @override
  _MessageThreadState createState() => _MessageThreadState();
}

class _MessageThreadState extends State<MessageThread> {
  final ScrollController _scrollController = ScrollController();

  List<Message> messages = [
    Message(
        body: "Body of message",
        dateTime: DateTime.now().toString(),
        isRead: true,
        sender: Sender(displayName: "Sam", username: "samdogg7")),
    Message(
        body: "Body of message",
        dateTime: DateTime.now().toString(),
        isRead: true,
        sender: Sender(displayName: "Fer", username: "fer7")),
  ];

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: ListView.builder(
      itemCount: messages.length,
      shrinkWrap: true,
      padding: EdgeInsets.only(top: 10, bottom: 10),
      physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      controller: _scrollController,
      itemBuilder: (context, index) {
        return MessageCard(messages[index]);
      },
    ));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
  }

  void scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }
}
