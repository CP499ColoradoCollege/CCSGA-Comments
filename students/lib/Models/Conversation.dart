import 'dart:convert';
import './Message.dart';

Conversation conversationFromJson(String str) =>
    Conversation.fromJson(json.decode(str));

String conversationToJson(Conversation data) => json.encode(data.toJson());

class Conversation {
  Conversation({
    this.id,
    this.messages,
    this.status,
    this.labels,
    this.isArchived,
    this.studentIdentityRevealed,
    this.isRead,
  });

  int id;
  Map<String, Message> messages;
  String status;
  List<String> labels;
  bool isArchived;
  bool studentIdentityRevealed;
  bool isRead;

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
        messages: Map.from(json["messages"])
            .map((k, v) => MapEntry<String, Message>(k, Message.fromJson(v))),
        status: json["status"],
        labels: List<String>.from(json["labels"].map((x) => x)),
        isArchived: json["isArchived"],
        studentIdentityRevealed: json["studentIdentityRevealed"],
        isRead: json["isRead"],
      );

  Map<String, dynamic> toJson() => {
        "messages": Map.from(messages)
            .map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
        "status": status,
        "labels": List<dynamic>.from(labels.map((x) => x)),
        "isArchived": isArchived,
        "studentIdentityRevealed": studentIdentityRevealed,
        "isRead": isRead,
      };
}
