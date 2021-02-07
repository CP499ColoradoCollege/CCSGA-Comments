import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InboxCard extends StatelessWidget {
  String name;
  String message;
  String time;

  InboxCard(String name, String message, DateTime time) {
    this.name = name;
    this.message = message;
    this.time = DateFormat("MMM d -").add_jm().format(time);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
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
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      this.time.toString(),
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void cardTapped() {
    print('Card tapped.');
  }
}
