import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id;
  String username;
  String email;
  String photoUrl;
  String displayName;
  String bio;
  num amountDonated;
  int squatCount;
  final String locality;
  final String country;
  final String isoCountryCode;
  final Timestamp lastSquatTime;
  final Timestamp joiningDateTime;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.photoUrl,
    required this.displayName,
    required this.bio,
    required this.amountDonated,
    required this.squatCount,
    required this.locality,
    required this.country,
    required this.isoCountryCode,
    required this.lastSquatTime,
    required this.joiningDateTime,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc['id'],
      email: doc['email'],
      username: doc['username'],
      photoUrl: doc['photoUrl'],
      displayName: doc['displayName'],
      bio: doc['bio'],
      amountDonated: doc['amountDonated'],
      squatCount: doc['squatCount'],
      locality: doc['locality'],
      country: doc['country'],
      isoCountryCode: doc['isoCountryCode'],
      lastSquatTime: doc['lastSquatTime'],
      joiningDateTime: doc['joiningDateTime'],
    );
  }
}
