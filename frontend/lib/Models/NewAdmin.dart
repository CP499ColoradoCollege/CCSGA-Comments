import 'dart:convert';

/// The functions that it called in the DatabaseHandler on the server response payload
NewAdmin newAdminFromJson(String str) => NewAdmin.fromJson(json.decode(str));

String newAdminToJson(NewAdmin data) => json.encode(data.toJson());

/// Code generated with https://app.quicktype.io/
/// This class exists to turn database return JSON objects
/// into instances of this class
/// We can then use this data in the frontend
class NewAdmin {
  NewAdmin({
    this.newAdmin,
  });

  String newAdmin;

  factory NewAdmin.fromJson(Map<String, dynamic> json) =>
      NewAdmin(newAdmin: json["newAdmin"] == null ? null : json["newAdmin"]);

  Map<String, dynamic> toJson() =>
      {"newAdmin": newAdmin == null ? null : newAdmin};
}
