import 'package:ccsga_comments/BasePage/BasePage.dart';
import 'package:ccsga_comments/Models/ChewedResponseModel.dart';
import 'package:ccsga_comments/Models/Conversation.dart';
import 'package:ccsga_comments/Models/Message.dart';
import 'package:ccsga_comments/Navigation/CCSGABeamLocations.dart';
import 'package:ccsga_comments/Settings/ConversationListSettingsDrawer.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
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

  List<Conversation> _convList;
  List<ConversationListCard> _convCards = [];

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
              child: FutureBuilder<bool>(
                  future: _getConversationList(),
                  builder:
                      (BuildContext context, AsyncSnapshot<bool> snapshot) {
                    if (snapshot.hasData) {
                      return ListView(
                          padding: const EdgeInsets.all(8),
                          children: _convCards);
                    } else {
                      return CircularProgressIndicator();
                    }
                  })),
        ],
      ),
    );
  }

  Future<bool> _getConversationList() async {
    Tuple2<ChewedResponse, List<Conversation>> responseTuple =
        await DatabaseHandler.instance.getConversationList();
    // print("responseTuple.item2.messages -> ${responseTuple.item2.messages}");
    // transaction successful, there was a conv obj sent in response, otherwise null
    if (responseTuple.item2 != null) {
      // use setState to update the data in the UI with conv
      _convList = responseTuple.item2;

      for (Conversation conv in _convList) {
        String joinedLabels = '';
        for (String label in conv.labels) {
          // print("we're in the label joiner loop!");
          joinedLabels += (" " + label);
        }
        List<String> messageKeys = conv.messages.keys.toList()
          ..sort((a, b) => a.compareTo(b));
        // print("we're after messageKeys!");
        Message mostRecentMessage = conv.messages[messageKeys.last];

        _convCards.add(ConversationListCard(
          joinedLabels: joinedLabels,
          mostRecentMessageBody: mostRecentMessage.body,
          mostRecentMessageDateTime: mostRecentMessage.dateTime,
        ));
      }
      // FutureBuilder requires that we return something
      return true;
    } else {
      setState(() {
        throw new Error();
        // _errorMessage = responseTuple.item1.message;
      });
      return false;
    }
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
    _getConversationList();
    setState(() {});
  }

  void filterConversations(
      FilterByDate date, FilterByLabel label, bool isApartOfConversation) {}
}
