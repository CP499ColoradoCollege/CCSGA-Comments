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
        conversationList.add(conversation);
      });
      return Tuple2<ChewedResponse, List<Conversation>>(
          chewedResponse, conversationList);
    } else {
      return Tuple2<ChewedResponse, List<Conversation>>(chewedResponse, null);
    }
  }

  /// Send a new message to the db, starting a conversation
  ///
  /// Send new message data to the backend, where [labels]
  /// is the list of committee labels.
  /// ChewedResponse is used to digest the status code and
  /// translate it into an isSuccessful bool and an error message
  Future<Tuple2<ChewedResponse, String>> initiateNewConversation(
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
    return Tuple2(chewedResponse, response.body);
  }

  /// Send a message in an existing conversation (as a reply)
  ///
  /// [conversationId] is important to know which conversation
  /// the reply should be appended to
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

  /// Get messages and other details of a single conversation
  ///
  /// Conversation.fromJson turns the return JSON into a Conversation obj
  /// Errorhandling: if response is not 200, status code and
  /// corresponding error message are thrown as Exception
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
      throw Exception(response.statusCode);
    }
  }

  /// Get messages and other details of a single conversation, deanonymized
  ///
  /// Conversation.fromJson turns the return JSON into a Conversation obj
  /// Errorhandling: if response is not 200, status code and
  /// corresponding error message are thrown as Exception
  Future<Tuple2<ChewedResponse, Conversation>> getConversationDeanonymized(
      int conversationId) async {
    final url = '/api/conversations/$conversationId?overrideAnonymity=true';
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
      throw Exception(
          "Error. Status code: ${response.statusCode}, Message: ${chewedResponse.message}");
    }
  }

  /// Updates attribute(s) of an existing conversation
  /// (if setting status, archiving deanonymizing etc)
  Future<void> updateConversation(
      int conversationId, ConversationUpdate conversationUpdate) async {
    final url = '/api/conversations/$conversationId';
    await http.patch(
      url,
      body: conversationUpdateToJson(conversationUpdate),
      headers: {"Content-Type": "application/json"},
    );
  }

  /// Gets list of banned users
  ///
  /// Returns a tuple with metadata about the response and the payload
  /// If the status code is not 200, the payload in the return tuple will be null
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

  /// Promote a user to CCSGA type based on [username]
  Future<void> addRepresentative(String username) async {
    final url = '/api/ccsga_reps/create';
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(NewRepresentative(newCCSGA: username)));
  }

  /// Add a user to the list of banned users,
  /// stripping them of access to the site
  Future<void> banUser(String username) async {
    final url = '/api/banned_users/create';
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(UserToBan(userToBan: username)));
  }

  /// Promote a user to Admin type based on [username]
  Future<void> addAdmin(String username) async {
    final url = '/api/admins/create';
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(NewAdmin(newAdmin: username)));
  }

  /// Get current list of CCSGA type users stored in the database
  ///
  /// Returns a tuple with metadata about the response and the payload
  /// If the status code is not 200, the payload in the return tuple will be null
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

  /// Get current list of Admin type users stored in the database
  ///
  /// Returns a tuple with metadata about the response and the payload
  /// If the status code is not 200, the payload in the return tuple will be null
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

  /// Get messages and other details of a single conversation
  ///
  /// If stataus code is not 200, an exception is thrown with
  /// the status code and likely corresponding error message
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
      throw Exception(response.statusCode);
    }
  }

  /// Demote an Admin user and take away their Admin privileges
  Future<ChewedResponse> deleteAdmin(String username) async {
    final url = '/api/admins/' + username;
    var response =
        await http.delete(url, headers: {"Content-Type": "application/json"});
    var chewedResponse = ChewedResponse();
    chewedResponse.chewStatusCode(response.statusCode);
    return chewedResponse;
  }

  /// Demote a CCSGA user and take away their CCSGA privileges
  Future<ChewedResponse> deleteCCSGA(String username) async {
    final url = '/api/ccsga_reps/' + username;
    var response =
        await http.delete(url, headers: {"Content-Type": "application/json"});
    var chewedResponse = ChewedResponse();
    chewedResponse.chewStatusCode(response.statusCode);
    return chewedResponse;
  }

  /// Unban a user, removing them from the list of banned users
  Future<ChewedResponse> deleteBannedUser(String username) async {
    final url = '/api/banned_users/' + username;
    var response =
        await http.delete(url, headers: {"Content-Type": "application/json"});
    var chewedResponse = ChewedResponse();
    chewedResponse.chewStatusCode(response.statusCode);
    return chewedResponse;
  }
}
