import 'package:flutter/material.dart';

class SettingsDrawer extends StatelessWidget {
  bool hasHeader = true;

  @required
  SettingsDrawer(bool hasHeader) {
    this.hasHeader = hasHeader;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          hasHeader
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
              : Container(),
          ListTile(
            title: Text('Settings Example #1'),
            onTap: () {},
          ),
          ListTile(
            title: Text('Settings Example #2'),
            onTap: () {},
          ),
          ListTile(
            title: Text('Settings Example #3'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
