import 'package:ccsga_comments/Models/User.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ccsga_comments/Models/Message.dart';

class MessageCard extends StatelessWidget {
  final Message message;

  MessageCard(this.message);

  User currentUser = User(username: "samdogg7", displayName: "Sam");

  @override
  Widget build(BuildContext context) {
    bool isCurrentUser = this.message.sender.username != currentUser.username;
    return Container(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: FractionallySizedBox(
          alignment:
              isCurrentUser ? Alignment.centerLeft : Alignment.centerRight,
          widthFactor: 0.66,
          child: Align(
            alignment: (isCurrentUser ? Alignment.topLeft : Alignment.topRight),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color:
                    (isCurrentUser ? Colors.grey.shade200 : Colors.blue[200]),
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
                        this.message.dateTime,
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
