import 'package:cloud_firestore/cloud_firestore.dart';

class Poll {
  String? pollId;
  String? pollTitle;
  String? pollImage;
  String? createdByUserId;
  String? createdByUsername;
  Timestamp? pollCreatedDateTime;
  Timestamp? pollEndDateTime;
  List<dynamic>? options;
  Map<String, dynamic> voters = {};

  Poll({required this.pollId,
    required this.pollTitle,
    required this.pollImage,
    required this.createdByUserId,
    required this.createdByUsername,
    required this.pollCreatedDateTime,
    required this.pollEndDateTime,
    required this.options,
    required this.voters});

  Poll.fromDocument(DocumentSnapshot snapshot) {
    pollId = snapshot['pollId'];
    pollTitle = snapshot['pollTitle'];
    pollImage = snapshot['pollImage'];
    createdByUserId = snapshot['createdByUserId'];
    createdByUsername = snapshot['createdByUsername'];
    pollCreatedDateTime = snapshot['pollCreatedDateTime'];
    pollEndDateTime = snapshot['pollEndDateTime'];
    options = snapshot['options'];
    voters = snapshot['voters'];
  }
}