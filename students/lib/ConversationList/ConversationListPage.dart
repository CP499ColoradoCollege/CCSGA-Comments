import 'package:ccsga_comments/BasePage/BasePage.dart';
import 'package:ccsga_comments/Conversation/ConversationPage.dart';
import 'package:ccsga_comments/Navigation/CCSGABeamLocations.dart';
import 'package:ccsga_comments/NewMessage/NewMessagePage.dart';
import 'package:flutter/material.dart';
import 'ConversationListCard.dart';
import 'package:ccsga_comments/DatabaseHandler.dart';
import 'package:beamer/beamer.dart';

class ConversationListPage extends BasePage {
  ConversationListPage({Key key, this.title}) : super(key: key);

  final String title;

  _ConversationListPageState createState() => _ConversationListPageState();
}

class _ConversationListPageState extends BaseState<ConversationListPage> with BasicPage {
  @override
  String screenName() {
    return "Messages";
  }

  List<ConversationListCard> _messages = [];

  Widget body() {
    return Center(
      child: RefreshIndicator(
        onRefresh: _pullRefresh,
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: _messages,
        ),
      ),
    );
  }

  @override
  Widget fab() {
    return FloatingActionButton.extended(
      onPressed: () {
        _newMessage();
      },
      label: Text('New Message'),
      icon: Icon(Icons.add),
      backgroundColor: Theme.of(context).accentColor,
    );
  }

  void _newMessage() {
    context.beamTo(NewMessageLocation());
  }

  Future<void> _pullRefresh() async {
    DatabaseHandler dbHandler = DatabaseHandler.instance;
    dbHandler.getMessages().then((messages) {
      setState(() {
        _messages = [...messages];
      });
    }).catchError((err) => print("Caught an error: $err"));
  }
}
