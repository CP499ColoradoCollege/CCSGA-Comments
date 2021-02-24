import 'dart:convert';

/// The functions that it called in the DatabaseHandler on the server response payload
UserToBan userToBanFromJson(String str) => UserToBan.fromJson(json.decode(str));

String userToBanToJson(UserToBan data) => json.encode(data.toJson());

/// Code generated with https://app.quicktype.io/
/// This class exists to turn database return JSON objects
/// into instances of this class
/// We can then use this data in the frontend
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
