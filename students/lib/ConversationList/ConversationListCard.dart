import 'package:beamer/beamer.dart';
import 'package:ccsga_comments/Navigation/CCSGABeamLocations.dart';
import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';
import 'package:intl/intl.dart';

typedef ConverastionCallback = void Function(int id);

class ConversationListCard extends StatelessWidget {
  final ConverastionCallback conversationCallback;
  final int convId;
  final String joinedLabels;
  final String mostRecentMessageBody;
  final String mostRecentMessageDateTime;

  ConversationListCard(
      {this.convId,
      this.joinedLabels,
      this.mostRecentMessageBody,
      this.mostRecentMessageDateTime,
      this.conversationCallback});

  @override
  Widget build(BuildContext context) {
    DateTime formattedDateTime = DateFormat("HH:mm a - MM-dd-yyyy")
        .parse(mostRecentMessageDateTime, true);

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
          conversationCallback(convId);
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
                    formattedDateTime.toLocal().toString(),
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
}
