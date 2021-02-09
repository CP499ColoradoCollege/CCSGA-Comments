import 'dart:html';
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

class NewMessagePage extends StatefulWidget {
  NewMessagePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _NewMessagePageState createState() => _NewMessagePageState();
}

class _NewMessagePageState extends State<NewMessagePage> {
  static List<Committee> _committees = [
    Committee(id: 0, name: 'Internal Affairs'),
    Committee(id: 1, name: 'Outreach'),
    Committee(id: 2, name: 'Diversity and Inclusion')
  ];
  List<Committee> _selectedCommittees = [];

  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Center(child: Text(widget.title))),
        body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Container(
                        constraints: BoxConstraints(maxWidth: 1000),
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
                                decoration: InputDecoration(
                                  labelText: 'Write a message',
                                  border: const OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Colors.black, width: 2.0),
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () => _sendMessage(),
                                    icon: Icon(Icons.send_rounded),
                                  ),
                                ),
                              )
                            ]))))));
  }

  void _sendMessage() {
    print("Send message");
  }
}
