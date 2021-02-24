import 'dart:convert';
import 'User.dart';

Representatives representativesFromJson(String str) =>
    Representatives.fromJson(json.decode(str));

String representativesToJson(Representatives data) =>
    json.encode(data.toJson());

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
