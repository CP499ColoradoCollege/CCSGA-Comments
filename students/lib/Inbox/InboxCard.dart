import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InboxCard extends StatelessWidget {
  final String name;
  final String message;
  final DateTime time;

  InboxCard(this.name, this.message, this.time);

  @override
  Widget build(BuildContext context) {
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
              title: Text(this.name),
              subtitle: Text(this.message),
              isThreeLine: true,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    DateFormat("MMM d -").add_jm().format(this.time).toString(),
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
