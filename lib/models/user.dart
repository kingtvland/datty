import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String name;
  final String photo;
  final int age;
  final dynamic location;  // Change this to GeoPoint if that's what you're using
  final String gender;
  final String interestedIn;
  final Timestamp? birthDate;  // Make this nullable

  User({
    required this.uid,
    required this.name,
    required this.photo,
    required this.age,
    required this.location,
    required this.gender,
    required this.interestedIn,
    this.birthDate,  // Make this optional
  });
}