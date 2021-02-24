import 'package:ccsga_comments/Conversation/MessageCard.dart';
import 'package:ccsga_comments/Models/Message.dart';
import 'package:ccsga_comments/Models/Conversation.dart';
import 'package:ccsga_comments/Models/User.dart';
import 'package:flutter/material.dart';

/// Containier for Messae Cards
///
/// The messages are retrieved  from the Conversation Page
/// containing this widget, then this creates the Message
/// cards and displays them
class MessageThread extends StatefulWidget {
  final Conversation conv;
  final User currentUser;
  const MessageThread(
      {Key key, @required this.conv, @required this.currentUser})
      : super(key: key);

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
          bool isMyMessage =
              messages[index].sender.username == widget.currentUser.username;
          return MessageCard(
              message: messages[index], isMyMessage: isMyMessage);
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
  }

  //This causes a scroll to bottom animation
  void scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }
}
