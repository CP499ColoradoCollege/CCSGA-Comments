import 'dart:html';
import 'package:flutter/material.dart';
import 'package:ccsga_comments/DatabaseHandler.dart';

class NewMessagePage extends StatefulWidget {
  NewMessagePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _NewMessagePageState createState() => _NewMessagePageState();
}

class _NewMessagePageState extends State<NewMessagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Write a message',
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.black, width: 2.0),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () => _sendMessage(),
                          icon: Icon(Icons.send_rounded),
                        ),
                      ),
                    )))));
  }

  void _sendMessage() {
    print("Send message");
  }
}
