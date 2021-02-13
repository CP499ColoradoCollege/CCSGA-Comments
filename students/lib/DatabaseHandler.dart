//import 'package:firebase/firebase.dart'; // for web
// import 'package:firebase_core/firebase_core.dart'; // for mobile
// import 'package:firebase_database/firebase_database.dart'; // for mobile
import 'package:ccsga_comments/NewMessage/ChewedResponseModel.dart';
import 'package:ccsga_comments/NewMessage/Conversation.dart';
import 'package:flutter/material.dart';

import 'Inbox/InboxCard.dart';
import 'package:http/http.dart' as http;
import 'NewMessage/Message.dart';
import 'dart:convert';

class DatabaseHandler {
  // The Database instance variable used for database calls
  //final Database db = database();

  // Singleton setup. To get the single instance of this class, use the getter: `DatabaseHandler.instance`
  DatabaseHandler._privateConstructor(); // Makes the only constructor private
  static final DatabaseHandler _instance = DatabaseHandler
      ._privateConstructor(); // A private, static instance of this class
  static DatabaseHandler get instance => _instance; // the getter

  // get all the messages from the database, or all of a user's messages if a username is provided
  Future<List<InboxCard>> getMessages({var username}) async {
    //DatabaseReference ref;
    List<InboxCard> messages = [];
    if (username == null) {
    } else {
      return messages;
    }
  }

  // send a new message to the db, starting a conversation
  Future<ChewedResponse> initiateNewConversation(
      bool isAnonymous, String messageBody, List<String> labels) async {
    var url = '/api/conversations/create';
    var newMessageAttributes = {
      'revealIdentity': isAnonymous,
      'messageBody': messageBody,
      'labels': labels
    };
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(newMessageAttributes));
    if (response.statusCode == 201) {
      return new ChewedResponse(true, 'Message Sent Successfully');
    } else if (response.statusCode == 401) {
      return new ChewedResponse(
          false, 'You cannot send a message unless you are signed in');
    } else if (response.statusCode == 403) {
      return new ChewedResponse(false,
          'If you are signed in with a CCSGA account, you cannot initiate a conversation \nOtherwise, your account may have been banned. Please contact the Administrator');
    } else {
      return new ChewedResponse(false,
          'Failed to send your message. Error code: ${response.statusCode}');
    }
  }
}
