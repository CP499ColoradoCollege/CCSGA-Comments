import 'dart:convert';

/// The functions that it called in the DatabaseHandler on the server response payload
User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

/// Code generated with https://app.quicktype.io/
/// This class exists to turn database return JSON objects
/// into instances of this class
/// We can then use this data in the frontend
class User {
  User({
    this.isSignedIn,
    this.username,
    this.displayName,
    this.isBanned,
    this.isCcsga,
    this.isAdmin,
  });

  bool isSignedIn;
  String username;
  String displayName;
  bool isBanned;
  bool isCcsga;
  bool isAdmin;

  factory User.fromJson(Map<String, dynamic> json) => User(
        isSignedIn: json["isSignedIn"] == null ? null : json["isSignedIn"],
        username: json["username"] == null ? null : json["username"],
        displayName: json["displayName"] == null ? null : json["displayName"],
        isBanned: json["isBanned"] == null ? null : json["isBanned"],
        isCcsga: json["isCCSGA"] == null ? null : json["isCCSGA"],
        isAdmin: json["isAdmin"] == null ? null : json["isAdmin"],
      );

  Map<String, dynamic> toJson() => {
        "isSignedIn": isSignedIn == null ? null : isSignedIn,
        "username": username == null ? null : username,
        "displayName": displayName == null ? null : displayName,
        "isBanned": isBanned == null ? null : isBanned,
        "isCCSGA": isCcsga == null ? null : isCcsga,
        "isAdmin": isAdmin == null ? null : isAdmin,
      };
}
