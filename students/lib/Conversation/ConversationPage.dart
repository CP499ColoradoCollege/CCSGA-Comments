import 'package:ccsga_comments/BasePage/BasePage.dart';
import 'package:ccsga_comments/Conversation/MessageThread.dart';
import 'package:ccsga_comments/Models/ChewedResponseModel.dart';
import 'package:ccsga_comments/DatabaseHandler.dart';
import 'package:ccsga_comments/Models/Conversation.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class ConversationPage extends BasePage {
  final int conversationId;

  ConversationPage({Key key, this.conversationId}) : super(key: key);

  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends BaseState<ConversationPage>
    with BasicPage {
  final _messageFieldController = TextEditingController();
  Conversation _conversation = Conversation();
  Map _pathParams;
  int _conversationId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _pathParams = getPathParameters();
      //if a convId is passed in when creating the page, use that.
      // if not, check the url for the id (pathParams)
      _conversationId = widget.conversationId ?? int.parse(_pathParams['id']);
      _conversation = await _getConversationData();
      print("conv id -> ${_conversation.id}");
    });
  }

  @override
  Widget body() {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Column(
        children: [
          MessageThread(conv: _conversation),
          TextFormField(
            controller: _messageFieldController,
            minLines: 2,
            maxLines: 6,
            cursorColor: Colors.black,
            decoration: InputDecoration(
              labelText: 'Write a message',
              labelStyle: TextStyle(color: Colors.black),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black),
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

  Future<Conversation> _getConversationData() async {
    Tuple2<ChewedResponse, Conversation> responseTuple =
        await DatabaseHandler.instance.getConversation(_conversationId);
    print("responseTuple.item2.messages -> ${responseTuple.item2.messages}");
    // transaction successful, there was a conv obj sent in response, otherwise null
    if (responseTuple.item2 != null) {
      // use setState to update the data in the UI with conv
      return responseTuple.item2;
    } else {
      setState(() {
        // _errorMessage = responseTuple.item1.message;
        return null;
      });
    }
  }

  void _sendMessage() async {
    if (_messageFieldController.text != "") {
      ChewedResponse chewedResponse = await DatabaseHandler.instance
          .sendMessageInConversation(1, _messageFieldController.text);
      if (chewedResponse.isSuccessful) {
        _messageFieldController.clear();
        setState(() {
          // _successMessage = chewedResponse.message;
        });
      } else {
        setState(() {
          // _errorMessage = chewedResponse.message;
        });
      }
    }
  }
}
