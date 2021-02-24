import 'dart:convert';

NewRepresentative newRepresentativeFromJson(String str) =>
    NewRepresentative.fromJson(json.decode(str));

String newRepresentativeToJson(NewRepresentative data) =>
    json.encode(data.toJson());

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
