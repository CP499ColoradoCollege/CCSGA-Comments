import 'package:ccsga_comments/Admin/UserCard.dart';
import 'package:ccsga_comments/BasePage/BasePage.dart';
import 'package:ccsga_comments/Models/Admins.dart';
import 'package:ccsga_comments/Models/BannedUsers.dart';
import 'package:ccsga_comments/Models/ChewedResponseModel.dart';
import 'package:ccsga_comments/Models/GlobalEnums.dart';
import 'package:ccsga_comments/Models/Representatives.dart';
import 'package:ccsga_comments/Models/User.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import '../DatabaseHandler.dart';

class LogoutPage extends BasePage {
  LogoutPage({Key key}) : super(key: key);

  @override
  _LogoutPageState createState() => _LogoutPageState();
}

class _LogoutPageState extends BaseState<LogoutPage> with BasicPage {
  @override
  Widget body() {
    return Center(
      child: Text("You have been successfully logged out..."),
    );
  }

  @override
  String screenName() {
    return "Logout";
  }

  @override
  Widget navigationDrawer() {
    return Container();
  }

  @override
  Widget staticDrawer() {
    return Container();
  }
}
