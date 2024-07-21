import 'package:datty/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class MessagingRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _firebaseStorage;
  final String uuid = const Uuid().v4();

  MessagingRepository({
    FirebaseStorage? firebaseStorage,
    FirebaseFirestore? firestore,
  })  : _firebaseStorage = firebaseStorage ?? FirebaseStorage.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> sendMessage({required Message message}) async {
    DocumentReference messageRef = _firestore.collection('messages').doc();
    CollectionReference senderRef = _firestore
        .collection('users')
        .doc(message.senderId)
        .collection('chats')
        .doc(message.selectedUserId)
        .collection('messages');

    CollectionReference sendUserRef = _firestore
        .collection('users')
        .doc(message.selectedUserId)
        .collection('chats')
        .doc(message.senderId)
        .collection('messages');

    if (message.photo != null) {
      Reference photoRef = _firebaseStorage
          .ref()
          .child('messages')
          .child(messageRef.id)
          .child(uuid);

      UploadTask uploadTask = photoRef.putFile(message.photo!);

      await uploadTask.whenComplete(() async {
        String photoUrl = await photoRef.getDownloadURL();
        await messageRef.set({
          'senderName': message.senderName,
          'senderId': message.senderId,
          'text': null,
          'photoUrl': photoUrl,
          'timestamp': FieldValue.serverTimestamp(), // Use Firestore's server timestamp
        });

        senderRef.doc(messageRef.id).set({
          'timestamp': FieldValue.serverTimestamp(),
          'photoUrl': photoUrl,
        });

        sendUserRef.doc(messageRef.id).set({
          'timestamp': FieldValue.serverTimestamp(),
          'photoUrl': photoUrl,
        });

        await _updateChatTimestamp(
          senderId: message.senderId,
          selectedUserId: message.selectedUserId,
        );
      });
    } else {
      await messageRef.set({
      'senderName': message.senderName,
      'senderId': message.senderId,
      'text': message.text,
      'photoUrl': null,
      'timestamp': FieldValue.serverTimestamp(), // Use Firestore's server timestamp
    });
    }

    senderRef.doc(messageRef.id).set({
      'timestamp': FieldValue.serverTimestamp(),
      'text': message.text,
    });

    sendUserRef.doc(messageRef.id).set({
      'timestamp': FieldValue.serverTimestamp(),
      'text': message.text,
    });

    await _updateChatTimestamp(
      senderId: message.senderId,
      selectedUserId: message.selectedUserId,
    );

  }

  Future<void> _updateChatTimestamp({
    required String senderId,
    required String selectedUserId,
  }) async {
    await _firestore.collection('users').doc(senderId).collection('chats').doc(selectedUserId).update({
      'timestamp': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('users').doc(selectedUserId).collection('chats').doc(senderId).update({
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages({
    required String currentUserId,
    required String selectedUserId,
  }) {
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('chats')
        .doc(selectedUserId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }


  Future<Message> getMessageDetail({
    required String messageId,
  }) async {
    DocumentSnapshot messageDoc = await _firestore.collection('messages').doc(messageId).get();

    Map<String, dynamic> messageData = messageDoc.data() as Map<String, dynamic>;

    return Message(
      senderId: messageData['senderId'] as String? ?? '',
      senderName: messageData['senderName'] as String? ?? '',
      selectedUserId: '', // You might want to update this based on your requirements
      timestamp: (messageData['timestamp'] as Timestamp?) ?? Timestamp.now(),
      text: messageData['text'] as String?,
      photoUrl: messageData['photoUrl'] as String?, id: '', receiverId: '',
    );
  }
}