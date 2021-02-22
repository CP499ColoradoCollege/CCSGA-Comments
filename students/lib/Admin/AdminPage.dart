import 'package:ccsga_comments/Admin/UserCard.dart';
import 'package:ccsga_comments/BasePage/BasePage.dart';
import 'package:ccsga_comments/Models/Admins.dart';
import 'package:ccsga_comments/Models/BannedUsers.dart';
import 'package:ccsga_comments/Models/ChewedResponseModel.dart';
import 'package:ccsga_comments/Models/Representatives.dart';
import 'package:ccsga_comments/Models/User.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import '../DatabaseHandler.dart';

class AdminPage extends BasePage {
  AdminPage({Key key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends BaseState<AdminPage> with BasicPage {
  Future<List<User>> admins;
  Future<List<User>> representatives;
  Future<List<User>> bannedUsers;

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

  @override
  Widget body() {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: ListView(
        shrinkWrap: true,
        children: [
          Center(
            child: Text(
              "Admins",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
            ),
          ),
          FutureBuilder<List<User>>(
              future: admins,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  print(snapshot.data[0] ?? "No data");
                  return UserCard(snapshot.data[0]);
                  // return ListView.builder(
                  //     padding: const EdgeInsets.all(8),
                  //     scrollDirection: Axis.vertical,
                  //     shrinkWrap: true,
                  //     itemCount: snapshot.data.length,
                  //     itemBuilder: (BuildContext context, int index) {
                  //     });
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
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
            ),
          ),
          FutureBuilder<List<User>>(
              future: representatives,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  print(snapshot.data[0] ?? "No data");
                  return ListView.builder(
                      padding: const EdgeInsets.all(8),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return UserCard(snapshot.data[index]);
                      });
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
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
            ),
          ),
          FutureBuilder<List<User>>(
              future: bannedUsers,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  print(snapshot.data[0] ?? "No data");
                  return ListView.builder(
                      padding: const EdgeInsets.all(8),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return UserCard(snapshot.data[index]);
                      });
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
      ),
    );
  }

  Future<List<User>> fetchAdmins() async {
    Tuple2<ChewedResponse, Admins> adminsResponse =
        await DatabaseHandler.instance.getAdmins();

    if (adminsResponse.item2 != null) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return adminsResponse.item2.admins;
    } else {
      print('Failed to load admins');
      return [];
    }
  }

  Future<List<User>> fetchRepresentatives() async {
    Tuple2<ChewedResponse, Representatives> repsRepsonse =
        await DatabaseHandler.instance.getRepresentatives();

    if (repsRepsonse.item2 != null) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return repsRepsonse.item2.ccsgaReps;
    } else {
      print('Failed to load representatives');
      return [];
    }
  }

  Future<List<User>> fetchBanned() async {
    Tuple2<ChewedResponse, BannedUsers> bannedUsersResponse =
        await DatabaseHandler.instance.getBannedUsers();

    if (bannedUsersResponse.item2 != null) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return bannedUsersResponse.item2.bannedUsers;
    } else {
      print('Failed to load admins');
      return [];
    }
  }

  // Future<bool> _getAdminPageData() async {
  //   Tuple2<ChewedResponse, Admins> adminsResponse =
  //       await DatabaseHandler.instance.getAdmins();
  //
  //   Tuple2<ChewedResponse, BannedUsers> bannedUsersResponse =
  //       await DatabaseHandler.instance.getBannedUsers();
  //
  //   Tuple2<ChewedResponse, Representatives> repsResponse =
  //       await DatabaseHandler.instance.getRepresentatives();
  //
  //   if (bannedUsersResponse.item2 != null) {
  //     print("bannedUsers response successful");
  //     bannedUsers = bannedUsersResponse.item2.bannedUsers;
  //   } else {
  //     print("bannedUsers response unsuccessful");
  //     return false;
  //   }
  //
  //   if (repsResponse.item2 != null) {
  //     print("representatives response successful");
  //     representatives = repsResponse.item2.ccsgaReps;
  //   } else {
  //     print("representatives response unsuccessful");
  //     return false;
  //   }
  //
  //   if (adminsResponse.item2 != null) {
  //     print("admins response successful");
  //     admins = adminsResponse.item2.admins;
  //     return true;
  //   } else {
  //     print("admins response unsuccessful");
  //     return false;
  //   }
  // }

  @override
  String screenName() {
    return "Admin Controls";
  }

  @override
  Widget fab() {
    return Row(
      children: [
        banUserButton(),
        SizedBox(
          width: 10,
        ),
        promoteNewUserButton(),
      ],
      mainAxisAlignment: MainAxisAlignment.end,
    );
  }

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
}
