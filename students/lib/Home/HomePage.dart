import 'package:ccsga_comments/BasePage/BasePage.dart';
import 'package:flutter/material.dart';
import 'HomeCard.dart';

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
      padding: EdgeInsets.all(10),
      child: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 3.0,
          padding: const EdgeInsets.all(4.0),
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
          children: <Widget>[
            HomeCard('CC Academic Calendar', 'See the academic calendar here...', 'https://www.coloradocollege.edu/academics/curriculum/calendar/calendar-2020-21.html/'),
            HomeCard('COVID-19 Guidelines', 'Learn more about the community guidelines here...', 'https://www.coloradocollege.edu/other/coronavirus/'),
            HomeCard('CCSGA Announcement', 'Midnight rasties!!!')
            ]
      ),
    );
  }

  @override
  String screenName() {
    return "Home";
  }
}
