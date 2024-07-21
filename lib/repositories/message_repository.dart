import 'package:datty/models/message.dart';
import 'package:datty/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageRepository {
  final FirebaseFirestore _firestore;

  MessageRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> getChats({required String userId}) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> deleteChat({required String currentUserId, required String selectedUserId}) async {
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('chats')
        .doc(selectedUserId)
        .delete();
  }

  Future<User> getUserDetail({required String userId}) async {
    DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore.collection('users').doc(userId).get();
    Map<String, dynamic> userData = userDoc.data() ?? {};

    return User(
      uid: userDoc.id,
      name: userData['name'] ?? '',
      photo: userData['photoUrl'] ?? '',
      age: userData['age'] ?? 0,
      location: userData['location'],  // This should be a GeoPoint if that's what you're using
      gender: userData['gender'] ?? '',
      interestedIn: userData['interestedIn'] ?? '',
      birthDate: userData['birthDate'] as Timestamp?,  // Use the birthDate from Firestore if available
    );
  }

  Future<Message> getLastMessage({required String currentUserId, required String selectedUserId}) async {
    QuerySnapshot<Map<String, dynamic>> messageSnapshot = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('chats')
        .doc(selectedUserId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (messageSnapshot.docs.isNotEmpty) {
      DocumentSnapshot<Map<String, dynamic>> lastMessageDoc = await _firestore
          .collection('messages')
          .doc(messageSnapshot.docs.first.id)
          .get();

      Map<String, dynamic> messageData = lastMessageDoc.data() ?? {};
      return Message(
        text: messageData['text'] as String?,
        photoUrl: messageData['photoUrl'] as String?,
        timestamp: messageData['timestamp'] as Timestamp? ?? Timestamp.now(),
        senderId: messageData['senderId'] as String? ?? '',
        senderName: messageData['senderName'] as String? ?? '',
        selectedUserId: selectedUserId, id: '', receiverId: '',
      );
    }

    return Message(
      senderId: '',
      senderName: '',
      selectedUserId: selectedUserId,
      timestamp: Timestamp.now(),
      text: '',
      photoUrl: '', id: '', receiverId: '',
    );
  }
}
