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

/// This is the page for an individual conversation with messages
///
/// It can be accessed either from the ConversationListPage or
/// by typing in the url of the conversation e.g. '/conversation/123'
class ConversationPage extends BasePage {
  final int conversationId;

  ConversationPage({Key key, this.conversationId}) : super(key: key);

  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends BaseState<ConversationPage>
    with BasicPage {
  final _messageFieldController = TextEditingController();
  Map _pathParams;

  @override
  void initState() {
    super.initState();
    _pathParams = getPathParameters();
  }

  @override
  Widget body() {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: FutureBuilder<Tuple2<User, Conversation>>(
          future: _getConversationData(),
          builder: (BuildContext context, AsyncSnapshot<Tuple2<User, Conversation>> snapshot) {
            if(snapshot.hasError){
              String exceptionString = snapshot.error.toString();
              String errorMessage;
              switch(exceptionString.substring(exceptionString.length - 3)){
                case "401":
                  errorMessage = "You are not signed in. Please refresh the page.";
                  break;
                case "403":
                  errorMessage = "You do not have access to this conversation, or you are currently banned from this site. Please email CCSGA if you believe this is a mistake.";
                  break;
                case "404":
                  errorMessage = "Conversation not found.";
                  break;
                default:
                  errorMessage = "Something went wrong. Refreshing the page may help.";
              }
              return Center(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: Text(errorMessage),
                ),
              );
            }else if (snapshot.hasData){
              return Column(
                children: [
                  ConversationStatus(
                      this.updateConversationStatus,
                      snapshot.data.item2.status,
                      (snapshot.data.item1.isCcsga ||
                              snapshot.data.item1.isAdmin) ??
                          false),
                  MessageThread(
                    conv: snapshot.data.item2,
                    currentUser: snapshot.data.item1,
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
            }else{ // still loading
              return Center(
                child: SizedBox(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(),
                ),
              );
            }
          }),
    );
  }

  @override
  String screenName() {
    return "Conversation Thread";
  }

  /// Custom conversation settings drawer
  @override
  Widget settingsDrawer() {
    return ConversationSettingsDrawer(false, _getConversationData());
  }

  /// Override right icon button for said settings drawer
  @override
  Icon get rightButtonIcon => Icon(Icons.settings);

  /// This method updates the conversation object
  Future<void> updateConversationStatus(String status) async {
    int _conversationId = widget.conversationId ?? int.parse(_pathParams['id']);
    DatabaseHandler.instance.updateConversation(
        _conversationId, ConversationUpdate(setStatus: status));
  }

  /// This gets the conversation data and the user data
  ///
  /// 2 separate DatabaseHandler methods are called. 
  /// If both succeed, this function returns a future representing the user and the conversation.
  /// If either DatabaseHandler method raises an exception, that exception is passed up to this function's caller.
  Future<Tuple2<User, Conversation>> _getConversationData() async {
    // if a convId is passed in when creating the page, use that.
    // if not, check the url for the id (pathParams)
    int _conversationId = widget.conversationId ?? int.parse(_pathParams['id']);
    Tuple2<ChewedResponse, Conversation> conversationResponse =
        await DatabaseHandler.instance
            .getConversation(_conversationId);

    Tuple2<ChewedResponse, User> userResponse = await DatabaseHandler.instance
        .getAuthenticatedUser();
    // transaction successful, there were a conv obj and a user obj sent in responses, without exceptions thrown
    return Tuple2(userResponse.item2, conversationResponse.item2);
  }

  /// This function makes a call to append a new message
  /// to this existing conversation
  ///
  /// Error is printed to the console if any
  /// setState() after _getConversationData() allows
  /// for the new message to appear without reload
  void _sendMessage() async {
    if (_messageFieldController.text != "") {
      int _conversationId = widget.conversationId ?? int.parse(_pathParams['id']);
      await DatabaseHandler.instance
          .sendMessageInConversation(
              _conversationId, _messageFieldController.text);
      _messageFieldController.clear();
      setState(() {}); // reload, letting _getConversationData take care of error handling
    }
  }

  handleError(e) {
    print('Error: ${e.toString()}');
  }
}
