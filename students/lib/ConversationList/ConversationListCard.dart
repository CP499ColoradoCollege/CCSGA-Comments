import 'package:ccsga_comments/Models/Conversation.dart';
import 'package:ccsga_comments/Models/Message.dart';
import 'package:flutter/material.dart';

class ConversationListCard extends StatelessWidget {
  final String joinedLabels;
  final String mostRecentMessageBody;
  final String mostRecentMessageDateTime;

  ConversationListCard(
      {this.joinedLabels,
      this.mostRecentMessageBody,
      this.mostRecentMessageDateTime});

  @override
  Widget build(BuildContext context) {
    // print("we're in the builder!");
    // String joinedLabels = "";
    // print("we're after the loop!");
    // List<String> messageKeys = conversation.messages.keys.toList()
    //   ..sort((a, b) => a.compareTo(b));
    // print("we're after messageKeys!");
    // Message mostRecentMessage = conversation.messages[messageKeys.last];
    // print("we're after mostRecentMessage!");
    // print(
    //     "joinedLabels -> ${joinedLabels}, messageKeys: ${messageKeys}, mostRecentMessage.body -> ${mostRecentMessage.body}, mostRecentMessage.dateTime -> ${mostRecentMessage.dateTime}");

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {
          cardTapped();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.message_outlined),
              title: Text("CCSGA " + joinedLabels),
              subtitle: Text(mostRecentMessageBody),
              isThreeLine: true,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    mostRecentMessageDateTime,
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void cardTapped() {
    print('Card tapped.');
  }
}
