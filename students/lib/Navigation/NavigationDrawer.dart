import 'package:ccsga_comments/ConversationList/ConversationListPage.dart';
import 'package:ccsga_comments/Navigation/CCSGABeamLocations.dart';
import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

class NavigationDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: 56.0,
            child: DrawerHeader(
                child: Text('CCSGA Comments',
                    style: TextStyle(color: Colors.white, fontSize: 20)),
                decoration: BoxDecoration(color: Theme.of(context).accentColor),
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.all(10.0)),
          ),
          ListTile(
            title: Text('Home'),
            onTap: () {
              print("Home Page Tapped");
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
              context.beamTo(HomeLocation());
            },
          ),
          ListTile(
            title: Text('Conversations'),
            onTap: () {
              print("Messages Page Tapped");
              // Update the state of the app

              // Then close the drawer
              Navigator.pop(context);

              context.beamTo(ConversationListLocation());
            },
          ),
          ListTile(
            title: Text('Settings'),
            onTap: () {
              print("Settings Page Tapped");
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
              context.beamTo(ConversationLocation(pathParameters: {'id': '6'}));
            },
          ),
        ],
      ),
    );
  }
}
