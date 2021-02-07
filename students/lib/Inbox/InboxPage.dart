import 'dart:html';
import 'package:flutter/material.dart';
import 'InboxCard.dart';

class InboxPage extends StatefulWidget {
  InboxPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _InboxPageState createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), actions: <Widget>[
        new IconTheme(
          data: new IconThemeData(
            color: Colors.black,
          ),
          child: new IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            tooltip: 'Filter Messages',
            onPressed: () {
              _filterMessages();
            },
          ),
        )
      ]),
      body: Center(
        child: RefreshIndicator(
          onRefresh: _pullRefresh,
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: <Widget>[
              InboxCard(
                  'CCSGA Internal Affairs - Fer',
                  'Hi Sam! Thanks for reaching out, we will help you with your issue.',
                  DateTime.now()),
              InboxCard('CCSGA President - Sakina Bhatti',
                  'Hi Ely, I love the database you setup!', DateTime.now())
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _newMessage,
        tooltip: 'New Message',
        child: Icon(Icons.add),
      ),
    );
  }

  void _filterMessages() {
    print("Filter messages");
  }

  void _newMessage() {
    setState(() {
      print("New message");
    });
  }

  Future<void> _pullRefresh() async {
    print("Pull to refresh");
    //call to database to get name
    setState(() {});
  }
}
