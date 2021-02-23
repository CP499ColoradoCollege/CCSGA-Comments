import 'package:ccsga_comments/BasePage/BasePage.dart';
import 'package:ccsga_comments/Conversation/MessageThread.dart';
import 'package:ccsga_comments/Models/ChewedResponseModel.dart';
import 'package:ccsga_comments/DatabaseHandler.dart';
import 'package:ccsga_comments/Models/Conversation.dart';
import 'package:ccsga_comments/Models/ConversationUpdate.dart';
import 'package:ccsga_comments/Models/GlobalEnums.dart';
import 'package:ccsga_comments/Models/Message.dart';
import 'package:ccsga_comments/Models/User.dart';
import 'package:ccsga_comments/Settings/ConversationSettingsDrawer.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import 'ConversationStatus.dart';

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
  User _currentUser;

  @override
  void initState() {
    super.initState();
    // apparently this is the way to do stuff in initState
    // print("conv id -> ${_conversation.id}");
  }

  @override
  Widget body() {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: FutureBuilder<bool>(
          future: _getConversationData(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: [
                  ConversationStatus(this.updateConversationStatus,
                      _conversation.status, this._currentUser.isCcsga ?? false),
                  MessageThread(
                    conv: this._conversation,
                    currentUser: _currentUser,
                  ),
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
              );
            } else {
              return CircularProgressIndicator();
            }
          }),
    );
  }

  @override
  String screenName() {
    return "Conversation Thread";
  }

  @override
  Widget settingsDrawer() {
    return ConversationSettingsDrawer(false, _conversation);
  }

  @override
  Icon get rightButtonIcon => Icon(Icons.settings);

  Future<void> updateConversationStatus(String status) async {
    DatabaseHandler.instance.updateConversation(
        _conversation.id, ConversationUpdate(setStatus: status));
  }

  Future<bool> _getConversationData() async {
    _pathParams = getPathParameters();
    //if a convId is passed in when creating the page, use that.
    // if not, check the url for the id (pathParams)
    _conversationId = widget.conversationId ?? int.parse(_pathParams['id']);
    Tuple2<ChewedResponse, Conversation> responseTuple =
        await DatabaseHandler.instance.getConversation(_conversationId);
    Tuple2<ChewedResponse, User> userResponse =
        await DatabaseHandler.instance.getAuthenticatedUser();

    if (userResponse.item2 != null) {
      print("user response successful");
      _currentUser = userResponse.item2;
    } else {
      print("user response unsuccessful");
      return false;
    }

    // transaction successful, there was a conv obj sent in response, otherwise null
    if (responseTuple.item2 != null) {
      print("responseTuple.item2.messages -> ${responseTuple.item2.messages}");
      // use setState to update the data in the UI with conv
      _conversation = responseTuple.item2;
      // FutureBuilder requires that we return something
      print("conversation response successful");
      return true;
    } else {
      setState(() {
        // _errorMessage = responseTuple.item1.message;
      });
      print("conversation response unsuccessful");
      return false;
    }

    Message msg = Message(
        body: "test body",
        dateTime: "2021-02-21 13:00:00",
        isRead: false,
        sender: Sender(displayName: "testDispName", username: "testUserName"));
    Conversation conv = Conversation(id: 99, messages: {"99": msg});
    _conversation = conv;
    return true;
  }

  void _sendMessage() async {
    if (_messageFieldController.text != "") {
      ChewedResponse chewedResponse = await DatabaseHandler.instance
          .sendMessageInConversation(
              _conversationId, _messageFieldController.text);
      if (chewedResponse.isSuccessful) {
        _messageFieldController.clear();
        await _getConversationData();
        setState(() {
          // _successMessage = chewedResponse.message;
        });
      } else {
        setState(() {
          throw new Error();
          // _errorMessage = chewedResponse.message;
        });
      }
    }
  }
}
