import 'package:ccsga_comments/Models/ChewedResponseModel.dart';
import 'package:ccsga_comments/Models/Conversation.dart';
import 'package:ccsga_comments/Models/ConversationUpdate.dart';
import 'package:ccsga_comments/Models/User.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import '../DatabaseHandler.dart';

/// This drawer appears on the conversation page
/// Currently functionality: anonymity slider
/// Future functionality: mark read/unread and others
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

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<Tuple2<User, Conversation>>(
          future: _getUserData(),
          builder: (BuildContext context,
              AsyncSnapshot<Tuple2<User, Conversation>> snapshot) {
            if (snapshot.hasData) {
              print("User object: " + snapshot.data.item1.toString());
              print("Conversation object: " + snapshot.data.item2.toString());
              anonymousIsSwitched =
                  !snapshot.data.item2.studentIdentityRevealed;
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
                      if (snapshot.data.item1.isCcsga == false) {
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
                  // Padding(
                  //   child: ElevatedButton(
                  //     onPressed: () {
                  //       // Respond to button press
                  //     },
                  //     child: Text('Mark conversation as unread'),
                  //   ),
                  //   padding: EdgeInsets.all(10),
                  // ),
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

  /// If a student wishes to deanonimize their conversation
  /// and thereby reveal their identity, this function is called
  /// This shows the confirmation dialogue with Confirm and Cancel
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
      print("Conversation id:" + widget.conversation.id.toString());
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

  /// Gets user's data from CAS and the details of the conversation
  /// to show the correct position on the anonymity slider
  Future<Tuple2<User, Conversation>> _getUserData() async {
    Tuple2<ChewedResponse, User> userResponse =
        await DatabaseHandler.instance.getAuthenticatedUser();

    Tuple2<ChewedResponse, Conversation> conversationResponse =
        await DatabaseHandler.instance.getConversation(widget.conversation.id);

    if (userResponse.item2 != null && conversationResponse.item2 != null) {
      return Tuple2(userResponse.item2, conversationResponse.item2);
    } else {
      return null;
    }
  }
}
