import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id;
  String username;
  String email;
  String photoUrl;
  String displayName;
  String bio;
  bool hasSquated;
  num amountDonated;
  int squatCount;
  final String locality;
  final String country;
  final Timestamp lastSquatTime;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.photoUrl,
    required this.displayName,
    required this.bio,
    required this.hasSquated,
    required this.amountDonated,
    required this.squatCount,
    required this.locality,
    required this.country,
    required this.lastSquatTime,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc['id'],
      email: doc['email'],
      username: doc['username'],
      photoUrl: doc['photoUrl'],
      displayName: doc['displayName'],
      bio: doc['bio'],
      hasSquated: doc['hasSquated'],
      amountDonated: doc['amountDonated'],
      squatCount: doc['squatCount'],
      locality: doc['locality'],
      country: doc['country'],
      lastSquatTime: doc['lastSquatTime'],
    );
  }
}
