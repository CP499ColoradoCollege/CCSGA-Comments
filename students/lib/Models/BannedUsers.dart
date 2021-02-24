import 'dart:convert';
import 'package:ccsga_comments/Models/User.dart';

BannedUsers bannedUsersFromJson(String str) =>
    BannedUsers.fromJson(json.decode(str));

String bannedUsersToJson(BannedUsers data) => json.encode(data.toJson());

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
