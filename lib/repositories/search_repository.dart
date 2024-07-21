import 'package:datty/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchRepository {
  final FirebaseFirestore _firestore;

  SearchRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<User> chooseUser(String currentUserId, String selectedUserId, {
    required String name,
    required String photoUrl,
  }) async {
    // Add the currentUserId to selectedUserId's chosenList
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('chosenList')
        .doc(selectedUserId)
        .set({});

    // Add the selectedUserId to currentUserId's chosenList
    await _firestore
        .collection('users')
        .doc(selectedUserId)
        .collection('chosenList')
        .doc(currentUserId)
        .set({});

    // Add the selectedUserId to currentUserId's selectedList
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('selectedList')
        .doc(selectedUserId)
        .set({
      'name': name,
      'photoUrl': photoUrl,
    });

    return getUser(currentUserId);
  }


  Future<User> passUser({
    required String currentUserId,
    required String selectedUserId,
  }) async {
    // Add the currentUserId to selectedUserId's chosenList
    await _firestore
        .collection('users')
        .doc(selectedUserId)
        .collection('chosenList')
        .doc(currentUserId)
        .set({});

    // Add the selectedUserId to currentUserId's chosenList
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('chosenList')
        .doc(selectedUserId)
        .set({});

    return getUser(currentUserId);
  }

  Future<User> getUserInterests(String userId) async {
    DocumentSnapshot<Map<String, dynamic>> userDoc =
    await _firestore.collection('users').doc(userId).get();
    Map<String, dynamic> userData = userDoc.data() ?? {};

    return User(
      uid: userId,
      name: userData['name'] as String? ?? '',
      photo: userData['photoUrl'] as String? ?? '',
      gender: userData['gender'] as String? ?? '',
      interestedIn: userData['interestedIn'] as String? ?? '',
      birthDate: null, // Make sure this matches the type in User model
      age: 0, // Replace with actual age if available
      location: null, // Make sure this matches the type in User model
    );
  }

  Future<List<String>> getChosenList(String userId) async {
    List<String> chosenList = [];
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
    await _firestore.collection('users').doc(userId).collection('chosenList').get();

    for (var doc in querySnapshot.docs) {
      chosenList.add(doc.id);
    }
    return chosenList;
  }

  Future<User> getUser(String userId) async {
    List<String> chosenList = await getChosenList(userId);
    User currentUser = await getUserInterests(userId);

    QuerySnapshot<Map<String, dynamic>> usersSnapshot = await _firestore.collection('users').get();
    for (var userDoc in usersSnapshot.docs) {
      Map<String, dynamic> userData = userDoc.data();

      if (!chosenList.contains(userDoc.id) &&
          userDoc.id != userId &&
          currentUser.interestedIn == userData['gender'] &&
          userData['interestedIn'] == currentUser.gender) {
        return User(
          uid: userDoc.id,
          name: userData['name'] as String? ?? '',
          photo: userData['photoUrl'] as String? ?? '',
          age: userData['age'] as int? ?? 0,
          location: userData['location'] as String? ?? '',
          gender: userData['gender'] as String? ?? '',
          interestedIn: userData['interestedIn'] as String? ?? '',
          birthDate: null, // Make sure this matches the type in User model
        );
      }
    }

    // Return a default User if no match is found
    return User(
      uid: '',
      name: 'No Match',
      photo: '',
      age: 0,
      location: '',
      gender: '',
      interestedIn: '',
      birthDate: null, // Make sure this matches the type in User model
    );
  }
}
