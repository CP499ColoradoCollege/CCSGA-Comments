import 'dart:html';
import 'package:ccsga_comments/BasePage/BasePage.dart';
import 'package:ccsga_comments/DatabaseHandler.dart';
import 'package:ccsga_comments/NewMessage/ChewedResponseModel.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:tuple/tuple.dart';
import './Message.dart';
import './Conversation.dart';
import './CommitteeModel.dart';

class NewMessagePage extends BasePage {
  NewMessagePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _NewMessagePageState createState() => _NewMessagePageState();
}

class _NewMessagePageState extends BaseState<NewMessagePage> with BasicPage {
  static List<Committee> _committees = [
    new Committee(0, 'Internal Affairs'),
    new Committee(1, 'Outreach'),
    new Committee(2, 'Diversity and Inclusion')
  ];
  List<Committee> _selectedCommittees = [];

  bool _isChecked = false;

  final _formKey = GlobalKey<FormState>();

  final textFieldController = TextEditingController();

  String _errorMessage = "";
  String _successMessage = "";

  @override
  void dispose() {
    textFieldController.dispose();
    super.dispose();
  }

  @override
  String screenName() {
    return "New Conversation";
  }

  @override
  Widget body() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Container(
                    constraints: BoxConstraints(maxWidth: 1000),
                    child: Form(
                        key: _formKey,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              if (_successMessage != "" && _errorMessage == "")
                                Text(
                                  _successMessage,
                                  style:
                                      TextStyle(backgroundColor: Colors.green),
                                ),
                              if (_errorMessage != "" && _successMessage == "")
                                Text(
                                  _errorMessage,
                                  style: TextStyle(backgroundColor: Colors.red),
                                ),
                              SizedBox(height: 24),
                              CheckboxListTile(
                                title: Text("Send my message anonymously"),
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 6),
                                value: _isChecked,
                                onChanged: (bool value) =>
                                    setState(() => _isChecked = value),
                              ),
                              SizedBox(height: 24),
                              MultiSelectDialogField(
                                buttonText: Text(
                                    'Select a committee to tag if you like'),
                                title: Text('CCSGA Committees'),
                                items: _committees
                                    .map((e) => MultiSelectItem(e, e.name))
                                    .toList(),
                                listType: MultiSelectListType.CHIP,
                                onConfirm: (List<Committee> values) {
                                  _selectedCommittees = values;
                                },
                              ),
                              SizedBox(height: 24),
                              TextFormField(
                                minLines: 7,
                                maxLines: 13,
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
                                      if (_formKey.currentState.validate()) {
                                        _getConversationData(6);
                                      }
                                    },
                                    icon: Icon(Icons.send_rounded),
                                  ),
                                ),
                                controller: textFieldController,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  return null;
                                },
                              )
                            ]))))));
  }

  void _sendMessageInNewConversation() async {
    List<String> selectedCommitteesStrList = [];
    _selectedCommittees.forEach((e) => selectedCommitteesStrList.add(e.name));
    ChewedResponse chewedResponse = await DatabaseHandler.instance
        .initiateNewConversation(
            _isChecked, textFieldController.text, selectedCommitteesStrList);
    if (chewedResponse.isSuccessful) {
      _formKey.currentState.reset();
      _selectedCommittees.clear();
      textFieldController.clear();
      setState(() {
        _isChecked = false;
        _successMessage = chewedResponse.message;
      });
    } else {
      setState(() {
        _errorMessage = chewedResponse.message;
      });
    }
  }

  // move this to conversation (thread) page
  void _sendMessageAsReply() async {
    ChewedResponse chewedResponse = await DatabaseHandler.instance
        .sendMessageInConversation(1, textFieldController.text);
    if (chewedResponse.isSuccessful) {
      _formKey.currentState.reset();
      textFieldController.clear();
      setState(() {
        _isChecked = false;
        _successMessage = chewedResponse.message;
      });
    } else {
      setState(() {
        _errorMessage = chewedResponse.message;
      });
    }
  }

  // move this to Conversation (thread) page
  void _getConversationData(int conversationId) async {
    Tuple2<ChewedResponse, Conversation> responseTuple =
        await DatabaseHandler.instance.getConversation(conversationId);
    // transaction successful, there was a conv obj sent in response
    if (responseTuple.item2 != null) {
      // use setState to update the data in the UI with conv
      Conversation conv = responseTuple.item2;
      print(conv);
    } else {
      setState(() {
        _errorMessage = responseTuple.item1.message;
      });
    }
  }
}
