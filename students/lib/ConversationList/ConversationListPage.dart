import 'package:ccsga_comments/BasePage/BasePage.dart';
import 'package:ccsga_comments/Navigation/CCSGABeamLocations.dart';
import 'package:ccsga_comments/Settings/ConversationListSettingsDrawer.dart';
import 'package:flutter/material.dart';
import 'ConversationListCard.dart';
import 'package:ccsga_comments/DatabaseHandler.dart';
import 'package:beamer/beamer.dart';
import 'package:ccsga_comments/Models/FilterEnums.dart';

class ConversationListPage extends BasePage {
  ConversationListPage({Key key, this.title}) : super(key: key);

  final String title;

  _ConversationListPageState createState() => _ConversationListPageState();
}

class _ConversationListPageState extends BaseState<ConversationListPage>
    with BasicPage {
  @override
  String screenName() {
    return "Conversations";
  }

  List<ConversationListCard> _conversations = [];

  Widget body() {
    return Center(
      child: Stack(
        children: [
          Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  "Pull to refresh",
                  style: TextStyle(color: Colors.grey[400]),
                ),
              )),
          RefreshIndicator(
            onRefresh: _pullRefresh,
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: _conversations,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget fab() {
    return FloatingActionButton.extended(
      onPressed: () {
        _newMessage();
      },
      label: Text('New Message'),
      icon: Icon(Icons.add),
      backgroundColor: Theme.of(context).accentColor,
    );
  }

  @override
  Widget settingsDrawer() {
    return ConversationListSettingsDrawer(
      filterCallback: filterConversations,
    );
  }

  @override
  Icon get rightButtonIcon => Icon(Icons.filter_alt_outlined);

  void _filterDrawerButtonPressed() {
    print("open end drawer");
  }

  void _newMessage() {
    context.beamTo(NewMessageLocation());
  }

  Future<void> _pullRefresh() async {
    // DatabaseHandler dbHandler = DatabaseHandler.instance;
    // dbHandler.getMessages().then((messages) {
    //   setState(() {
    //     _messages = [...messages];
    //   });
    // }).catchError((err) => print("Caught an error: $err"));
  }

  void filterConversations(
      FilterByDate date, FilterByLabel label, bool isApartOfConversation) {}
}
