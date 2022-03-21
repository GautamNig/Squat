import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flag/flag.dart';
import 'package:flag/flag_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:squat/widgets/header.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../helpers/Constants.dart';
import '../models/user.dart';
import 'Home.dart';

class Squaters extends StatefulWidget {
  @override
  State<Squaters> createState() => _SquatsState();
}

class _SquatsState extends State<Squaters> {

  bool isSortedRecently = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "Squatters"),
      body: Stack(
              children: [
                ListView(
                  children: squattersList!.map((e) => UserWidget.fromDocument(e))!.toList(),
                ),
                Constants.createAttributionAlignWidget(
                    'Sachin @Lottie Files'),
              ],
            )
    );
  }
}

class UserWidget extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final Timestamp joiningDateTime;
  final String locality;
  final String country;
  final String isoCountryCode;
  final num amountDonated;
  final num squatCount;

  UserWidget({
    required this.username,
    required this.userId,
    required this.avatarUrl,
    required this.joiningDateTime,
    required this.locality,
    required this.country,
    required this.isoCountryCode,
    required this.amountDonated,
    required this.squatCount,
  });

  factory UserWidget.fromDocument(User user) {
    return UserWidget(
      username: user.username,
      userId: user.id,
      joiningDateTime: user.joiningDateTime,
      avatarUrl: user.photoUrl,
      locality: user.locality,
      country: user.country,
      isoCountryCode: user.isoCountryCode,
      amountDonated: user.amountDonated,
      squatCount: user.squatCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    return  Card(
      color: Constants.appColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      child: Wrap(
        children: [
          Container(
            height: 98,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            margin: const EdgeInsets.only(left: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            Text(username, style: const TextStyle(fontStyle: FontStyle.italic, color: Constants.appColor)),
                            amountDonated > 0
                                ? Container(height: 60, width: 60, child: Lottie.asset('assets/dollar.json'))
                                : Container(),
                          ],
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('$locality, $country'),
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Flag.fromString(isoCountryCode, height: 50, width: 50, replacement: Text('$isoCountryCode not found'),),
                              )
                            ],
                          ),
                        ),
                        Text('Joined ${timeago.format(joiningDateTime.toDate())}',
                            style: const TextStyle(fontStyle: FontStyle.italic,
                                color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
