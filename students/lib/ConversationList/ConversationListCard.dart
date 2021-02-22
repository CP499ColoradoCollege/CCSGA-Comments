import 'package:ccsga_comments/Models/Conversation.dart';
import 'package:ccsga_comments/Models/Message.dart';
import 'package:flutter/material.dart';

class ConversationListCard extends StatelessWidget {
  final Conversation conversation;

  ConversationListCard({this.conversation});

  @override
  Widget build(BuildContext context) {
    String joinedLabels = "";
    for (String label in conversation.labels) {
      joinedLabels += (" " + label);
    }
    List<String> messageKeys = conversation.messages.keys.toList()
      ..sort((a, b) => a.compareTo(b));
    Message mostRecentMessage = conversation.messages[messageKeys.last];

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
              subtitle: Text(mostRecentMessage.body),
              isThreeLine: true,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    mostRecentMessage.dateTime,
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
