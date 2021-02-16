import 'dart:convert';

Map<String, Message> messageFromJson(String str) => Map.from(json.decode(str))
    .map((k, v) => MapEntry<String, Message>(k, Message.fromJson(v)));

String messageToJson(Map<String, Message> data) => json.encode(
    Map.from(data).map((k, v) => MapEntry<String, dynamic>(k, v.toJson())));

class Message {
  Message({
    this.body,
    this.dateTime,
    this.isRead,
    this.sender,
  });

  String body;
  String dateTime;
  bool isRead;
  Sender sender;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        body: json["body"],
        dateTime: json["dateTime"],
        isRead: json["isRead"],
        sender: Sender.fromJson(json["sender"]),
      );

  Map<String, dynamic> toJson() => {
        "body": body,
        "dateTime": dateTime,
        "isRead": isRead,
        "sender": sender.toJson(),
      };
}

class Sender {
  Sender({
    this.displayName,
    this.username,
  });

  String displayName;
  String username;

  factory Sender.fromJson(Map<String, dynamic> json) => Sender(
        displayName: json["displayName"],
        username: json["username"],
      );

  Map<String, dynamic> toJson() => {
        "displayName": displayName,
        "username": username,
      };
}
