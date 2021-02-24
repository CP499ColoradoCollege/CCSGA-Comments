import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:beamer/beamer.dart';
import 'Navigation/CCSGABeamLocations.dart';
import 'dart:io';
import 'package:url_strategy/url_strategy.dart';

//This is our main function. It is used to start our app.
void main() {
  //setPathUrlStrategy removes the # from the default build url
  setPathUrlStrategy();
  runApp(CCSGACommentsApp());
}

class CCSGACommentsApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: BeamerRouterDelegate(
        //Default starting location in the web app
        initialLocation: HomeLocation(),
        notFoundPage: Scaffold(body: Center(child: Text('Not found'))),
      ),
      routeInformationParser: BeamerRouteInformationParser(
        //All the navigable pages of our app, predefined so Beamer can expect them.
        beamLocations: [
          HomeLocation(),
          ConversationListLocation(),
          NewMessageLocation(),
          ConversationLocation(),
          AdminLocation(),
          LogoutLocation(),
        ],
      ),
      title: 'CCSGA Comments',
      theme: ThemeData(primarySwatch: Colors.amber),
      debugShowCheckedModeBanner: false,
    );
  }
}
