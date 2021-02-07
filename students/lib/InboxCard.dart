import 'package:intl/intl.dart';

class InboxCard {
  String name;
  String message;
  String time;

  InboxCard(String name, String message, DateTime time) {
    this.name = name;
    this.message = message;
    this.time = DateFormat("MMM d -").add_jm().format(time);
  }

}