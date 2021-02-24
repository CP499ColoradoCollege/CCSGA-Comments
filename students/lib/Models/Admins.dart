import 'dart:convert';
import 'User.dart';

/// The functions that it called in the DatabaseHandler on the server response payload
Admins adminsFromJson(String str) => Admins.fromJson(json.decode(str));

String adminsToJson(Admins data) => json.encode(data.toJson());

/// Code generated with https://app.quicktype.io/
/// This class exists to turn database return JSON objects
/// into instances of this class
/// We can then use this data in the frontend
class Admins {
  Admins({
    this.admins,
  });

  List<User> admins;

  factory Admins.fromJson(Map<String, dynamic> json) => Admins(
        admins: json["admins"] == null
            ? null
            : List<User>.from(json["admins"].map((x) => User.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "admins": admins == null
            ? null
            : List<dynamic>.from(admins.map((x) => x.toJson())),
      };
}
