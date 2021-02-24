import 'package:ccsga_comments/ConversationList/ConversationListPage.dart';
import 'package:ccsga_comments/Models/ChewedResponseModel.dart';
import 'package:ccsga_comments/Models/User.dart';
import 'package:flutter/material.dart';
import 'package:ccsga_comments/Models/GlobalEnums.dart';
import 'package:tuple/tuple.dart';

import '../DatabaseHandler.dart';

/// This drawer is for CCSG and Admin users only
/// Contains filters, sort and should in future contain search
/// This page is hidden at this time (Feb 2021) as above features
/// are not yet implemented
class ConversationListSettingsDrawer extends StatefulWidget {
  Function(FilterByDate date, FilterByLabel label, bool isApartOfConversation)
      filterCallback;

  @required
  ConversationListSettingsDrawer({Key key, this.filterCallback})
      : super(key: key);

  _ConversationListSettingsDrawerState createState() =>
      _ConversationListSettingsDrawerState();
}

class _ConversationListSettingsDrawerState
    extends State<ConversationListSettingsDrawer> {
  User currentUser;
  FilterByDate sortByDateValue = FilterByDate.DateDescending;
  FilterByLabel sortByLabelValue = FilterByLabel.All;
  bool isApartOfConversation = true;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<bool>(
          future: _getUserData(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.hasData) {
              return ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  Center(
                      child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Conversations Filter",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  )),
                  currentUser.isCcsga
                      ? CheckboxListTile(
                          title: const Text('My Conversations'),
                          value: isApartOfConversation,
                          onChanged: (bool value) {
                            setState(() {
                              isApartOfConversation = value;
                              widget.filterCallback(sortByDateValue,
                                  sortByLabelValue, isApartOfConversation);
                            });
                          },
                          // secondary: const Icon(Icons.add_comment_outlined),
                        )
                      : Container(),
                  currentUser.isCcsga
                      ? Padding(
                          padding: EdgeInsets.all(10),
                          child: DropdownButton<FilterByLabel>(
                            value: sortByLabelValue,
                            icon: Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            underline: Container(
                              height: 2,
                              color: Theme.of(context).accentColor,
                            ),
                            onChanged: (FilterByLabel newValue) {
                              setState(() {
                                sortByLabelValue = newValue;
                                widget.filterCallback(sortByDateValue,
                                    sortByLabelValue, isApartOfConversation);
                              });
                            },
                            items: [
                              DropdownMenuItem(
                                child: Text("All Committees"),
                                value: FilterByLabel.All,
                              ),
                              DropdownMenuItem(
                                child: Text("Internal Affairs"),
                                value: FilterByLabel.InternalAffairs,
                              ),
                              DropdownMenuItem(
                                child: Text("Outreach"),
                                value: FilterByLabel.Outreach,
                              ),
                              DropdownMenuItem(
                                child: Text("Diversity and Inclusion"),
                                value: FilterByLabel.DiversityAndInclusion,
                              ),
                            ],
                          ),
                        )
                      : Container(),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: DropdownButton<FilterByDate>(
                      value: sortByDateValue,
                      icon: Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      underline: Container(
                        height: 2,
                        color: Theme.of(context).accentColor,
                      ),
                      onChanged: (FilterByDate newValue) {
                        setState(() {
                          sortByDateValue = newValue;
                          widget.filterCallback(sortByDateValue,
                              sortByLabelValue, isApartOfConversation);
                        });
                      },
                      items: [
                        DropdownMenuItem(
                          child: Text("Date Descending"),
                          value: FilterByDate.DateDescending,
                        ),
                        DropdownMenuItem(
                          child: Text("Date Ascending"),
                          value: FilterByDate.DateAscending,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return Flexible(
                child: Center(
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }
          }),
    );
  }

  Future<bool> _getUserData() async {
    Tuple2<ChewedResponse, User> userResponse = await DatabaseHandler.instance
        .getAuthenticatedUser()
        .catchError(handleError);
    if (userResponse.item2 != null) {
      currentUser = userResponse.item2;
      return true;
    } else {
      return false;
    }
  }

  handleError(e) {
    print(e.toString());
  }
}
