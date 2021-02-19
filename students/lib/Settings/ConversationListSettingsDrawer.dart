import 'package:flutter/material.dart';

enum _FilterBy {
  DateDescending,
  DateAscending,
}

class ConversationListSettingsDrawer extends StatefulWidget {
  _ConversationListSettingsDrawerState createState() =>
      _ConversationListSettingsDrawerState();
}

class _ConversationListSettingsDrawerState
    extends State<ConversationListSettingsDrawer> {
  _FilterBy sortByDropDownValue = _FilterBy.DateDescending;

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
          Padding(
            padding: EdgeInsets.all(10),
            child: DropdownButton<_FilterBy>(
              value: sortByDropDownValue,
              icon: Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              underline: Container(
                height: 2,
                color: Theme.of(context).accentColor,
              ),
              onChanged: (_FilterBy newValue) {
                setState(() {
                  sortByDropDownValue = newValue;
                });
              },
              items: [
                DropdownMenuItem(
                  child: Text("Date Descending"),
                  value: _FilterBy.DateDescending,
                ),
                DropdownMenuItem(
                  child: Text("Date Ascending"),
                  value: _FilterBy.DateAscending,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
