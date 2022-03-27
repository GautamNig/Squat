import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:squat/models/user.dart';

class UserPreferences {
  static User myUser = User(
    id: '',
    email: '',
    username: '',
    photoUrl: '',
    displayName: '',
    bio: '',
    amountDonated: 0,
    squatCount: 0,
    locality: '',
    country: '',
    isoCountryCode: '',
    lastSquatTime: Timestamp.fromDate(DateTime.now()),
    joiningDateTime: Timestamp.fromDate(DateTime.now()),
  );
}
