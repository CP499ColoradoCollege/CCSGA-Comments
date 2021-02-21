import 'package:beamer/beamer.dart';
import 'package:ccsga_comments/Admin/AdminPage.dart';
import 'package:ccsga_comments/Home/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:ccsga_comments/ConversationList/ConversationListPage.dart';
import 'package:ccsga_comments/NewMessage/NewMessagePage.dart';
import 'package:ccsga_comments/Conversation/ConversationPage.dart';

const List<String> _homePath = [''];
const List<String> _conversationListPath = ['conversation_list'];
const List<String> _conversationPath = ['conversation/:conversationID'];
const List<String> _newMessagePath = ['new_message'];
const List<String> _adminPath = ['admin_controls'];
const List<String> _loginPath = ['login'];

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
    @required Map<String, String> pathParameters,
  }) : super(
          pathBlueprint: _conversationPath.last,
          pathParameters: pathParameters,
        );

  @override
  List<String> get pathBlueprints => _conversationPath;

  @override
  List<BeamPage> get pages => [
        ...ConversationListLocation().pages,
        BeamPage(
          key: ValueKey('conversation-${pathParameters['id'] ?? ''}'),
          child: ConversationPage(),
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
