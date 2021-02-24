import 'dart:convert';
import 'User.dart';

Admins adminsFromJson(String str) => Admins.fromJson(json.decode(str));

String adminsToJson(Admins data) => json.encode(data.toJson());

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
