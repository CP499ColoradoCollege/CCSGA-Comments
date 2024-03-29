import 'package:ccsga_comments/BasePage/BasePage.dart';
import 'package:ccsga_comments/Models/ChewedResponseModel.dart';
import 'package:ccsga_comments/Models/Conversation.dart';
import 'package:ccsga_comments/Models/Message.dart';
import 'package:ccsga_comments/Navigation/CCSGABeamLocations.dart';
import 'package:ccsga_comments/Settings/ConversationListSettingsDrawer.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import '../DatabaseHandler.dart';
import 'ConversationListCard.dart';
import 'package:beamer/beamer.dart';
import 'package:ccsga_comments/Models/GlobalEnums.dart';

/// Class for the page showing the list of conversations that -
/// if Student: I have initiated
/// if CCSGA or Admin: students have sent to CCSGA (all)
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

  /// list of conversation cards that will be displayed on the page
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
                    if (snapshot.hasError){
                      String exceptionString = snapshot.error.toString();
                      String errorMessage;
                      switch(exceptionString.substring(exceptionString.length - 3)){
                        case "401":
                          errorMessage = "You are not signed in. Please refresh the page.";
                          break;
                        case "403":
                          errorMessage = "You are currently banned from this site. Please email CCSGA if you believe this is a mistake.";
                          break;
                        default:
                          errorMessage = "Something went wrong. Refreshing the page may help.";
                      }
                      return Center(
                        child: SizedBox(
                          width: 200,
                          height: 200,
                          child: Text(errorMessage),
                        ),
                      );
                    }else if (snapshot.hasData) {
                      return ListView(
                          padding: const EdgeInsets.all(8),
                          children: _convCards);
                    } else {
                      return Center(
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                  })),
        ],
      ),
    );
  }

  /// Gets the list of conversations that I should see
  /// based on my username and user type
  ///
  /// Throws error if unsuccessful.
  /// Is called within the body() so gets run onInit()
  /// and when seteState() is called
  Future<bool> _getConversationList() async {
    Tuple2<ChewedResponse, List<Conversation>> responseTuple =
        await DatabaseHandler.instance.getConversationList();
    // transaction successful, there was a conv obj sent in response, otherwise null
    if (responseTuple.item2 != null) {
      // use setState to update the data in the UI with conv
      buildConversationCards(responseTuple.item2);
      // FutureBuilder requires that we return something
      return true;
    } else {
      setState(() {
        throw new Exception(responseTuple.item1.statusCode);
      });
      return false;
    }
  }

  /// ConversationCards need to digest some of the
  /// data that a conversation holds, this method
  /// does just that
  void buildConversationCards(convList) {
    _convCards.clear();
    for (Conversation conv in convList) {
      String joinedLabels = '';
      for (String label in conv.labels) {
        joinedLabels += (" " + label);
      }
      //these are the message IDs
      List<String> messageKeys = conv.messages.keys.toList()
        ..sort((a, b) => a.compareTo(b));
      Message mostRecentMessage = conv.messages[messageKeys.last];
      _convCards.add(ConversationListCard(
        convId: conv.id,
        joinedLabels: joinedLabels,
        mostRecentMessageBody: mostRecentMessage.body,
        mostRecentMessageDateTime: mostRecentMessage.dateTime,
        conversationCallback: beamToConversation,
      ));
    }
  }

  /// Used as callback so we can open
  /// the conversation page when a
  /// conversation card is clicked
  void beamToConversation(int id) {
    context.beamTo(ConversationLocation(
        pathParameters: {"conversationId": id.toString()}));
  }

  /// The New Message button
  ///
  /// Takes user to the new_message page
  @override
  Widget fab() {
    return FutureBuilder<bool>(
      future: _getConversationList(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if(snapshot.hasData){
          return FloatingActionButton.extended(
            onPressed: () {
              _newMessage();
            },
            label: Text('New Message'),
            icon: Icon(Icons.add),
            backgroundColor: Theme.of(context).accentColor,
          );
        }else{ // error (such as banned user), or hasn't loaded yet
          return null;
        }
    });
  }

  // Future functionality, for filter, sort, search
  // @override
  // Widget settingsDrawer() {
  //   return ConversationListSettingsDrawer(
  //     filterCallback: filterConversations,
  //   );
  // }

  // @override
  // Icon get rightButtonIcon => Icon(Icons.filter_alt_outlined);

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
