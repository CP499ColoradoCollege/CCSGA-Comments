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
      appBar: AppBar(
        title: Text(screenName()),
        centerTitle: true,
      ),
      body: Container(
        child: body(),
      ),
      floatingActionButton: fab(),
      drawer: NavigationDrawer(),
    );
  }

  // Override body to add a body to the page
  Widget body();
  // Override fab to add a floating action button to the page
  Widget fab() => Container();

  Map<String, String> getPathParameters() {
    return Beamer.of(context).currentLocation.pathParameters;
  }
}
