import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';
import 'Navigation/CCSGABeamLocations.dart';
import 'package:url_strategy/url_strategy.dart';

void main() {
  // setPathUrlStrategy();
  runApp(CCSGACommentsApp());
}

class CCSGACommentsApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: BeamerRouterDelegate(
        initialLocation: HomeLocation(),
        notFoundPage: Scaffold(body: Center(child: Text('Not found'))),
      ),
      routeInformationParser: BeamerRouteInformationParser(
        beamLocations: [
          HomeLocation(),
          ConversationListLocation(),
          NewMessageLocation(),
          ConversationLocation(),
        ],
      ),
      title: 'CCSGA Comments',
      theme: ThemeData(primarySwatch: Colors.amber),
      debugShowCheckedModeBanner: false,
    );
  }
}
