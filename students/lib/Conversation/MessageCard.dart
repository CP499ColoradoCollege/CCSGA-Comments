import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageCard extends StatelessWidget {
  final String sender;
  final String body;
  final DateTime time;
  final bool isSender;

  MessageCard(this.sender, this.body, this.time, this.isSender);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
      child: Align(
        alignment: (this.isSender ? Alignment.topLeft : Alignment.topRight),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: (this.isSender ? Colors.grey.shade200 : Colors.blue[200]),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        this.body.toString(),
                        textAlign: TextAlign.left,
                      ))
                ],
              ),
              Row(
                children: [
                  Text(
                    this.sender.toString(),
                    textAlign: TextAlign.left,
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  Text(
                    DateFormat("MMM d -").add_jm().format(this.time).toString(),
                    textAlign: TextAlign.right,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
