import 'package:ccsga_comments/Conversation/MessageCard.dart';
import 'package:ccsga_comments/DatabaseHandler.dart';
import 'package:ccsga_comments/Models/ChewedResponseModel.dart';
import 'package:ccsga_comments/Models/Message.dart';
import 'package:ccsga_comments/Models/Conversation.dart';
import 'package:ccsga_comments/Models/User.dart';

import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class MessageThread extends StatefulWidget {
  final Conversation conv;
  const MessageThread({Key key, @required this.conv}) : super(key: key);

  @override
  _MessageThreadState createState() => _MessageThreadState();
}

class _MessageThreadState extends State<MessageThread> {
  final ScrollController _scrollController = ScrollController();

  List<Message> messages;
  User currentAuthenticatedUser;

  @override
  Widget build(BuildContext context) {
    // get list of messages from the conversation object
    messages = List.from(widget.conv.messages.values);
    FutureBuilder<bool>(
        future: _getUserInfo(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            return Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                shrinkWrap: true,
                padding: EdgeInsets.only(top: 10, bottom: 10),
                physics: BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                controller: _scrollController,
                itemBuilder: (context, index) {
                  print("Total messages: " + messages.length.toString());
                  print("Current user's username: " +
                      currentAuthenticatedUser.username);
                  return MessageCard(
                      message: messages[index],
                      isMyMessage: messages[index].sender.username ==
                          currentAuthenticatedUser.username);
                },
              ),
            );
          } else {
            return CircularProgressIndicator();
          }
        });
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

  Future<bool> _getUserInfo() async {
    Tuple2<ChewedResponse, User> responseTuple =
        await DatabaseHandler.instance.getAuthenticatedUser();
    if (responseTuple.item2 != null) {
      currentAuthenticatedUser = responseTuple.item2;
      return true;
    } else {
      print(responseTuple.item1.message);
      return false;
    }
  }
}
