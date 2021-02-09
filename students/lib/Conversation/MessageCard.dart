import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageCard extends StatelessWidget {
  String sender;
  String body;
  String time;
  bool isSender;

  MessageCard(String sender, String body, DateTime time, bool isSender) {
    this.sender = sender;
    this.body = body;
    this.time = DateFormat("MMM d -").add_jm().format(time);
    this.isSender = isSender;
  }

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
                      padding: const EdgeInsets.all(10.0),
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
                  Text(
                    this.time.toString(),
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
