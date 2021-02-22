import 'dart:convert';
import 'User.dart';

Admins adminsFromJson(String str) => Admins.fromJson(json.decode(str));

String adminsToJson(Admins data) => json.encode(data.toJson());

class Admins {
  Admins({
    this.admins,
  });

  List<User> admins;

  factory Admins.fromJson(Map<String, dynamic> json) =>
      Admins(admins: json["admins"] == null ? null : json["admins"]);

  Map<String, dynamic> toJson() => {"admins": admins == null ? null : admins};
}
