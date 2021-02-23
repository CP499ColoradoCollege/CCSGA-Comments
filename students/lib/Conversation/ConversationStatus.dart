import 'package:ccsga_comments/Models/GlobalEnums.dart';
import 'package:flutter/material.dart';
import 'package:enum_to_string/enum_to_string.dart';

typedef FutureVoidCallback = Future<void> Function(String status);

class ConversationStatus extends StatefulWidget {
  final FutureVoidCallback updateStatusCallback;
  final String status;
  final bool isCcsga;

  ConversationStatus(this.updateStatusCallback, this.status, this.isCcsga);

  @override
  _ConversationStatusState createState() => _ConversationStatusState();
}

class _ConversationStatusState extends State<ConversationStatus> {
  String unread = EnumToString.convertToString(ConversationStatusLabel.Unread,
      camelCase: true);
  String inProgress = EnumToString.convertToString(
      ConversationStatusLabel.InProgress,
      camelCase: true);
  String done = EnumToString.convertToString(ConversationStatusLabel.Done,
      camelCase: true);
  String denied = EnumToString.convertToString(ConversationStatusLabel.Denied,
      camelCase: true);

  @override
  Widget build(BuildContext context) {
    String currentDropdownStatus = widget.status;
    return SizedBox(
      child: FractionallySizedBox(
        child: Card(
          child: ListTile(
            title: Row(children: [
              Spacer(),
              Icon(Icons.pending_outlined),
              SizedBox(
                width: 5,
              ),
              Text("Conversation status:"),
              SizedBox(
                width: 5,
              ),
              widget.isCcsga
                  ? DropdownButton<String>(
                      value: currentDropdownStatus,
                      icon: Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      underline: Container(
                        height: 2,
                        color: Theme.of(context).accentColor,
                      ),
                      onChanged: (String newValue) {
                        setState(() {
                          currentDropdownStatus = newValue;
                          if (currentDropdownStatus == unread) {
                            widget.updateStatusCallback(unread);
                          } else if (currentDropdownStatus == denied) {
                            widget.updateStatusCallback(denied);
                          } else if (currentDropdownStatus == done) {
                            widget.updateStatusCallback(done);
                          } else {
                            widget.updateStatusCallback(inProgress);
                          }
                        });
                      },
                      items: [
                        DropdownMenuItem(
                          child: Text("Unread"),
                          value: unread,
                        ),
                        DropdownMenuItem(
                          child: Text("In Progress"),
                          value: inProgress,
                        ),
                        DropdownMenuItem(
                          child: Text("Done"),
                          value: done,
                        ),
                        DropdownMenuItem(
                          child: Text("Denied"),
                          value: denied,
                        ),
                      ],
                    )
                  : Text(widget.status),
              Spacer(),
            ]),
          ),
        ),
        widthFactor: 0.6,
      ),
      height: 55,
    );
  }
}
