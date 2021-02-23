import 'package:ccsga_comments/Models/GlobalEnums.dart';
import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    ConversationStatusLabel currentDropdownStatus =
        ConversationStatusLabel.Unread;
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
                  ? Padding(
                      padding: EdgeInsets.all(10),
                      child: DropdownButton<ConversationStatusLabel>(
                        value: currentDropdownStatus,
                        icon: Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        underline: Container(
                          height: 2,
                          color: Theme.of(context).accentColor,
                        ),
                        onChanged: (ConversationStatusLabel newValue) {
                          setState(() {
                            currentDropdownStatus = newValue;
                            switch (currentDropdownStatus) {
                              case ConversationStatusLabel.Unread:
                                widget.updateStatusCallback("Unread");
                                break;
                              case ConversationStatusLabel.InProgress:
                                widget.updateStatusCallback("In Progress");
                                break;
                              case ConversationStatusLabel.Done:
                                widget.updateStatusCallback("Done");
                                break;
                              case ConversationStatusLabel.Denied:
                                widget.updateStatusCallback("Denied");
                                break;
                            }
                          });
                        },
                        items: [
                          DropdownMenuItem(
                            child: Text("Unread"),
                            value: ConversationStatusLabel.Unread,
                          ),
                          DropdownMenuItem(
                            child: Text("In Progress"),
                            value: ConversationStatusLabel.InProgress,
                          ),
                          DropdownMenuItem(
                            child: Text("Done"),
                            value: ConversationStatusLabel.Done,
                          ),
                          DropdownMenuItem(
                            child: Text("Denied"),
                            value: ConversationStatusLabel.Denied,
                          ),
                        ],
                      ),
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
