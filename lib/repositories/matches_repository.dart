// File: lib/repositories/matches_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class MatchesRepository {
  final FirebaseFirestore _firestore;

  MatchesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<QuerySnapshot> getMatchedList(String userId) {
    return _firestore.collection('matches')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  Stream<QuerySnapshot> getSelectedList(String userId) {
    return _firestore.collection('selected')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  Future<void> deleteUser(String currentUserId, String selectedUserId) async {
    final batch = _firestore.batch();

    final matchDoc = _firestore.collection('matches')
        .doc(currentUserId)
        .collection('matchedUsers')
        .doc(selectedUserId);

    final selectedDoc = _firestore.collection('selected')
        .doc(currentUserId)
        .collection('selectedUsers')
        .doc(selectedUserId);

    batch.delete(matchDoc);
    batch.delete(selectedDoc);

    await batch.commit();
  }

  Future<void> openChat({required String currentUserId, required String selectedUserId}) async {
    await _firestore.collection('chats')
        .add({
      'participants': [currentUserId, selectedUserId],
      'createdAt': FieldValue.serverTimestamp()
    });
  }

  Future<void> selectUser(
      String currentUserId,
      String selectedUserId,
      String currentUserName,
      String currentUserPhotoUrl,
      String selectedUserName,
      String selectedUserPhotoUrl
      ) async {
    await _firestore.collection('selected').add({
      'currentUserId': currentUserId,
      'selectedUserId': selectedUserId,
      'currentUserName': currentUserName,
      'currentUserPhotoUrl': currentUserPhotoUrl,
      'selectedUserName': selectedUserName,
      'selectedUserPhotoUrl': selectedUserPhotoUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  getUserDetails(String id) {}
}
