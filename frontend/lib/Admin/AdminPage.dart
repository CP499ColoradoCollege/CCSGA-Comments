import 'package:ccsga_comments/Admin/UserCard.dart';
import 'package:ccsga_comments/BasePage/BasePage.dart';
import 'package:ccsga_comments/Models/Admins.dart';
import 'package:ccsga_comments/Models/BannedUsers.dart';
import 'package:ccsga_comments/Models/ChewedResponseModel.dart';
import 'package:ccsga_comments/Models/Conversation.dart';
import 'package:ccsga_comments/Models/GlobalEnums.dart';
import 'package:ccsga_comments/Models/Representatives.dart';
import 'package:ccsga_comments/Models/User.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tuple/tuple.dart';
import '../DatabaseHandler.dart';

//Admin page is a base page, that displays admin controls such as banning, promoting and demoting users.
class AdminPage extends BasePage {
  AdminPage({Key key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends BaseState<AdminPage> with BasicPage {
  //List of each of the user types as future objects. These expect to be updated outside of state management.
  Future<List<User>> admins;
  Future<List<User>> representatives;
  Future<List<User>> bannedUsers;

  //Init all of the future lists
  @override
  void initState() {
    super.initState();
    admins = fetchAdmins();
    representatives = fetchRepresentatives();
    bannedUsers = fetchBanned();
  }

  TextEditingController _textEditingController = TextEditingController();
  bool _isAdminChecked = true;
  bool _isRepresentativeChecked = false;
  String _revealedUser = "";

  @override
  Widget body() {
    //If there are no users in a selected list, display a blank card (reused by all three lists)
    Widget noUsersEmptyCard = Center(
      child: Padding(
        child: Text("No users of this type..."),
        padding: EdgeInsets.all(10),
      ),
    );

    //Future builder will update the display (conditionally) based on whether currentUser has data or not
    return FutureBuilder<User>(
        future: currentUser,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.hasData) {
              if (snapshot.data.isAdmin) {
                return ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  children: [
                    Center(
                      child: Text(
                        "Admins",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 20),
                      ),
                    ),
                    FutureBuilder<List<User>>(
                        future: admins,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data.length == 0) {
                              return noUsersEmptyCard;
                            } else {
                              return ListView.builder(
                                  padding: const EdgeInsets.all(8),
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount: snapshot.data.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return UserCard(
                                        snapshot.data[index], UserType.Admin);
                                  });
                            }
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
                    Center(
                      child: Text(
                        "Representatives",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 20),
                      ),
                    ),
                    FutureBuilder<List<User>>(
                        future: representatives,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data.length == 0) {
                              return noUsersEmptyCard;
                            } else {
                              return ListView.builder(
                                  padding: const EdgeInsets.all(8),
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount: snapshot.data.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return UserCard(snapshot.data[index],
                                        UserType.Representative);
                                  });
                            }
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
                    Center(
                      child: Text(
                        "Banned users",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 20),
                      ),
                    ),
                    FutureBuilder<List<User>>(
                        future: bannedUsers,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data.length == 0) {
                              return noUsersEmptyCard;
                            } else {
                              return ListView.builder(
                                  padding: const EdgeInsets.all(8),
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount: snapshot.data.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return UserCard(
                                        snapshot.data[index], UserType.Student);
                                  });
                            }
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
                  ],
                );
              } else {
                return Center(
                  child: Text("Page forbidden..."),
                );
              }
            } else {
              return Text("Loading current user data...");
            }
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
        });
  }

  //This function is used to get data to populate the admins list
  Future<List<User>> fetchAdmins() async {
    Tuple2<ChewedResponse, Admins> adminsResponse =
        await DatabaseHandler.instance.getAdmins();

    if (adminsResponse.item2 != null) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return adminsResponse.item2.admins;
    } else {
      return [];
    }
  }

  //This function is used to get data to populate the representatives list
  Future<List<User>> fetchRepresentatives() async {
    Tuple2<ChewedResponse, Representatives> repsRepsonse =
        await DatabaseHandler.instance.getRepresentatives();

    if (repsRepsonse.item2 != null) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return repsRepsonse.item2.ccsgaReps;
    } else {
      return [];
    }
  }

  //This function is used to get data to populate the banned users list
  Future<List<User>> fetchBanned() async {
    Tuple2<ChewedResponse, BannedUsers> bannedUsersResponse =
        await DatabaseHandler.instance.getBannedUsers();

    if (bannedUsersResponse.item2 != null) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return bannedUsersResponse.item2.bannedUsers;
    } else {
      return [];
    }
  }

  //This is the display name in the app bar
  @override
  String screenName() {
    return "Admin Controls";
  }

  //This is the floating action button in the bottom right side of the screen
  //In this case, it contains both a button to ban a user as well as a button to promote a user
  @override
  Widget fab() {
    return Row(
      children: [
        banUserButton(),
        SizedBox(
          width: 10,
        ),
        promoteNewUserButton(),
        SizedBox(
          width: 10,
        ),
        revealUserIdentityButton(),
      ],
      mainAxisAlignment: MainAxisAlignment.end,
    );
  }

  //This widget is in charge of displaying the floating action button in the bottom right,
  //As well as shows the dialogue box when promote new user is selected, allowing the admin
  //To select who to promote (and promote to either admin or representative)
  Widget promoteNewUserButton() {
    return FloatingActionButton.extended(
      heroTag: "promoteNewUserButton",
      onPressed: () {
        return showDialog<void>(
          context: context,
          barrierDismissible: true,
          builder: (context) {
            return StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                title: Text("Promote New User"),
                content: SizedBox(
                  height: 250,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            "Please select the role you wish to promote the user to:"),
                        CheckboxListTile(
                          title: Text("Admin"),
                          value: _isAdminChecked,
                          onChanged: (newValue) {
                            setState(() {
                              _isAdminChecked = newValue;
                              _isRepresentativeChecked = !newValue;
                            });
                          },
                          controlAffinity: ListTileControlAffinity
                              .leading, //  <-- leading Checkbox
                        ),
                        CheckboxListTile(
                          title: Text("Representative"),
                          value: _isRepresentativeChecked,
                          onChanged: (newValue) {
                            setState(() {
                              _isRepresentativeChecked = newValue;
                              _isAdminChecked = !newValue;
                            });
                          },
                          controlAffinity: ListTileControlAffinity
                              .leading, //  <-- leading Checkbox
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Text("Please enter the CC username:"),
                        SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: _textEditingController,
                          decoration: InputDecoration(
                            labelText: 'Username:',
                            labelStyle: TextStyle(color: Colors.black),
                            border: const OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    child: Text("Cancel"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text("Confirm"),
                    onPressed: () {
                      bool isAdmin = _isAdminChecked;
                      String username = _textEditingController.text;
                      if (_isAdminChecked) {
                        DatabaseHandler.instance.addAdmin(username);
                      } else {
                        DatabaseHandler.instance.addRepresentative(username);
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
          },
        );
      },
      label: Text('Promote New User'),
      icon: Icon(Icons.upgrade),
      backgroundColor: Theme.of(context).accentColor,
    );
  }

  //This widget is in charge of displaying the floating action button in the bottom right,
  //As well as shows the dialogue box when ban a user is selected, allowing the admin
  //To select who to ban
  Widget banUserButton() {
    return FloatingActionButton.extended(
      heroTag: "banUserButton",
      onPressed: () {
        return showDialog<void>(
          context: context,
          barrierDismissible: true,
          builder: (context) {
            return StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                title: Text("Ban user"),
                content: SizedBox(
                  height: 90,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Please enter the CC username you wish to ban:"),
                        SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: _textEditingController,
                          decoration: InputDecoration(
                            labelText: 'Username:',
                            labelStyle: TextStyle(color: Colors.black),
                            border: const OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    child: Text("Cancel"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text("Confirm"),
                    onPressed: () {
                      bool isAdmin = _isAdminChecked;
                      String username = _textEditingController.text;
                      DatabaseHandler.instance.banUser(username);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
          },
        );
      },
      label: Text('Ban User'),
      icon: Icon(Icons.not_interested),
      backgroundColor: Theme.of(context).accentColor,
    );
  }

  //This widget is in charge of displaying the floating action button in the bottom right,
  //As well as shows the dialogue box to reveal a user's identity
  Widget revealUserIdentityButton() {
    var userIdentity = "";
    return FloatingActionButton.extended(
      heroTag: "revealUserIdentityButton",
      onPressed: () {
        return showDialog<void>(
          context: context,
          barrierDismissible: true,
          builder: (context) {
            return StatefulBuilder(builder: (context, setState) {
              return userIdentity != ""
                  ? AlertDialog(
                      title: Text("User Identity:" + userIdentity),
                      actions: [
                        TextButton(
                          child: Text("Close"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    )
                  : AlertDialog(
                      title: Text("Reveal User Identity"),
                      content: SizedBox(
                        height: 250,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  "Please enter the conversation ID to reveal the user's anonymous identity:"),
                              TextField(
                                controller: _textEditingController,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^[0-9]+$')),
                                ],
                                decoration: InputDecoration(
                                  labelText: 'Conversation ID:',
                                  labelStyle: TextStyle(color: Colors.black),
                                  border: const OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.black),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: Text("Cancel"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text("Confirm"),
                          onPressed: () async {
                            Tuple2<ChewedResponse, Conversation>
                                conversationResponse = await DatabaseHandler
                                    .instance
                                    .getConversationDeanonymized(
                                        int.parse(_textEditingController.text));
                            setState(() {
                              userIdentity = conversationResponse
                                  .item2.messages[0].sender.username;
                            });
                          },
                        ),
                      ],
                    );
            });
          },
        );
      },
      label: Text('Reveal User Identity'),
      icon: Icon(Icons.people_alt_outlined),
      backgroundColor: Theme.of(context).accentColor,
    );
  }

  Future<void> _showAnonymousUserIdentityDialog(int conversationID) async {
    Tuple2<ChewedResponse, Conversation> conversationResponse =
        await DatabaseHandler.instance
            .getConversationDeanonymized(conversationID);

    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Revealed Identity'),
          content: Text("Username: " +
              conversationResponse.item2.messages[0].sender.username),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
