import 'package:beamer/beamer.dart';
import 'package:ccsga_comments/Admin/AdminPage.dart';
import 'package:ccsga_comments/Home/HomePage.dart';
import 'package:ccsga_comments/Logout/LogoutPage.dart';
import 'package:flutter/material.dart';
import 'package:ccsga_comments/ConversationList/ConversationListPage.dart';
import 'package:ccsga_comments/NewMessage/NewMessagePage.dart';
import 'package:ccsga_comments/Conversation/ConversationPage.dart';

const List<String> _homePath = [''];
const List<String> _conversationListPath = ['conversation_list'];
const List<String> _conversationPath = ['conversation/:conversationId'];
const List<String> _newMessagePath = ['new_message'];
const List<String> _adminPath = ['admin_controls'];
const List<String> _logoutPath = ['logout'];

class HomeLocation extends BeamLocation {
  HomeLocation() {
    pathSegments = _homePath;
  }
  @override
  List<String> get pathBlueprints => _homePath;

  @override
  List<BeamPage> get pages => [
        BeamPage(
          key: ValueKey('home'),
          child: HomePage(),
        ),
      ];
}

class LogoutLocation extends BeamLocation {
  LogoutLocation() {
    pathSegments = _logoutPath;
  }
  @override
  List<String> get pathBlueprints => _logoutPath;

  @override
  List<BeamPage> get pages => [
        BeamPage(
          key: ValueKey('logout'),
          child: LogoutPage(),
        ),
      ];
}

class AdminLocation extends BeamLocation {
  AdminLocation() {
    pathSegments = _adminPath;
  }
  @override
  List<String> get pathBlueprints => _adminPath;

  @override
  List<BeamPage> get pages => [
        BeamPage(
          key: ValueKey('admin'),
          child: AdminPage(),
        ),
      ];
}

class ConversationListLocation extends BeamLocation {
  ConversationListLocation() {
    pathSegments = _conversationListPath;
  }
  @override
  List<String> get pathBlueprints => _conversationListPath;

  @override
  List<BeamPage> get pages => [
        BeamPage(
          key: ValueKey('conversation_list'),
          child: ConversationListPage(),
        ),
      ];
}

class ConversationLocation extends BeamLocation {
  ConversationLocation({
    Map<String, String> pathParameters,
  }) : super(
          pathParameters: pathParameters,
        );

  @override
  List<String> get pathBlueprints => _conversationPath;

  @override
  List<BeamPage> get pages => [
        ...ConversationListLocation().pages,
        BeamPage(
          key: ValueKey(
              'conversation/${pathParameters['conversationId'] ?? ''}'),
          child: ConversationPage(
              conversationId: int.parse(pathParameters['conversationId'] ?? 0)),
        )
      ];
}

class NewMessageLocation extends BeamLocation {
  NewMessageLocation() {
    pathSegments = _newMessagePath;
  }

  @override
  List<String> get pathBlueprints => _newMessagePath;

  @override
  List<BeamPage> get pages => [
        BeamPage(
          key: ValueKey('new_message'),
          child: NewMessagePage(),
        ),
      ];
}
