import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderName;
  final String selectedUserId;
  final Timestamp timestamp;
  final String? text;
  final String? photoUrl;
  final File? photo;

  Message({
    required this.senderId,
    required this.senderName,
    required this.selectedUserId,
    required this.timestamp,
    this.text,
    this.photoUrl,
    this.photo, required String id, required String receiverId,
  });
}