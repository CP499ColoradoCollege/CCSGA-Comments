import 'package:flutter/foundation.dart';
import './Message.dart';
import './CommitteeModel.dart';

class ConversationStatus {
  String notSent;
  String sent;
  String read;
  String underConsideration;
  String inProgress;
  String completed;

  ConversationStatus() {
    this.notSent = 'not sent';
    this.sent = 'sent';
    this.read = 'read';
    this.underConsideration = 'under consideration';
    this.inProgress = 'in progress';
    this.completed = 'completed';
  }
}

class Conversation {
  double id;
  String status;
  bool isAnonymous;
  bool isRead;
  List<Message> messages;
  List<String> labels;

  Conversation(this.isAnonymous, this.messages, this.labels) {
    this.status = new ConversationStatus().sent;
  }
}
