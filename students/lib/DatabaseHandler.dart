import 'package:firebase/firebase.dart'; // for web
// import 'package:firebase_core/firebase_core.dart'; // for mobile
// import 'package:firebase_database/firebase_database.dart'; // for mobile
import 'InboxCard.dart';

class DatabaseHandler {
  
  // The Database instance variable used for database calls
  final Database db = database();

  // Singleton setup. To get the single instance of this class, use the getter: `DatabaseHandler.instance`
  DatabaseHandler._privateConstructor(); // Makes the only constructor private
  static final DatabaseHandler _instance = DatabaseHandler._privateConstructor(); // A private, static instance of this class
  static DatabaseHandler get instance => _instance; // the getter

  // get all the messages from the database, or all of a user's messages if a username is provided
  Future<List<InboxCard>> getMessages({var username}) async {
    DatabaseReference ref;
    List<InboxCard> messages = [];
    if (username == null){
      ref = db.ref("messages");
      var queryEvent = await ref.once("value");
      DataSnapshot allMessagesSnapshot = queryEvent.snapshot;
      allMessagesSnapshot.forEach((userMessagesSnapshot) {
        userMessagesSnapshot.forEach((messageSnapshot){
          Map<String, dynamic> message = messageSnapshot.val();
          messages.add(new InboxCard(message["display_name"], message["body"], DateTime.parse(message["time"])));
        });
      });
      return messages;
    }else{
      ref = db.ref("messages/$username");
      var queryEvent = await ref.once("value");
      DataSnapshot messagesSnapshot = queryEvent.snapshot;
      messagesSnapshot.forEach((messageSnapshot) {
        Map<String, dynamic> message = messageSnapshot.val();
        messages.add(new InboxCard(message["display_name"], message["body"], DateTime.parse(message["time"])));
      });
      return messages;
    }
  }
}
