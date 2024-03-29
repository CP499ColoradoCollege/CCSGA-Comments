import 'dart:html';

import 'package:ccsga_comments/Models/ChewedResponseModel.dart';
import 'package:ccsga_comments/Models/User.dart';
import 'package:ccsga_comments/Navigation/CCSGABeamLocations.dart';
import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';

import '../DatabaseHandler.dart';

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
  Future<User> currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = _getUserData();
  }

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
              // Update the state of the app

              // Then close the drawer
              if (widget.hasHeader) {
                Navigator.pop(context);
              }

              context.beamTo(ConversationListLocation());
            },
          ),
          FutureBuilder<User>(
              future: currentUser,
              builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
                if (snapshot.hasData && snapshot.data.isAdmin) {
                  return ListTile(
                    title: Center(
                      child: Text(
                        'Admin Controls',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    contentPadding: EdgeInsets.all(10),
                    onTap: () {
                      // Then close the drawer
                      if (widget.hasHeader) {
                        Navigator.pop(context);
                      }

                      context.beamTo(AdminLocation());
                    },
                  );
                } else {
                  return Container();
                }
              }),
          ListTile(
            title: Center(
              child: Text(
                'Log Out',
                style: TextStyle(fontSize: 20),
              ),
            ),
            contentPadding: EdgeInsets.all(10),
            onTap: () {
              logoutTapped();
              // Update the state of the app
              setState(() {});
              // Then close the drawer
              if (widget.hasHeader) {
                Navigator.pop(context);
              }
            },
          ),
          FutureBuilder<User>(
            future: currentUser,
            builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
              if (snapshot.hasData) {
                return ListTile(
                  title: Center(
                    child: Text(
                      'Signed in as ${snapshot.data.username}',
                      style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                    ),
                  ),
                  contentPadding: EdgeInsets.all(10),
                );
              } else {
                return Container();
              }
            }
          ),
        ],
      ),
    );
  }

  void logoutTapped() async {
    const url = "https:/logout";
    if (await canLaunch(url)) {
      await launch(url);
      context.beamTo(LogoutLocation());
    }
  }

  Future<User> _getUserData() async {
    Tuple2<ChewedResponse, User> userResponse =
        await DatabaseHandler.instance.getAuthenticatedUser();

    if (userResponse.item2 != null) {
      return userResponse.item2;
    } else {
      return null;
    }
  }
}
