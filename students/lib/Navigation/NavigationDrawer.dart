import 'package:ccsga_comments/Navigation/CCSGABeamLocations.dart';
import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';
import 'package:url_launcher/url_launcher.dart';

class NavigationDrawer extends StatefulWidget {
  bool hasHeader = true;

  @required
  NavigationDrawer(bool hasHeader) {
    this.hasHeader = hasHeader;
  }

  @override
  _NavigationDrawerState createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          widget.hasHeader
              ? Container(
                  height: 56.0,
                  child: Padding(
                    child: Text('CCSGA Comments',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                    padding: EdgeInsets.only(top: 25),
                  ))
              : Container(),
          ListTile(
            title: Center(
              child: Text(
                'Home',
                style: TextStyle(fontSize: 20),
              ),
            ),
            contentPadding: EdgeInsets.all(10),
            onTap: () {
              print("Home Page Tapped");
              // Update the state of the app
              // ...
              // Then close the drawer
              if (widget.hasHeader) {
                Navigator.pop(context);
              }
              context.beamTo(HomeLocation());
            },
          ),
          ListTile(
            title: Center(
              child: Text(
                'Conversations',
                style: TextStyle(fontSize: 20),
              ),
            ),
            contentPadding: EdgeInsets.all(10),
            onTap: () {
              print("Messages Page Tapped");
              // Update the state of the app

              // Then close the drawer
              if (widget.hasHeader) {
                Navigator.pop(context);
              }

              context.beamTo(ConversationListLocation());
            },
          ),
          ListTile(
            title: Center(
              child: Text(
                'Log Out',
                style: TextStyle(fontSize: 20),
              ),
            ),
            contentPadding: EdgeInsets.all(10),
            onTap: () {
              print("Log Out Tapped");
              // Update the state of the app
              setState(() {});
              // Then close the drawer
              if (widget.hasHeader) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
