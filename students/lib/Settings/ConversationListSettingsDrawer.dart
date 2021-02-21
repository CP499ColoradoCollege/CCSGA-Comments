import 'package:ccsga_comments/ConversationList/ConversationListPage.dart';
import 'package:flutter/material.dart';
import 'package:ccsga_comments/Models/FilterEnums.dart';

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
  FilterByDate sortByDateValue = FilterByDate.DateDescending;
  FilterByLabel sortByLabelValue = FilterByLabel.All;
  bool isApartOfConversation = true;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Center(
              child: Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              "Conversations Filter",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          )),
          CheckboxListTile(
            title: const Text('My Conversations'),
            value: isApartOfConversation,
            onChanged: (bool value) {
              setState(() {
                isApartOfConversation = value;
                widget.filterCallback(
                    sortByDateValue, sortByLabelValue, isApartOfConversation);
              });
            },
            // secondary: const Icon(Icons.add_comment_outlined),
          ),
          Padding(
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
                  widget.filterCallback(
                      sortByDateValue, sortByLabelValue, isApartOfConversation);
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
          ),
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
                  widget.filterCallback(
                      sortByDateValue, sortByLabelValue, isApartOfConversation);
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
      ),
    );
  }
}
