import 'package:ccsga_comments/Models/ChewedResponseModel.dart';
import 'package:ccsga_comments/Models/Conversation.dart';
import 'package:tuple/tuple.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'Models/User.dart';

class DatabaseHandler {
  // Singleton setup. To get the single instance of this class, use the getter: `DatabaseHandler.instance`
  DatabaseHandler._privateConstructor(); // Makes the only constructor private
  static final DatabaseHandler _instance = DatabaseHandler
      ._privateConstructor(); // A private, static instance of this class
  static DatabaseHandler get instance => _instance; // the getter

  // get all my conversations from the database
  Future<Tuple2<ChewedResponse, List<Conversation>>>
      getConversationList() async {
    final url = '/api/conversations';
    var response =
        await http.get(url, headers: {"Content-Type": "application/json"});
    ChewedResponse chewedResponse =
        ChewedResponse(statusCode: response.statusCode);
    if (response.statusCode == 200) {
      //we need a conv list here somehow
      Map<String, dynamic> jsonConvsMap = jsonDecode(response.body);
      List<Conversation> conversationList = [];
      jsonConvsMap.forEach((id, conv) {
        Conversation conversation = Conversation.fromJson(conv);
        conversation.id = int.parse(id);
        conversationList.add(Conversation.fromJson(conv));
      });
      return Tuple2<ChewedResponse, List<Conversation>>(
          chewedResponse, conversationList);
    } else {
      return Tuple2<ChewedResponse, List<Conversation>>(chewedResponse, null);
    }
  }

  // send a new message to the db, starting a conversation
  Future<ChewedResponse> initiateNewConversation(
      bool isAnonymous, String messageBody, List<String> labels) async {
    final url = '/api/conversations/create';
    var newMessageAttributes = {
      'revealIdentity': !isAnonymous,
      'messageBody': messageBody,
      'labels': labels
    };
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(newMessageAttributes));
    var chewedResponse = ChewedResponse(
        message: "Message Sent Successfully!", statusCode: response.statusCode);
    return chewedResponse;
  }

  // send a message in an existing conversation (as a reply)
  Future<ChewedResponse> sendMessageInConversation(
      int conversationId, String messageBody) async {
    final url = '/api/conversations/$conversationId/messages/create';
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"messageBody": messageBody}));
    var chewedResponse = ChewedResponse(
        message: "Message Sent Successfully!", statusCode: response.statusCode);
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
    // only if the transaction is successful, will there will be a conversation obj in the response
    if (response.statusCode == 200) {
      Conversation conv = Conversation.fromJson(jsonDecode(response.body));
      // the conv id comes from the request, not from the response
      conv.id = conversationId;
      return Tuple2<ChewedResponse, Conversation>(chewedResponse, conv);
    } else {
      return Tuple2<ChewedResponse, Conversation>(chewedResponse, null);
    }
  }

  // get messages and other details of a single conversation
  Future<Tuple2<ChewedResponse, User>> getAuthenticatedUser() async {
    final url = '/api/authenticate';
    var response =
        await http.get(url, headers: {"Content-Type": "application/json"});
    var chewedResponse = ChewedResponse();
    chewedResponse.chewStatusCode(response.statusCode);
    // only if the transaction is successful, will there will be a conversation obj in the response
    if (response.statusCode == 200) {
      User user = User.fromJson(jsonDecode(response.body));
      return Tuple2<ChewedResponse, User>(chewedResponse, user);
    } else {
      return Tuple2<ChewedResponse, User>(chewedResponse, null);
    }
  }
}
