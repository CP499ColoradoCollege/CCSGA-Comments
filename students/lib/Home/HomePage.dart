import 'dart:html';

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
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10),
            child: Text(
              'Announcements',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ),
          //Announcements Grid
          GridView.extent(
              maxCrossAxisExtent: 800.0,
              crossAxisSpacing: 5.0,
              childAspectRatio: 6,
              shrinkWrap: true,
              children: <Widget>[
                HomeCard(
                    'CC Academic Calendar',
                    'See the academic calendar here...',
                    'https://www.coloradocollege.edu/academics/curriculum/calendar/calendar-2020-21.html/'),
                HomeCard(
                    'COVID-19 Guidelines',
                    'Learn more about the community guidelines here...',
                    'https://www.coloradocollege.edu/other/coronavirus/'),
                HomeCard('CCSGA Announcement', 'Midnight rasties!!!')
              ]),
          Container(
            padding: EdgeInsets.all(10),
            child: Text(
              'About Us',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ),
          //Our Mission Card
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Colors.amberAccent),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                      color: Colors.amberAccent[700]),
                  child: ListTile(
                    leading: new IconTheme(
                      data: new IconThemeData(color: Colors.white),
                      child: new Icon(Icons.local_police_outlined),
                    ),
                    title: Text(
                      "Our Mission",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  child: Text(
                      "The Colorado College Student Government Association (CCSGA) is comprised of members democratically elected by the Colorado College student body. CCSGA gives students a crucial role in the campus-wide development of an enriching college experience. CCSGA strives to make life at Colorado College not only intellectual, but also enjoyable and meaningful. In addition to being a source of support for student organizations and events, CCSGA is also a forum for cooperative action and provides a voice calling for progress. CCSGA is dedicated to the improvement of Colorado College and is driven by the passion and determination of its students."),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  String screenName() {
    return "Home";
  }
}
