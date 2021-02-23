import 'package:ccsga_comments/Models/ChewedResponseModel.dart';
import 'package:ccsga_comments/Models/Conversation.dart';
import 'package:ccsga_comments/Models/User.dart';
import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';
import 'package:ccsga_comments/Navigation/NavigationDrawer.dart';
import 'package:tuple/tuple.dart';

import '../DatabaseHandler.dart';

//Based on this article: https://medium.com/flutter-community/mixins-and-base-classes-a-recipe-for-success-in-flutter-bc3fbb5da670

abstract class BasePage extends StatefulWidget {
  BasePage({Key key}) : super(key: key);
}

abstract class BaseState<Page extends BasePage> extends State<Page> {
  String screenName();
}

mixin BasicPage<Page extends BasePage> on BaseState<Page> {
  @override
  final GlobalKey<BaseState> scaffoldKey = GlobalKey<BaseState>();
  Future<User> currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = _getUserData();
  }

  Widget build(BuildContext context) {
    List<Widget> bodyChildren = [Expanded(child: body())];

    Widget rightActionButton = Builder(
      builder: (context) => rightButtonIcon != null
          ? IconButton(
              icon: rightButtonIcon,
              onPressed: () => Scaffold.of(context).openEndDrawer())
          : Container(),
    );

    if (isMobileLayout(context) == false) {
      bodyChildren.insert(
          0,
          Container(
            padding: EdgeInsets.only(right: 10),
            child: staticDrawer(),
          ));
      bodyChildren.add(Container(
        padding: EdgeInsets.only(left: 10),
        child: getSettingsDrawer(),
      ));
      rightActionButton = Container();
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(screenName()),
        centerTitle: true,
        leading: Builder(
          builder: (context) => drawerButton(context),
        ),
        actions: [rightActionButton],
      ),
      body: Container(
        child: Row(
          children: bodyChildren,
        ),
      ),
      floatingActionButton: fab(),
      drawer: NavigationDrawer(true),
      endDrawer: settingsDrawer(),
    );
  }

  //Override to add the navigation drawer to the side, will be hidden when screen size too small
  Widget staticDrawer() => Container(
        child: SizedBox(
          width: 275,
          child: NavigationDrawer(false),
        ),
      );
  // Override body to add a body to the page
  Widget body();
  //Override to add the settings drawer to the side, will be hidden when screen size too small
  Widget settingsDrawer() => Container();
  // Override fab to add a floating action button to the page
  Widget fab() => Container();

  Map<String, String> getPathParameters() {
    return Beamer.of(context).currentLocation.pathParameters;
    // Override rightIconButton to add an icon button to the right side of the app bar
  }

  Icon rightButtonIcon;
  Widget drawerButton(BuildContext context) {
    if (isMobileLayout(context) == false) {
      return Container();
    } else {
      return IconButton(
        icon: Icon(Icons.menu),
        onPressed: () => Scaffold.of(context).openDrawer(),
      );
    }
  }

  bool isMobileLayout(BuildContext context) {
    if (MediaQuery.of(context).size.width < 850) {
      return true;
    }
    return false;
  }

  Widget getSettingsDrawer() {
    var drawer = settingsDrawer();
    if (drawer is Container) {
      return Container();
    } else {
      return SizedBox(
        width: 275,
        child: drawer,
      );
    }
  }

  void openEndDrawer() {
    Scaffold.of(scaffoldKey.currentState.context).openEndDrawer();
  }

  Future<User> _getUserData() async {
    Tuple2<ChewedResponse, User> userResponse =
        await DatabaseHandler.instance.getAuthenticatedUser();

    if (userResponse.item2 != null) {
      print("user response successful");
      return userResponse.item2;
    } else {
      throw Exception("Get current user failed");
    }
  }
}
