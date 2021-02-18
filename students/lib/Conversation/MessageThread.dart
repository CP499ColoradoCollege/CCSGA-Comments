import 'package:ccsga_comments/Conversation/MessageCard.dart';
import 'package:ccsga_comments/Models/MessageModel.dart';
import 'package:flutter/material.dart';

class MessageThread extends StatefulWidget {
  const MessageThread({Key key}) : super(key: key);

  @override
  _MessageThreadState createState() => _MessageThreadState();
}

class _MessageThreadState extends State<MessageThread> {
  final ScrollController _scrollController = ScrollController();

  List<MessageModel> messages = [
    MessageModel(
        "Sam Doggett", "Placeholder message body", DateTime.now(), false),
    MessageModel("Fer", "Placeholder message body", DateTime.now(), true)
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
