import 'dart:convert';
import 'User.dart';

BannedUsers adminsFromJson(String str) =>
    BannedUsers.fromJson(json.decode(str));

String adminsToJson(BannedUsers data) => json.encode(data.toJson());

class BannedUsers {
  BannedUsers({
    this.bannedUsers,
  });

  List<User> bannedUsers;

  factory BannedUsers.fromJson(Map<String, dynamic> json) => BannedUsers(
      bannedUsers: json["bannedUsers"] == null ? null : json["bannedUsers"]);

  Map<String, dynamic> toJson() =>
      {"bannedUsers": bannedUsers == null ? null : bannedUsers};
}
