import 'dart:convert';
import 'package:ccsga_comments/Models/User.dart';

/// The functions that it called in the DatabaseHandler on the server response payload
BannedUsers bannedUsersFromJson(String str) =>
    BannedUsers.fromJson(json.decode(str));

String bannedUsersToJson(BannedUsers data) => json.encode(data.toJson());

/// Code generated with https://app.quicktype.io/
/// This class exists to turn database return JSON objects
/// into instances of this class
/// We can then use this data in the frontend
class BannedUsers {
  BannedUsers({
    this.bannedUsers,
  });

  List<User> bannedUsers;

  factory BannedUsers.fromJson(Map<String, dynamic> json) => BannedUsers(
        bannedUsers: json["bannedUsers"] == null
            ? null
            : List<User>.from(json["bannedUsers"].map((x) => User.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "bannedUsers": bannedUsers == null
            ? null
            : List<dynamic>.from(bannedUsers.map((x) => x.toJson())),
      };
}
