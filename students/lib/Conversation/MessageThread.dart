import 'package:ccsga_comments/Conversation/MessageCard.dart';
import 'package:ccsga_comments/Models/Message.dart';
import 'package:ccsga_comments/Models/Conversation.dart';

import 'package:flutter/material.dart';

class MessageThread extends StatefulWidget {
  final Conversation conv;
  const MessageThread({Key key, @required this.conv}) : super(key: key);

  @override
  _MessageThreadState createState() => _MessageThreadState();
}

class _MessageThreadState extends State<MessageThread> {
  final ScrollController _scrollController = ScrollController();

  List<Message> messages;

  @override
  Widget build(BuildContext context) {
    // get list of messages from the conversation object
    messages = List.from(widget.conv.messages.values);

    return Expanded(
        child: ListView.builder(
      itemCount: messages.length,
      shrinkWrap: true,
      padding: EdgeInsets.only(top: 10, bottom: 10),
      physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      controller: _scrollController,
      itemBuilder: (context, index) {
        //TEMP!! in future check whether message was sent by user or not
        bool isMyMessage = false;
        if (index % 2 == 0) {
          isMyMessage = true;
        }
        return MessageCard(message: messages[index], isMyMessage: isMyMessage);
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

  // List<MessageModel> messages = [
  //   MessageModel(
  //       "Sam Doggett", "Placeholder to test scrolling", DateTime.now(), false),
  //   MessageModel("Fer - Internal Affairs", "Placeholder to test scrolling",
  //       DateTime.now(), true),
  //   MessageModel(
  //       "Sam Doggett", "Placeholder to test scrolling", DateTime.now(), false),
  //   MessageModel("Fer - Internal Affairs", "Placeholder to test scrolling",
  //       DateTime.now(), true),
  //   MessageModel(
  //       "Sam Doggett", "Placeholder to test scrolling", DateTime.now(), false),
  //   MessageModel("Fer - Internal Affairs", "Placeholder to test scrolling",
  //       DateTime.now(), true),
  //   MessageModel(
  //       "Sam Doggett", "Placeholder to test scrolling", DateTime.now(), false),
  //   MessageModel("Fer - Internal Affairs", "Placeholder to test scrolling",
  //       DateTime.now(), true),
  //   MessageModel(
  //       "Sam Doggett", "Placeholder to test scrolling", DateTime.now(), false),
  //   MessageModel("Fer - Internal Affairs", "Placeholder to test scrolling",
  //       DateTime.now(), true),
  //   MessageModel(
  //       "Sam Doggett", "Placeholder to test scrolling", DateTime.now(), false),
  //   MessageModel("Fer - Internal Affairs", "Placeholder to test scrolling",
  //       DateTime.now(), true),
  //   MessageModel(
  //       "Sam Doggett", "Placeholder to test scrolling", DateTime.now(), false),
  //   MessageModel("Fer - Internal Affairs", "Placeholder to test scrolling",
  //       DateTime.now(), true),
  //   MessageModel(
  //       "Sam Doggett", "Placeholder to test scrolling", DateTime.now(), false),
  //   MessageModel("Fer - Internal Affairs", "Placeholder to test scrolling",
  //       DateTime.now(), true),
  //   MessageModel(
  //       "Sam Doggett", "Placeholder to test scrolling", DateTime.now(), false),
  //   MessageModel("Fer - Internal Affairs", "Placeholder to test scrolling",
  //       DateTime.now(), true),
  //   MessageModel(
  //       "Sam Doggett", "Placeholder to test scrolling", DateTime.now(), false),
  //   MessageModel("Fer - Internal Affairs", "Placeholder to test scrolling",
  //       DateTime.now(), true),
  //   MessageModel(
  //       "Sam Doggett", "Placeholder to test scrolling", DateTime.now(), false),
  //   MessageModel("Fer - Internal Affairs", "Placeholder to test scrolling",
  //       DateTime.now(), true),
  //   MessageModel(
  //       "Sam Doggett", "Placeholder to test scrolling", DateTime.now(), false),
  //   MessageModel("Fer - Internal Affairs", "Placeholder to test scrolling",
  //       DateTime.now(), true)
  // ];
}
