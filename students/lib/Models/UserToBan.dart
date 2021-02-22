import 'dart:convert';

UserToBan userToBanFromJson(String str) => UserToBan.fromJson(json.decode(str));

String userToBanToJson(UserToBan data) => json.encode(data.toJson());

class UserToBan {
  UserToBan({
    this.userToBan,
  });

  String userToBan;

  factory UserToBan.fromJson(Map<String, dynamic> json) => UserToBan(
      userToBan: json["userToBan"] == null ? null : json["userToBan"]);

  Map<String, dynamic> toJson() =>
      {"userToBan": userToBan == null ? null : userToBan};
}
