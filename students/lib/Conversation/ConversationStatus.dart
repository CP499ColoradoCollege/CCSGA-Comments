import 'package:flutter/material.dart';

class ConversationStatus extends StatelessWidget {
  final String status;

  ConversationStatus(this.status);

  @override
  Widget build(BuildContext context) {
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
              Text(status),
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
