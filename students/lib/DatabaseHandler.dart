//import 'package:firebase/firebase.dart'; // for web
// import 'package:firebase_core/firebase_core.dart'; // for mobile
// import 'package:firebase_database/firebase_database.dart'; // for mobile
import 'package:ccsga_comments/NewMessage/ChewedResponseModel.dart';
import 'package:ccsga_comments/NewMessage/Conversation.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

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

  // WIP
  // get all my conversations from the database
  // Future<Tuple2<ChewedResponse, List<Conversation>>>
  //     getConversationList() async {
  //   final url = '/api/conversations';
  //   var response =
  //       await http.get(url, headers: {"Content-Type": "application/json"});
  //   var chewedResponse = ChewedResponse();
  //   chewedResponse.chewStatusCode(response.statusCode);
  //   if (response.statusCode == 200) {
  //     //we need a conv list here somehow
  //     //another class for a ConvList? loop through JSON attr and fromJson them all?
  //     List<Conversation> convList =
  //         Conversation.fromJson(jsonDecode(response.body));
  //   }
  //   // PLACEHOLDER, replace with ^^ when figured out
  //   List<Conversation> conversationList = [Conversation()];
  //   return Tuple2<ChewedResponse, List<Conversation>>(
  //       chewedResponse, conversationList);
  // }

  // send a new message to the db, starting a conversation
  Future<ChewedResponse> initiateNewConversation(
      bool isAnonymous, String messageBody, List<String> labels) async {
    final url = '/api/conversations/create';
    var newMessageAttributes = {
      'revealIdentity': isAnonymous,
      'messageBody': messageBody,
      'labels': labels
    };
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(newMessageAttributes));
    var chewedResponse =
        ChewedResponse(null, "Message Sent Successfully!", response.statusCode);
    return chewedResponse;
  }

  // send a message in an existing conversation (as a reply)
  Future<ChewedResponse> sendMessageInConversation(
      int conversationId, String messageBody) async {
    final url = '/api/conversations/$conversationId/messages/create';
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"messageBody": messageBody}));
    var chewedResponse =
        ChewedResponse(null, "Message Sent Successfully!", response.statusCode);
    return chewedResponse;
  }

  // get messages and other details of a single conversation
  Future<Tuple2<ChewedResponse, Conversation>> getConversation(
      int conversationId) async {
    final url = '/api/conversations/$conversationId';
    var response =
        await http.get(url, headers: {"Content-Type": "application/json"});
    var chewedResponse = ChewedResponse();
    chewedResponse.chewStatusCode(response.statusCode);
    if (response.statusCode == 200) {
      Conversation conv = Conversation.fromJson(jsonDecode(response.body));
      return Tuple2<ChewedResponse, Conversation>(chewedResponse, conv);
    } else {
      return Tuple2<ChewedResponse, Conversation>(chewedResponse, null);
    }
  }

  // get details of a single message based on ID
  Future<Tuple2<ChewedResponse, Message>> getMessage(int messageId) async {
    final url = '/api/conversations/<conversationId>/messages/$messageId';
    var response =
        await http.get(url, headers: {"Content-Type": "application/json"});
    var chewedResponse = ChewedResponse();
    chewedResponse.chewStatusCode(response.statusCode);
    if (response.statusCode == 200) {
      Message msg = Message.fromJson(jsonDecode(response.body));
      return Tuple2<ChewedResponse, Message>(chewedResponse, msg);
    } else {
      return Tuple2<ChewedResponse, Message>(chewedResponse, null);
    }
  }
}
