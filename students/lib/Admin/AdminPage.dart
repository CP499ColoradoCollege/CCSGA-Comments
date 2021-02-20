import 'package:ccsga_comments/Admin/UserCard.dart';
import 'package:ccsga_comments/BasePage/BasePage.dart';
import 'package:ccsga_comments/Models/User.dart';
import 'package:flutter/material.dart';

class AdminPage extends BasePage {
  AdminPage({Key key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends BaseState<AdminPage> with BasicPage {
  List<User> admins = [];
  List<User> representatives = [];

  @override
  Widget body() {
    getUsers();

    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Column(
        children: [
          Text(
            "Admins",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
          ),
          ListView.builder(
              padding: const EdgeInsets.all(8),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: admins.length,
              itemBuilder: (BuildContext context, int index) {
                return UserCard(admins[index]);
              }),
          Text(
            "Representatives",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
          ),
          ListView.builder(
              padding: const EdgeInsets.all(8),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: representatives.length,
              itemBuilder: (BuildContext context, int index) {
                return UserCard(representatives[index]);
              }),
        ],
      ),
    );
  }

  @override
  String screenName() {
    return "Admin Controls";
  }

  @override
  Widget fab() {
    return FloatingActionButton.extended(
      onPressed: () {
        promoteUser();
      },
      label: Text('Promote New User'),
      icon: Icon(Icons.upgrade),
      backgroundColor: Theme.of(context).accentColor,
    );
  }

  TextEditingController _textEditingController = TextEditingController();
  String _promoteUserDropdownValue = "rep";

  void promoteUser() async {
    DropdownButton dropdownButton = DropdownButton(
        value: _promoteUserDropdownValue,
        items: [
          DropdownMenuItem(
            child: Text("Representative"),
            value: "rep",
          ),
          DropdownMenuItem(
            child: Text("Admin"),
            value: "admin",
          ),
        ],
        onChanged: (value) {
          setState(() {
            _promoteUserDropdownValue = value;
          });
        });

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Promote New User"),
          content: Column(
            children: [
              Text("Please select the role you wish to promote the user to:"),
              dropdownButton,
              Text("Please enter the email address of the user:"),
              TextField(
                controller: _textEditingController,
                decoration: InputDecoration(
                  labelText: 'Write a message',
                  labelStyle: TextStyle(color: Colors.black),
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                ),
              )
            ],
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Continue"),
              onPressed: () {
                bool isAdmin = dropdownButton.value == "admin" ? true : false;
                String email = _textEditingController.text;
                //TODO ADD USER TO BACKEND HERE
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void getUsers() async {
    //TODO Add async get admins and reps
    admins = [
      User(
          displayName: "Sam",
          isAdmin: true,
          isBanned: false,
          isCcsga: false,
          isSignedIn: false,
          notSignedIn: false,
          username: "admin1"),
      User(
          displayName: "Ely",
          isAdmin: true,
          isBanned: false,
          isCcsga: false,
          isSignedIn: false,
          notSignedIn: false,
          username: "admin2"),
      User(
          displayName: "Viktor",
          isAdmin: true,
          isBanned: false,
          isCcsga: false,
          isSignedIn: false,
          notSignedIn: false,
          username: "admin3"),
    ];

    representatives = [
      User(
          displayName: "Fer",
          isAdmin: true,
          isBanned: false,
          isCcsga: false,
          isSignedIn: false,
          notSignedIn: false,
          username: "rep1"),
      User(
          displayName: "Sarah",
          isAdmin: true,
          isBanned: false,
          isCcsga: false,
          isSignedIn: false,
          notSignedIn: false,
          username: "rep2"),
    ];
  }
}
