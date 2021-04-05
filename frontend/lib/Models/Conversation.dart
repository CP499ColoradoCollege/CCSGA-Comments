import 'dart:convert';
import './Message.dart';

/// The functions that it called in the DatabaseHandler on the server response payload
Conversation conversationFromJson(String str) =>
    Conversation.fromJson(json.decode(str));

String conversationToJson(Conversation data) => json.encode(data.toJson());

/// Code generated with https://app.quicktype.io/
/// This class exists to turn database return JSON objects
/// into instances of this class
/// We can then use this data in the frontend
class Conversation {
  Conversation({
    this.id,
    this.messages,
    this.status,
    this.labels,
    this.isArchived,
    this.allIdentitiesRevealed,
    this.ownIdentityRevealed,
    this.isRead,
  });

  int id;
  Map<String, Message> messages;
  String status;
  List<String> labels;
  bool isArchived;
  bool allIdentitiesRevealed;
  bool ownIdentityRevealed;
  bool isRead;

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
        messages: json["messages"] == null
            ? null
            : Map.from(json["messages"]).map(
                (k, v) => MapEntry<String, Message>(k, Message.fromJson(v))),
        status: json["status"] == null ? null : json["status"],
        labels: json["labels"] == null
            ? null
            : List<String>.from(json["labels"].map((x) => x)),
        isArchived: json["isArchived"] == null ? null : json["isArchived"],
        allIdentitiesRevealed: json["allIdentitiesRevealed"] == null
            ? null
            : json["allIdentitiesRevealed"],
        ownIdentityRevealed: json["ownIdentityRevealed"] == null
            ? null
            : json["ownIdentityRevealed"],
        isRead: json["isRead"] == null ? null : json["isRead"],
      );

  Map<String, dynamic> toJson() => {
        "messages": messages == null
            ? null
            : Map.from(messages)
                .map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
        "status": status == null ? null : status,
        "labels":
            labels == null ? null : List<dynamic>.from(labels.map((x) => x)),
        "isArchived": isArchived == null ? null : isArchived,
        "allIdentitiesRevealed":
            allIdentitiesRevealed == null ? null : allIdentitiesRevealed,
        "ownIdentityRevealed":
            ownIdentityRevealed == null ? null : ownIdentityRevealed,
        "isRead": isRead == null ? null : isRead,
      };
}
