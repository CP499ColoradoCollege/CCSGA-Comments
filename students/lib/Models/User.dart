import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  User({
    this.isSignedIn,
    this.username,
    this.notSignedIn,
    this.displayName,
    this.isBanned,
    this.isCcsga,
    this.isAdmin,
  });

  bool isSignedIn;
  String username;
  bool notSignedIn;
  String displayName;
  bool isBanned;
  bool isCcsga;
  bool isAdmin;

  factory User.fromJson(Map<String, dynamic> json) => User(
        isSignedIn: json["isSignedIn"],
        username: json["username"],
        notSignedIn: json["not_signed_in"],
        displayName: json["displayName"],
        isBanned: json["isBanned"],
        isCcsga: json["isCCSGA"],
        isAdmin: json["isAdmin"],
      );

  Map<String, dynamic> toJson() => {
        "isSignedIn": isSignedIn,
        "username": username,
        "not_signed_in": notSignedIn,
        "displayName": displayName,
        "isBanned": isBanned,
        "isCCSGA": isCcsga,
        "isAdmin": isAdmin,
      };
}
