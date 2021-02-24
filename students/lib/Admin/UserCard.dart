import 'package:ccsga_comments/DatabaseHandler.dart';
import 'package:ccsga_comments/Models/GlobalEnums.dart';
import 'package:ccsga_comments/Models/User.dart';
import 'package:flutter/material.dart';

class UserCard extends StatefulWidget {
  UserType userType;
  User user;

  @required
  UserCard(this.user, this.userType);

  @override
  _UserCardState createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  @override
  Widget build(BuildContext context) {
    var username = widget.user.username ?? "Null_username";
    return Center(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(7.5),
          leading: Icon(Icons.person_outline),
          title: Text(username),
          trailing: IconButton(
            icon: Icon(Icons.remove_circle_outline),
            color: Colors.red,
            splashColor: Colors.redAccent,
            onPressed: _showMyDialog,
          ),
        ),
      ),
    );
  }

  void removeUser() {
    if (widget.user.username != null) {
      switch (widget.userType) {
        case UserType.Admin:
          DatabaseHandler.instance.deleteAdmin(widget.user.username);
          break;
        case UserType.Representative:
          DatabaseHandler.instance.deleteCCSGA(widget.user.username);
          break;
        case UserType.Student:
          DatabaseHandler.instance.deleteBannedUser(widget.user.username);
          break;
      }
    }
  }

  void _showMyDialog() async {
    User user = widget.user;
    if (user == null) {
      return;
    }
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Remove User"),
          content: Text("Are you sure you would you like to remove the" +
              (user.isAdmin ? " admin: " : " representative: ") +
              user.username +
              "?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Remove"),
              onPressed: () {
                removeUser();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
