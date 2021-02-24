import 'package:ccsga_comments/Models/User.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ccsga_comments/Models/Message.dart';

/// A single message card widget
class MessageCard extends StatelessWidget {
  final Message message;
  final bool isMyMessage;

  MessageCard({this.message, this.isMyMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: FractionallySizedBox(
          //Align the text based on if the active user sent the message or not
          alignment:
              this.isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
          widthFactor: 0.66,
          child: Align(
            alignment:
                (this.isMyMessage ? Alignment.topRight : Alignment.topLeft),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                //Update the color based on the sender
                color: (this.isMyMessage
                    ? Colors.blue[200]
                    : Colors.grey.shade200),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Flexible(
                      child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      this.message.body.toString(),
                      textAlign: TextAlign.left,
                    ),
                  )),
                  Row(
                    children: [
                      Expanded(
                          child: Text(
                        this.message.sender.displayName,
                        textAlign: TextAlign.left,
                      )),
                      Text(
                        //Update the date to not be in UTC
                        DateFormat("MMM d -")
                            .add_jm()
                            .format(DateTime.parse(this.message.dateTime)
                                .subtract(new Duration(hours: 7)))
                            .toString(),
                        textAlign: TextAlign.right,
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
