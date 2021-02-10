import 'dart:html';
import 'package:ccsga_comments/BasePage.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class Committee {
  final int id;
  final String name;

  Committee({
    this.id,
    this.name,
  });
}

class NewMessagePage extends BasePage {
  NewMessagePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _NewMessagePageState createState() => _NewMessagePageState();
}

class _NewMessagePageState extends BaseState<NewMessagePage> with BasicPage {
  static List<Committee> _committees = [
    Committee(id: 0, name: 'Internal Affairs'),
    Committee(id: 1, name: 'Outreach'),
    Committee(id: 2, name: 'Diversity and Inclusion')
  ];
  List<Committee> _selectedCommittees = [];

  bool _isChecked = false;

  final _formKey = GlobalKey<FormState>();

  @override
  String screenName() {
    return "Messages";
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
                                onConfirm: (values) {
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
                                        _sendMessage();
                                      }
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
                            ]))))));
  }

  void _sendMessage() {
    print("Send message");
  }
}
