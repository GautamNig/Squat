import 'package:cloud_firestore/cloud_firestore.dart';

class Poll {
  String? pollId;
  String? pollTitle;
  String? pollDescription;
  String? createdByUserId;
  String? createdByUsername;
  Timestamp? pollCreatedDateTime;
  Timestamp? pollEndDateTime;
  List<dynamic>? options;
  Map<String, dynamic> voters = {};

  Poll({required this.pollId,
    required this.pollTitle,
    required this.pollDescription,
    required this.createdByUserId,
    required this.createdByUsername,
    required this.pollCreatedDateTime,
    required this.pollEndDateTime,
    required this.options,
    required this.voters});

  Poll.fromDocument(DocumentSnapshot snapshot) {
    pollId = snapshot['pollId'];
    pollTitle = snapshot['pollTitle'];
    pollDescription = snapshot['pollDescription'];
    createdByUserId = snapshot['createdByUserId'];
    createdByUsername = snapshot['createdByUsername'];
    pollCreatedDateTime = snapshot['pollCreatedDateTime'];
    pollEndDateTime = snapshot['pollEndDateTime'];
    options = snapshot['options'];
    voters = snapshot['voters'];
  }
}