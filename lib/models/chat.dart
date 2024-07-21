import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  String name, photoUrl, lastMessagePhoto, lastMessage;
  Timestamp timestamp;

  Chat(
      {required this.name,
      required this.photoUrl,
      required this.lastMessagePhoto,
      required this.lastMessage,
      required this.timestamp});
}
