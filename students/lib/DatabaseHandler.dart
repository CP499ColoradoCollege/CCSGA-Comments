import 'package:ccsga_comments/Models/BannedUsers.dart';
import 'package:ccsga_comments/Models/ChewedResponseModel.dart';
import 'package:ccsga_comments/Models/Conversation.dart';
import 'package:ccsga_comments/Models/ConversationUpdate.dart';
import 'package:ccsga_comments/Models/NewAdmin.dart';
import 'package:ccsga_comments/Models/NewRepresentative.dart';
import 'package:ccsga_comments/Models/Representatives.dart';
import 'package:ccsga_comments/Models/UserToBan.dart';
import 'package:tuple/tuple.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'Models/Admins.dart';
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
      'revealIdentity': isAnonymous,
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

  Future<void> updateConversation(
      int conversationId, ConversationUpdate conversationUpdate) async {
    final url = '/api/conversations/$conversationId';
    await http.patch(
      url,
      body: conversationUpdateToJson(conversationUpdate),
      headers: {"Content-Type": "application/json"},
    );
  }

  Future<Tuple2<ChewedResponse, BannedUsers>> getBannedUsers() async {
    final url = '/api/banned_users';
    var response =
        await http.get(url, headers: {"Content-Type": "application/json"});
    var chewedResponse = ChewedResponse();
    chewedResponse.chewStatusCode(response.statusCode);
    // only if the transaction is successful, will there will be a conversation obj in the response
    if (response.statusCode == 200) {
      BannedUsers bannedUsers = BannedUsers.fromJson(jsonDecode(response.body));
      return Tuple2<ChewedResponse, BannedUsers>(chewedResponse, bannedUsers);
    } else {
      return Tuple2<ChewedResponse, BannedUsers>(chewedResponse, null);
    }
  }

  Future<void> addRepresentative(String username) async {
    final url = '/api/ccsga_reps/create';
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(NewRepresentative(newCCSGA: username)));
  }

  Future<void> banUser(String username) async {
    final url = '/api/banned_users/create';
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(UserToBan(userToBan: username)));
  }

  Future<void> addAdmin(String username) async {
    final url = '/api/admins/create';
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(NewAdmin(newAdmin: username)));
  }

  Future<Tuple2<ChewedResponse, Representatives>> getRepresentatives() async {
    final url = '/api/ccsga_reps';
    var response =
        await http.get(url, headers: {"Content-Type": "application/json"});
    var chewedResponse = ChewedResponse();
    chewedResponse.chewStatusCode(response.statusCode);
    // only if the transaction is successful, will there will be a conversation obj in the response
    if (response.statusCode == 200) {
      Representatives reps =
          Representatives.fromJson(jsonDecode(response.body));
      return Tuple2<ChewedResponse, Representatives>(chewedResponse, reps);
    } else {
      return Tuple2<ChewedResponse, Representatives>(chewedResponse, null);
    }
  }

  Future<Tuple2<ChewedResponse, Admins>> getAdmins() async {
    final url = '/api/admins';
    var response =
        await http.get(url, headers: {"Content-Type": "application/json"});
    var chewedResponse = ChewedResponse();
    chewedResponse.chewStatusCode(response.statusCode);
    // only if the transaction is successful, will there will be a conversation obj in the response
    if (response.statusCode == 200) {
      Admins admins = Admins.fromJson(jsonDecode(response.body));
      return Tuple2<ChewedResponse, Admins>(chewedResponse, admins);
    } else {
      return Tuple2<ChewedResponse, Admins>(chewedResponse, null);
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

  Future<ChewedResponse> deleteAdmin(String username) async {
    final url = '/api/admins/' + username;
    var response =
        await http.delete(url, headers: {"Content-Type": "application/json"});
    print(response);
    var chewedResponse = ChewedResponse();
    chewedResponse.chewStatusCode(response.statusCode);
    return chewedResponse;
  }

  Future<ChewedResponse> deleteCCSGA(String username) async {
    final url = '/api/ccsga_reps/' + username;
    var response =
        await http.delete(url, headers: {"Content-Type": "application/json"});
    print(response);
    var chewedResponse = ChewedResponse();
    chewedResponse.chewStatusCode(response.statusCode);
    return chewedResponse;
  }

  Future<ChewedResponse> deleteBannedUser(String username) async {
    final url = '/api/banned_users/' + username;
    var response =
        await http.delete(url, headers: {"Content-Type": "application/json"});
    print(response);
    var chewedResponse = ChewedResponse();
    chewedResponse.chewStatusCode(response.statusCode);
    return chewedResponse;
  }

// WE'LL PROB NOT HAVE THIS ON THE BACKEND
//   // get details of a single message based on ID
//   Future<Tuple2<ChewedResponse, Message>> getMessage(int messageId) async {
//     final url = '/api/conversations/<conversationId>/messages/$messageId';
//     var response =
//         await http.get(url, headers: {"Content-Type": "application/json"});
//     var chewedResponse = ChewedResponse();
//     chewedResponse.chewStatusCode(response.statusCode);
//     if (response.statusCode == 200) {
//       Message msg = Message.fromJson(jsonDecode(response.body));
//       return Tuple2<ChewedResponse, Message>(chewedResponse, msg);
//     } else {
//       return Tuple2<ChewedResponse, Message>(chewedResponse, null);
//     }
//   }
}
