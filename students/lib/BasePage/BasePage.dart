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
    return Scaffold(
      appBar:
          AppBar(title: Center(child: Text(screenName())), actions: <Widget>[
        new IconTheme(
          data: new IconThemeData(
            color: Colors.white,
          ),
          child: new IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            tooltip: 'Filter Messages',
            onPressed: () {
              _filterMessages();
            },
          ),
        )
      ]),
      body: Container(
        child: body(),
        //This will be the system wide background color
        color: Colors.white,
      ),
      floatingActionButton: fab(),
      drawer: NavigationDrawer(),
    );
  }

  // Override body to add a body to the page
  Widget body();
  // Override fab to add a floating action button to the page
  Widget fab() => Container();

  void _filterMessages() {
    print("Filter messages");
  }
}
