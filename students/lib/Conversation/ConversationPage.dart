import 'package:ccsga_comments/BasePage/BasePage.dart';
import 'package:ccsga_comments/Conversation/MessageThread.dart';
import 'package:flutter/material.dart';

class ConversationPage extends BasePage {
  ConversationPage({Key key}) : super(key: key);

  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends BaseState<ConversationPage>
    with BasicPage {

  final messageFieldController = TextEditingController();

  @override
  Widget body() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          MessageThread(),
          TextFormField(
            controller: messageFieldController,
            minLines: 1,
            maxLines: 6,
            cursorColor: Colors.black,
            decoration: InputDecoration(
              labelText: 'Write a message',
              labelStyle: TextStyle(color: Colors.black),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide:
                const BorderSide(color: Colors.black),
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  _sendMessage();
                },
                icon: Icon(Icons.send_rounded),
              ),
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          )
        ],
      ),
    );
  }

  @override
  String screenName() {
    return "Conversation Thread";
  }

  void _sendMessage() {
    if(this.messageFieldController.text != "") {
      print("Send message");
    }
  }
}
