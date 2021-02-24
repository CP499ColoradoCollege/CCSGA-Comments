import 'dart:convert';

/// The functions that it called in the DatabaseHandler on the server response payload
ConversationUpdate conversationUpdateFromJson(String str) =>
    ConversationUpdate.fromJson(json.decode(str));

String conversationUpdateToJson(ConversationUpdate data) =>
    json.encode(data.toJson());

/// Code generated with https://app.quicktype.io/
/// This class exists to turn database return JSON objects
/// into instances of this class
/// We can then use this data in the frontend
class ConversationUpdate {
  ConversationUpdate({
    this.revealIdentity,
    this.setArchived,
    this.setStatus,
    this.setLabels,
    this.setRead,
  });

  bool revealIdentity;
  bool setArchived;
  String setStatus;
  List<String> setLabels;
  bool setRead;

  factory ConversationUpdate.fromJson(Map<String, dynamic> json) =>
      ConversationUpdate(
        revealIdentity:
            json["revealIdentity"] == null ? null : json["revealIdentity"],
        setArchived: json["setArchived"] == null ? null : json["setArchived"],
        setStatus: json["setStatus"] == null ? null : json["setStatus"],
        setLabels: json["setLabels"] == null
            ? null
            : List<String>.from(json["setLabels"].map((x) => x)),
        setRead: json["setRead"] == null ? null : json["setRead"],
      );

  Map<String, dynamic> toJson() => {
        "revealIdentity": revealIdentity == null ? null : revealIdentity,
        "setArchived": setArchived == null ? null : setArchived,
        "setStatus": setStatus == null ? null : setStatus,
        "setLabels": setLabels == null
            ? null
            : List<dynamic>.from(setLabels.map((x) => x)),
        "setRead": setRead == null ? null : setRead,
      };
}
