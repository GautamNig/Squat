import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:squat/widgets/header.dart';
import 'package:squat/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../helpers/Constants.dart';
import '../models/user.dart';
import 'Home.dart';

class Squaters extends StatefulWidget {
  @override
  State<Squaters> createState() => _SquatsState();
}

class _SquatsState extends State<Squaters> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "Squatters"),
      body: StreamBuilder(
          stream:
              usersRef.orderBy("lastSquatTime", descending: true).snapshots(),
          builder: (context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            }
            List<UserWidget> users = [];
            snapshot.data.docs.forEach((doc) {
              users.add(UserWidget.fromDocument(doc));
            });
            return Stack(
              children: [
                ListView(
                  children: users,
                ),
                Constants.createAttributionAlignWidget(
                    'Santosh Thapa @Lottie Files'),
              ],
            );
          }),
    );
  }
}

class UserWidget extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final Timestamp timestamp;
  final String locality;
  final String country;

  UserWidget({
    required this.username,
    required this.userId,
    required this.avatarUrl,
    required this.timestamp,
    required this.locality,
    required this.country,
  });

  factory UserWidget.fromDocument(DocumentSnapshot doc) {
    return UserWidget(
      username: doc['username'],
      userId: doc['id'],
      timestamp: doc['lastSquatTime'],
      avatarUrl: doc['photoUrl'],
      locality: doc['locality'],
      country: doc['country'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text('$username\n$locality $country\n'),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(avatarUrl),
          ),
          subtitle: Text(timeago.format(timestamp.toDate())),
          trailing: Lottie.asset('assets/location.json'),
        ),
        const Divider(),
      ],
    );
  }
}
