import 'dart:convert';

Admins userFromJson(String str) => Admins.fromJson(json.decode(str));

String userToJson(Admins data) => json.encode(data.toJson());

class Admins {
  Admins({
    this.admins,
  });

  List<String> admins;

  factory Admins.fromJson(Map<String, dynamic> json) =>
      Admins(admins: json["admins"] == null ? null : json["admins"]);

  Map<String, dynamic> toJson() => {"admins": admins == null ? null : admins};
}
