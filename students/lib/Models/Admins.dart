import 'dart:convert';

Admins adminsFromJson(String str) => Admins.fromJson(json.decode(str));

String adminsToJson(Admins data) => json.encode(data.toJson());

class Admins {
  Admins({
    this.admins,
  });

  List<Admin> admins;

  factory Admins.fromJson(Map<String, dynamic> json) => Admins(
        admins: json["admins"] == null
            ? null
            : List<Admin>.from(json["admins"].map((x) => Admin.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "admins": admins == null
            ? null
            : List<dynamic>.from(admins.map((x) => x.toJson())),
      };
}

class Admin {
  Admin({
    this.displayName,
    this.isAdmin,
    this.isBanned,
    this.isCcsga,
    this.username,
  });

  String displayName;
  bool isAdmin;
  bool isBanned;
  bool isCcsga;
  String username;

  factory Admin.fromJson(Map<String, dynamic> json) => Admin(
        displayName: json["displayName"] == null ? null : json["displayName"],
        isAdmin: json["isAdmin"] == null ? null : json["isAdmin"],
        isBanned: json["isBanned"] == null ? null : json["isBanned"],
        isCcsga: json["isCCSGA"] == null ? null : json["isCCSGA"],
        username: json["username"] == null ? null : json["username"],
      );

  Map<String, dynamic> toJson() => {
        "displayName": displayName == null ? null : displayName,
        "isAdmin": isAdmin == null ? null : isAdmin,
        "isBanned": isBanned == null ? null : isBanned,
        "isCCSGA": isCcsga == null ? null : isCcsga,
        "username": username == null ? null : username,
      };
}
