import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:squat/models/user.dart';
import 'package:squat/pages/home.dart';
import 'package:squat/widgets/button_widget.dart';
import 'package:squat/widgets/numbers_widget.dart';
import 'package:squat/widgets/profile_widget.dart';
import 'package:squat/widgets/progress.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/user.dart';
import '../widgets/header.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  ProfilePage({required this.user}) : super();

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late List<_SquattersChartData> data;
  late TooltipBehavior _tooltip;
  int min = 2;
  int max = 10;
  bool isCurrentUserPurgeInProgress = false;

  @override
  void initState() {
    var topSquatters =
        squattersList!.take(min + random.nextInt(max - min)).toList();

    if (!topSquatters.contains(widget.user)) topSquatters.add(widget.user);

    data = topSquatters
        .map((e) => _SquattersChartData(
            e.displayName,
            e.squatCount /
                (DateTime.now().difference(e.joiningDateTime.toDate()).inDays)))
        .toList();

    _tooltip = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Builder(
      builder: (context) => Scaffold(
        appBar: header(context, titleText: 'User Profile'),
        body: isCurrentUserPurgeInProgress
            ? circularProgress()
            : ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            const SizedBox(height: 24),
            ProfileWidget(
              imagePath: user.photoUrl,
              isCurrentUser: currentUser.id == user.id,
              onClicked: () {
                Alert(
                  context: context,
                  type: AlertType.warning,
                  title: "PURGE USER",
                  desc:
                      "This action will permanently delete all events/comments made by user and any user data stored. Do you wish to continue?",
                  buttons: [
                    DialogButton(
                      child: const Text(
                        "Yes",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        setState(() {
                          isCurrentUserPurgeInProgress = true;
                        });

                        await FirebaseFirestore.instance
                            .runTransaction((Transaction myTransaction) async {
                          var commentsToDelete = await commentsRef
                              .where('userId', isEqualTo: currentUser.id)
                              .get();

                          commentsToDelete.docs.forEach((doc) {
                            myTransaction.delete(doc.reference);
                          });

                          var eventsToDelete = await eventsRef
                              .where('createdByUserId',
                                  isEqualTo: currentUser.id)
                              .get();

                          eventsToDelete.docs.forEach((doc) {
                            myTransaction.delete(doc.reference);
                          });

                          var usersToDelete = await usersRef
                              .where('id', isEqualTo: currentUser.id)
                              .get();

                          usersToDelete.docs.forEach((doc) {
                            myTransaction.delete(doc.reference);
                          });

                          googleSignIn.signOut();
                        });

                        setState(() {
                          isCurrentUserPurgeInProgress = false;
                        });
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      color: const Color.fromRGBO(0, 179, 134, 1.0),
                    ),
                    DialogButton(
                      child: const Text(
                        "No",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      onPressed: () => Navigator.pop(context),
                      gradient: const LinearGradient(colors: [
                        Color.fromRGBO(116, 116, 191, 1.0),
                        Color.fromRGBO(52, 138, 199, 1.0)
                      ]),
                    )
                  ],
                ).show();
              },
            ),
            const SizedBox(height: 24),
            buildName(user),
            const SizedBox(height: 24),
            Center(child: buildUpgradeButton()),
            const SizedBox(height: 24),
            NumbersWidget(user),
            const SizedBox(height: 48),
            buildAbout(user),
          ],
        ),
      ),
    );
  }

  Widget buildName(User user) => Column(
        children: [
          Text(
            user.displayName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: const TextStyle(color: Colors.grey),
          )
        ],
      );

  Widget buildUpgradeButton() => ButtonWidget(
        text: 'User squat performance',
        onClicked: () {
          Alert(
              context: context,
              content: SfCartesianChart(
                  title: ChartTitle(
                      text: 'Average squats/day',
                      textStyle: const TextStyle(
                        fontFamily: "Signatra",
                        fontSize: 30,
                        color: Colors.teal,
                      )),
                  primaryXAxis: CategoryAxis(borderColor: Colors.teal),
                  primaryYAxis:
                      NumericAxis(minimum: 0, maximum: 40, interval: 10),
                  tooltipBehavior: _tooltip,
                  series: <ChartSeries<_SquattersChartData, String>>[
                    BarSeries<_SquattersChartData, String>(
                        dataSource: data,
                        xValueMapper: (_SquattersChartData data, _) => data.x,
                        yValueMapper: (_SquattersChartData data, _) => data.y,
                        name: 'Gold',
                        color: const Color.fromRGBO(8, 142, 255, 1))
                  ])).show();
        },
      );

  Widget buildAbout(User user) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              user.bio,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
          ],
        ),
      );
}

class _SquattersChartData {
  _SquattersChartData(this.x, this.y);

  final String x;
  final double y;
}
