import 'dart:convert';

/// The functions that it called in the DatabaseHandler on the server response payload
NewRepresentative newRepresentativeFromJson(String str) =>
    NewRepresentative.fromJson(json.decode(str));

String newRepresentativeToJson(NewRepresentative data) =>
    json.encode(data.toJson());

/// Code generated with https://app.quicktype.io/
/// This class exists to turn database return JSON objects
/// into instances of this class
/// We can then use this data in the frontend
class NewRepresentative {
  NewRepresentative({
    this.newCCSGA,
  });

  String newCCSGA;

  factory NewRepresentative.fromJson(Map<String, dynamic> json) =>
      NewRepresentative(
          newCCSGA: json["newCCSGA"] == null ? null : json["newCCSGA"]);

  Map<String, dynamic> toJson() =>
      {"newCCSGA": newCCSGA == null ? null : newCCSGA};
}
