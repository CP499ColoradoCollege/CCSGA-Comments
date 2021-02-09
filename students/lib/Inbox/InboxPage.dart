import 'package:ccsga_comments/BasePage.dart';
import 'package:flutter/material.dart';
import 'InboxCard.dart';
import 'package:ccsga_comments/DatabaseHandler.dart';

class InboxPage extends BasePage {
  InboxPage({Key key, this.title}) : super(key: key);

  final String title;

  _InboxPageState createState() => _InboxPageState();
}

class _InboxPageState extends BaseState<InboxPage> with BasicPage {
  @override
  String screenName() {
    return "Messages";
  }

  List<InboxCard> _messages = [];

  @override
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
      backgroundColor: Colors.yellow,
    );
  }

  void _newMessage() {
    setState(() {
      print("New message");
    });
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
