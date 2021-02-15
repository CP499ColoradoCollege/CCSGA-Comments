import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeCard extends StatelessWidget {
  String title;
  String body;
  String url;

  @required
  HomeCard(String title, String body, [String url = '']) {
    this.title = title;
    this.body = body;
    this.url = url;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {
            cardTapped();
          },
          child: Container(
              padding: EdgeInsets.all(7.5),
              child: ListTile(
                leading: Icon(Icons.announcement_outlined),
                title: Text(title),
                subtitle: Text(body),
                trailing: Icon(Icons.chevron_right_rounded),
              ))),
    ));
  }

  void cardTapped() async {
    if (url != '' && await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
