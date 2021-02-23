import 'package:flutter/material.dart';

class ConversationSettingsDrawer extends StatefulWidget {
  var isMobileLayout = false;

  @required
  ConversationSettingsDrawer(bool isMobileLayout) {
    this.isMobileLayout = isMobileLayout;
  }

  _ConversationSettingsDrawerState createState() =>
      _ConversationSettingsDrawerState();
}

class _ConversationSettingsDrawerState
    extends State<ConversationSettingsDrawer> {
  bool anonymousIsSwitched = true;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Center(
              child: Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              "Conversation Settings",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          )),
          SwitchListTile(
            title: Text(
              'Anonymous',
            ),
            value: anonymousIsSwitched,
            inactiveThumbColor:
                anonymousIsSwitched ? Colors.white : Colors.grey.shade400,
            inactiveTrackColor: anonymousIsSwitched
                ? Colors.grey.withAlpha(0x80)
                : Colors.grey[300],
            onChanged: (bool value) {
              if (anonymousIsSwitched) {
                _showMyDialog();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      "You cannot anonymize yourself after revealing your identity..."),
                  duration: Duration(seconds: 2),
                ));
              }
            },
            // secondary: const Icon(Icons.account_circle_outlined),
          ),
          Padding(
            child: ElevatedButton(
              onPressed: () {
                // Respond to button press
              },
              child: Text('Mark conversation as unread'),
            ),
            padding: EdgeInsets.all(10),
          ),
        ],
      ),
    );
  }

  Future<void> _showMyDialog() async {
    bool isConfirmed = false;
    await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure you would like to deanoynomize yourself?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                isConfirmed = true;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    if (isConfirmed && anonymousIsSwitched) {
      setState(() {
        anonymousIsSwitched = false;
      });
    }
  }
}
