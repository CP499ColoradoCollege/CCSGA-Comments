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
  bool anonymousIsSwitched = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          widget.isMobileLayout
              ? Container(
                  height: 56.0,
                  child: DrawerHeader(
                      child: Text('Settings',
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                      decoration:
                          BoxDecoration(color: Theme.of(context).accentColor),
                      margin: EdgeInsets.all(0.0),
                      padding: EdgeInsets.all(10.0)),
                )
              : Center(
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
            onChanged: (bool value) {
              setState(() {
                anonymousIsSwitched = value;
              });
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
}
