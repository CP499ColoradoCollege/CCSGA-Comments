import 'dart:convert';

NewAdmin newAdminFromJson(String str) => NewAdmin.fromJson(json.decode(str));

String newAdminToJson(NewAdmin data) => json.encode(data.toJson());

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
