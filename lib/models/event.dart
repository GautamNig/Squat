import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  String eventId;
  String eventName;
  String eventStatus;
  String eventLocation;
  String eventDescription;
  String giphyUrl;
  String createdByUserId;
  String createdByUsername;
  Timestamp eventCreatedDateTime;
  Timestamp eventOccurrenceDateTime;
  Timestamp eventEndDateTime;
  List<String> eventEnrolledByIds;

  Event({
    required this.eventId,
    required this.eventName,
    required this.eventStatus,
    required this.eventLocation,
    required this.eventDescription,
    required this.giphyUrl,
    required this.createdByUserId,
    required this.createdByUsername,
    required this.eventCreatedDateTime,
    required this.eventOccurrenceDateTime,
    required this.eventEndDateTime,
    required this.eventEnrolledByIds,
  });

  factory Event.fromDocument(DocumentSnapshot doc) {
    return Event(
      eventId: doc['eventId'],
      eventName: doc['eventName'],
      eventStatus: doc['eventStatus'],
      eventLocation: doc['eventLocation'],
      eventDescription: doc['eventDescription'],
      giphyUrl: doc['giphyUrl'],
      createdByUserId: doc['createdByUserId'],
      createdByUsername: doc['createdByUsername'],
      eventCreatedDateTime: doc['eventCreatedDateTime'],
      eventOccurrenceDateTime: doc['eventOccurrenceDateTime'],
      eventEndDateTime: doc['eventEndDateTime'],
      eventEnrolledByIds:
      List<String>.from(doc["eventEnrolledByIds"].map((x) => x)),
    );
  }
}
