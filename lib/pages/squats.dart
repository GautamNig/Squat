import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:squat/widgets/header.dart';
import 'package:squat/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'Home.dart';

class Squats extends StatefulWidget {
  @override
  State<Squats> createState() => _SquatsState();
}

class _SquatsState extends State<Squats> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: squatsRef
            .orderBy("timestamp", descending: false)
            .snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<Squat> squats = [];
          snapshot.data.docs.forEach((doc) {
            print(doc);
            squats.add(Squat.fromDocument(doc));
          });
          return ListView(
            children: squats,
          );
        });
  }
}

class Squat extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final Timestamp timestamp;
  final String locality;
  final String country;

  Squat({
    required this.username,
    required this.userId,
    required this.avatarUrl,
    required this.timestamp,
    required this.locality,
    required this.country,
  });

  factory Squat.fromDocument(DocumentSnapshot doc) {
    return Squat(
      username: doc['username'],
      userId: doc['userId'],
      timestamp: doc['timestamp'],
      avatarUrl: doc['avatarUrl'],
      locality: doc['locality'],
      country: doc['country'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text('A new squat done by $username\n$locality $country\n'),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(avatarUrl),
          ),
          subtitle: Text(timeago.format(timestamp.toDate())),
        ),
        const Divider(),
      ],
    );
  }
}
