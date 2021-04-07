import 'package:ccsga_comments/BasePage/BasePage.dart';
import 'package:ccsga_comments/DatabaseHandler.dart';
import 'package:ccsga_comments/Models/ChewedResponseModel.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class NewMessagePage extends BasePage {
  NewMessagePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _NewMessagePageState createState() => _NewMessagePageState();
}

class _NewMessagePageState extends BaseState<NewMessagePage> with BasicPage {
  static List<Committee> _committees = [
    new Committee(id: 0, name: 'Internal Affairs'),
    new Committee(id: 1, name: 'Outreach'),
    new Committee(id: 2, name: 'Diversity and Inclusion')
  ];
  List<Committee> _selectedCommittees = [];

  // reveal identity to CCSGA
  bool _isChecked = false;

  // used to validate and submit form
  final _formKey = GlobalKey<FormState>();

  // used to validate, clear text field
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
                              // depending on the success/error, display appropriate text
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
                                title: Text("Share my identity with CCSGA"),
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
                                      // don't submit if no text
                                      if (_formKey.currentState.validate()) {
                                        _sendMessageInNewConversation();
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

  /// Once form submit is clicked, call Databasehandler,
  /// reset the form and display the success/error message
  /// according to the reponse
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
        _errorMessage = "";
      });
    } else {
      setState(() {
        _successMessage = "";
        _errorMessage = chewedResponse.message;
      });
    }
  }
}

class Committee {
  final int id;
  final String name;

  Committee({
    this.id,
    this.name,
  });
}
