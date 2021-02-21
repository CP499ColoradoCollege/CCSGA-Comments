import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ccsga_comments/Models/Message.dart';

class MessageCard extends StatelessWidget {
  final Message message;
  final bool isMyMessage;

  MessageCard({this.message, this.isMyMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: FractionallySizedBox(
          alignment:
              this.isMyMessage ? Alignment.centerLeft : Alignment.centerRight,
          widthFactor: 0.66,
          child: Align(
            alignment:
                (this.isMyMessage ? Alignment.topLeft : Alignment.topRight),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: (this.isMyMessage
                    ? Colors.grey.shade200
                    : Colors.blue[200]),
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
                        this.message.body.toString(),
                        textAlign: TextAlign.left,
                      ))
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        this.message.sender.displayName,
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        DateFormat("MMM d -")
                            .add_jm()
                            .format(DateTime.parse(this.message.dateTime))
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
