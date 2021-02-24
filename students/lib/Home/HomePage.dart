import 'dart:html';

import 'package:ccsga_comments/BasePage/BasePage.dart';
import 'package:flutter/material.dart';
import 'HomeCard.dart';

/// Page class for the hompage
///
/// Currently holds static HomeCards, not updatable through the UI
/// In future, functionality should be added
class HomePage extends BasePage {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends BaseState<HomePage> with BasicPage {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget body() {
    return Container(
      child: Column(
        children: <Widget>[
          GridView.extent(
              maxCrossAxisExtent: 800.0,
              crossAxisSpacing: 5.0,
              childAspectRatio: 6,
              shrinkWrap: true,
              children: <Widget>[
                HomeCard(
                    'CC Academic Calendar 2021-2022',
                    'See the academic calendar here...',
                    'https://www.coloradocollege.edu/academics/curriculum/calendar/calendar-2021-22.html'),
                HomeCard(
                    'COVID-19 Guidelines',
                    'Learn more about the community guidelines here...',
                    'https://www.coloradocollege.edu/other/coronavirus/'),
                HomeCard('CCSGA Announcement', 'Midnight rasties!!!')
              ]),
        ],
      ),
    );
  }

  @override
  String screenName() {
    return "Home";
  }
}
