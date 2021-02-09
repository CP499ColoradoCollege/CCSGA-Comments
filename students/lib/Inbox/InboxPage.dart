import 'package:ccsga_comments/Conversation/MessageCard.dart';
import 'package:flutter/material.dart';
import 'InboxCard.dart';
import 'package:ccsga_comments/DatabaseHandler.dart';
import 'package:ccsga_comments/Navigation/NavigationDrawer.dart';

class InboxPage extends StatefulWidget {
  InboxPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _InboxPageState createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  List<InboxCard> _messages = [];

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
        // child: RefreshIndicator(
        //   onRefresh: _pullRefresh,
        //   child: ListView(
        //     padding: const EdgeInsets.all(8),
        //     children: _messages,
        //   ),
        // ),

        child: new MessageCard(
            "Sam",
            "Test message to see how well this works.... !!!!!",
            DateTime.now(),
            true),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _newMessage,
        tooltip: 'New Message',
        child: Icon(Icons.add),
      ),
      drawer: NavigationDrawer(),
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
    DatabaseHandler dbHandler = DatabaseHandler.instance;
    dbHandler.getMessages().then((messages) {
      setState(() {
        _messages = [...messages];
      });
    }).catchError((err) => print("Caught an error: $err"));
  }
}
