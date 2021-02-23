import 'package:ccsga_comments/Models/ChewedResponseModel.dart';
import 'package:ccsga_comments/Models/Conversation.dart';
import 'package:ccsga_comments/Models/ConversationUpdate.dart';
import 'package:ccsga_comments/Models/User.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import '../DatabaseHandler.dart';

class ConversationSettingsDrawer extends StatefulWidget {
  var isMobileLayout = false;
  Conversation conversation;

  @required
  ConversationSettingsDrawer(bool isMobileLayout, Conversation conversation) {
    this.isMobileLayout = isMobileLayout;
    this.conversation = conversation;
  }

  _ConversationSettingsDrawerState createState() =>
      _ConversationSettingsDrawerState();
}

class _ConversationSettingsDrawerState
    extends State<ConversationSettingsDrawer> {
  bool anonymousIsSwitched = true;
  User currentUser;

  @override
  Widget build(BuildContext context) {
    if (currentUser.isCcsga) {
      anonymousIsSwitched = !widget.conversation.studentIdentityRevealed;
    }

    return Drawer(
      child: FutureBuilder<bool>(
          future: _getUserData(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.hasData) {
              return ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "Conversation Settings",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SwitchListTile(
                    title: Text(
                      'Anonymous',
                    ),
                    value: anonymousIsSwitched,
                    inactiveThumbColor: anonymousIsSwitched
                        ? Colors.white
                        : Colors.grey.shade400,
                    inactiveTrackColor: anonymousIsSwitched
                        ? Colors.grey.withAlpha(0x80)
                        : Colors.grey[300],
                    onChanged: (bool value) {
                      if (currentUser.isCcsga == false) {
                        if (anonymousIsSwitched) {
                          _showMyDialog();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "You cannot anonymize yourself after revealing your identity..."),
                            duration: Duration(seconds: 2),
                          ));
                        }
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
              );
            } else {
              return Flexible(
                child: Center(
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }
          }),
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
      DatabaseHandler.instance.updateConversation(
          widget.conversation.id,
          ConversationUpdate(
              revealIdentity: true,
              setArchived: null,
              setLabels: null,
              setRead: null,
              setStatus: null));
      setState(() {
        anonymousIsSwitched = false;
      });
    }
  }

  Future<bool> _getUserData() async {
    Tuple2<ChewedResponse, User> userResponse =
        await DatabaseHandler.instance.getAuthenticatedUser();

    if (userResponse.item2 != null) {
      print("user response successful");
      print(userResponse.item2);
      currentUser = userResponse.item2;
      return true;
    } else {
      print("user response unsuccessful");
      return false;
    }
  }
}
