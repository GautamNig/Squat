import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flag/flag.dart';
import 'package:flag/flag_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:squat/pages/profile_page.dart';
import 'package:squat/pages/squat_stat.dart';
import 'package:squat/widgets/header.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../helpers/Constants.dart';
import '../helpers/shared_axis_page_route.dart';
import '../models/user.dart';
import 'Home.dart';

class Squaters extends StatefulWidget {
  @override
  State<Squaters> createState() => _SquatsState();
}

class _SquatsState extends State<Squaters> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Squatters',
            style: Constants.appHeaderTextSTyle,
            overflow: TextOverflow.ellipsis,
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          actions: [
          OpenContainer(
            openColor: Colors.teal,
            closedColor: Colors.teal,
            transitionType: ContainerTransitionType.fade,
            transitionDuration: const Duration(milliseconds: 1100),
            openBuilder: (_, closeContainer) {
              return const SquatStat();
            },
            closedBuilder: (_, openContainer) {
              return IconButton(
                icon: const FaIcon(FontAwesomeIcons.chartPie, color: Colors.white,),
                onPressed: openContainer,
              );
            },
          ),
          ],
        ),
        body: Stack(
          children: [
            ListView(
              children: squattersList!
                  .map((e) => UserWidget(user: e)).toList(),
            ),
            Constants.createAttributionAlignWidget('Sachin @Lottie Files'),
          ],
        ));
  }
}

class UserWidget extends StatefulWidget {
  final User user;

  UserWidget({
    required this.user,
  });

  @override
  _UserWidgetState createState() => _UserWidgetState(
    // event: this.event,
  );
}

class _UserWidgetState extends State<UserWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final route = SharedAxisPageRoute(page: ProfilePage(user: widget.user), transitionType:
        SharedAxisTransitionType.scaled, duration: 1.5);
        await Navigator.of(context).push(route);
      },
      child: Card(
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
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width/4,
                                child: Tooltip(
                                  decoration: const BoxDecoration(color: Constants.appColor),
                                  message: widget.user.username,
                                  child: Text(widget.user.username,
                                      style: const TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          fontStyle: FontStyle.italic,
                                          color: Constants.appColor, fontSize: 20)),
                                ),
                              ),
                              widget.user.amountDonated > 0
                                  ? Container(
                                      height: 80,
                                      width: 60,
                                      child: Lottie.asset('assets/json/dollar.json'))
                                  : Container(
                                      height: 80,
                                      width: 60,
                                    ),
                            ],
                          ),
                        Container(
                          width: MediaQuery.of(context).size.width/5,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // const Padding(
                              //   padding:  EdgeInsets.only(right: 8.0),
                              //   child: Icon(Icons.accessibility_sharp),
                              // ),
                              Card(
                                  shape: BeveledRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(10.0),
                                  ),
                                  color: Constants.appColor,
                                  child: Container(
                                    height: 40,
                                    width: 60,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Center(child: Text(NumberFormat.compact().format(widget.user.squatCount),
                                          style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight:
                                          FontWeight
                                              .bold),),),
                                        const Text(
                                          'SQUATS',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 7),
                                        )
                                      ],
                                    ),),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Flag.fromString(
                            widget.user.isoCountryCode,
                            height: 50,
                            width: 50,
                            replacement:
                            Container(),
                          ),
                        )
                      ],
                    ),
                    Expanded(child: Text('${widget.user.locality}, ${widget.user.country}',
                      style: const TextStyle(overflow: TextOverflow.ellipsis,),),),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
