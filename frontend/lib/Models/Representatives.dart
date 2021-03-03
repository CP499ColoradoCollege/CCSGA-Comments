import 'dart:convert';
import 'User.dart';

/// The functions that it called in the DatabaseHandler on the server response payload
Representatives representativesFromJson(String str) =>
    Representatives.fromJson(json.decode(str));

String representativesToJson(Representatives data) =>
    json.encode(data.toJson());

/// Code generated with https://app.quicktype.io/
/// This class exists to turn database return JSON objects
/// into instances of this class
/// We can then use this data in the frontend
class Representatives {
  Representatives({
    this.ccsgaReps,
  });

  List<User> ccsgaReps;

  factory Representatives.fromJson(Map<String, dynamic> json) =>
      Representatives(
        ccsgaReps: json["ccsgaReps"] == null
            ? null
            : List<User>.from(json["ccsgaReps"].map((x) => User.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "ccsgaReps": ccsgaReps == null
            ? null
            : List<dynamic>.from(ccsgaReps.map((x) => x.toJson())),
      };
}
