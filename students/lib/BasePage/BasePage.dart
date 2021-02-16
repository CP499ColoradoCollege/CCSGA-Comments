import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';
import 'package:ccsga_comments/Navigation/NavigationDrawer.dart';

//Based on this article: https://medium.com/flutter-community/mixins-and-base-classes-a-recipe-for-success-in-flutter-bc3fbb5da670

abstract class BasePage extends StatefulWidget {
  BasePage({Key key}) : super(key: key);
}

abstract class BaseState<Page extends BasePage> extends State<Page> {
  String screenName();
}

mixin BasicPage<Page extends BasePage> on BaseState<Page> {
  @override
  Widget build(BuildContext context) {
    List<Widget> bodyChildren = [Expanded(child: body())];

    if (isMobileLayout(context) == false) {
      bodyChildren.insert(
          0,
          Container(
            padding: EdgeInsets.only(right: 10),
            child: staticDrawer(),
          ));
      bodyChildren.add(Container(
        padding: EdgeInsets.only(left: 10),
        child: settingsDrawer(),
      ));
    }

    return Scaffold(
      appBar: AppBar(
          title: Text(screenName()),
          centerTitle: true,
          leading: Builder(
            builder: (context) => drawerButton(context),
          )),
      body: Container(
        child: Row(
          children: bodyChildren,
        ),
      ),
      floatingActionButton: fab(),
      drawer: NavigationDrawer(true),
    );
  }

  //Override to add the navigation drawer to the side, will be hidden when screen size too small
  Widget staticDrawer() => Container(
        child: SizedBox(
          width: 200,
          child: NavigationDrawer(false),
        ),
      );
  // Override body to add a body to the page
  Widget body();
  //Override to add the settings drawer to the side, will be hidden when screen size too small
  Widget settingsDrawer() => Container(
        child: SizedBox(
          width: 200,
          child: Container(
            color: Colors.blue,
          ),
        ),
      );
  // Override fab to add a floating action button to the page
  Widget fab() => Container();

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
    if (MediaQuery.of(context).size.width < 800) {
      return true;
    }
    return false;
  }
}
