import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
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
                    'Santosh Thapa/Sachin @Lottie Files'),
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
  final num amountDonated;
  final num squatCount;

  UserWidget({
    required this.username,
    required this.userId,
    required this.avatarUrl,
    required this.timestamp,
    required this.locality,
    required this.country,
    required this.amountDonated,
    required this.squatCount,
  });

  factory UserWidget.fromDocument(DocumentSnapshot doc) {
    return UserWidget(
      username: doc['username'],
      userId: doc['id'],
      timestamp: doc['lastSquatTime'],
      avatarUrl: doc['photoUrl'],
      locality: doc['locality'],
      country: doc['country'],
      amountDonated: doc['amountDonated'],
      squatCount: doc['squatCount'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text('$username\n$locality $country\n'),
          onLongPress: () {
            Alert(
                context: context,
                title: 'Squatter Profile',
                content: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 120,
                      child: Container(
                        alignment: const Alignment(0.0, 2.5),
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(avatarUrl),
                          radius: 60.0,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 60,
                    ),
                    Text(
                      username,
                      style: const TextStyle(
                          fontSize: 25.0,
                          color: Colors.blueGrey,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "$locality, $country",
                      style: const TextStyle(
                          fontSize: 18.0,
                          color: Colors.black45,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.w300),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      timeago.format(timestamp.toDate()),
                      style: const TextStyle(
                          fontSize: 15.0,
                          color: Colors.black45,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
                buttons: [
                  DialogButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Ok",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  )
                ]).show();
          },
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(avatarUrl),
          ),
          subtitle: Text(timeago.format(timestamp.toDate())),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              amountDonated > 0
                  ? Lottie.asset('assets/dollar.json')
                  : Container(),
              Lottie.asset('assets/location.json'),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }
}
