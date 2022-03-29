import 'package:animations/animations.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:squat/pages/news_page.dart';
import 'package:squat/widgets/progress.dart';
import '../helpers/Constants.dart';
import '../models/event.dart';
import '../widgets/event_detail.dart';
import 'CreateEvent.dart';
import 'Home.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import '../helpers/shared_axis_page_route.dart';

class Events extends StatefulWidget {
  @override
  EventsState createState() => EventsState();
}

class EventsState extends State<Events> {
  List<DocumentSnapshot> documents = [];

  buildEvents() {
    return StreamBuilder(
        stream: eventsRef.snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<EventWidget> events = [];

          documents = snapshot.data.docs;

          if (documents.isEmpty) {
            return Image.asset('assets/images/notfound.png', fit: BoxFit.fill);
          }

          documents.forEach((doc) {
            events.add(EventWidget(event: Event.fromDocument(doc)));
          });
          return ListView(
            children: events,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: OpenContainer(
        openColor: Colors.teal,
        closedColor: Colors.teal,
        transitionType: ContainerTransitionType.fade,
        transitionDuration: const Duration(milliseconds: 1100),
        openBuilder: (_, closeContainer) {
          return CreateEvent();
        },
        closedBuilder: (_, openContainer) {
          return FloatingActionButton(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(0.0))
            ),
            backgroundColor: Constants.appColor,
            foregroundColor: Colors.white,
            onPressed: openContainer,
            child: const FaIcon(FontAwesomeIcons.plus, color: Colors.white),
          );
        },
      ),
      appBar: AppBar(
        title: Stack(
          children: [
            const Align(
              alignment: Alignment.center,
              child: Text(
                'Events',
                style: Constants.appHeaderTextSTyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Align(
                alignment: Alignment.bottomRight,
                child: Image.asset('assets/images/poweredbygiphy.png')),
          ],
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: buildEvents()),
          const Divider(),
        ],
      ),
    );
  }
}

class EventWidget extends StatefulWidget {
  final Event event;

  EventWidget({
    required this.event,
  });

  @override
  _EventWidgetState createState() => _EventWidgetState(
    // event: this.event,
  );
}

class _EventWidgetState extends State<EventWidget> {
  AudioCache audioCache = AudioCache();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async{
        final route = SharedAxisPageRoute(page: EventDetail(event: widget.event), transitionType:
        SharedAxisTransitionType.scaled, duration: 1.5);
        await Navigator.of(context).push(route);

        //Show SharedAxis Page - Provides 3 axis, vt, hz and scale
        // Navigator.push(context, SharedAxisPageRoute.sharedAxis(EventDetail(event: widget.event), SharedAxisTransitionType.scaled));
      },
      child: Card(
        color: Constants.appColor,
        elevation: 14,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
          margin: const EdgeInsets.only(left: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widget.event!.giphyUrl.isNotEmpty
                  ? Column(
                    children: [
                      CachedNetworkImage(
                          imageUrl: widget.event!.giphyUrl,
                          imageBuilder: (context, imageProvider) => Container(
                            width: 110,
                            height: 110.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              image: DecorationImage(
                                  image: imageProvider, fit: BoxFit.cover),
                            ),
                          ),
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      Text(
                        widget.event!.eventStatus,
                        style: const TextStyle(
                            color: Colors.red, overflow: TextOverflow.ellipsis,
                            fontSize: 20,
                            fontStyle: FontStyle.italic),
                      )
                    ],
                  )
                  : Column(
                    children: [
                      Container(
                          width: 110.0,
                          height: 110.0,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage('assets/images/nobully.png'),
                                fit: BoxFit.cover,
                              ))),
                      Text(
                        widget.event!.eventStatus,
                        style: const TextStyle(
                            color: Colors.red, overflow: TextOverflow.ellipsis,
                            fontSize: 20,
                            fontStyle: FontStyle.italic),
                      )
                    ],
                  ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Constants.getAutoSizeText(widget.event!.eventName, fontWeight: FontWeight.bold),
                        const SizedBox(height: 20,),
                        Stack(
                          children: [
                            Visibility(
                              visible: widget.event!.eventStatus == '',
                              child: Padding(padding: const EdgeInsets.only(left: 4, right: 4), child: CountdownTimer(
                                endTime:
                                widget.event!.eventOccurrenceDateTime.millisecondsSinceEpoch,
                                onEnd: () {
                                  if (widget.event!.eventStatus == 'EXPIRED' ||
                                      widget.event!.eventStatus == 'LIVE') return;

                                  audioCache.play('bell.mp3');

                                  eventsRef
                                      .doc(widget.event!.eventId)
                                      .update({'eventStatus': 'LIVE'});
                                },
                                widgetBuilder: (_, CurrentRemainingTime? time) {
                                  if (time == null) {
                                    return Container();
                                  }
                                  return Constants.getAutoSizeText(
                                      'Live in: ${time.days ?? '00'}:${time.hours ?? '00'}:${time.min ?? '00'}:${time.sec ?? '00'}',
                                    fontSize: 14, color: Colors.red, maxLines: 1,
                                  );
                                },
                              ),),
                            ),
                            Visibility(
                              visible: widget.event!.eventStatus == 'LIVE',
                              child: Padding(padding: const EdgeInsets.only(left: 4, right: 4), child: CountdownTimer(
                                endTime: widget.event!.eventEndDateTime.millisecondsSinceEpoch,
                                widgetBuilder: (_, CurrentRemainingTime? time) {
                                  if (time == null) {
                                    return Container();
                                  }
                                  return Constants.getAutoSizeText(
                                  'Ends in: ${time.days ?? '00'}:${time.hours ?? '00'}:${time.min ?? '00'}:${time.sec ?? '00'}',
                                    fontSize: 14, color: Colors.red, maxLines: 1,
                                  );
                                },
                                onEnd: () {
                                  if (widget.event!.eventStatus == 'EXPIRED') return;
                                  eventsRef
                                      .doc(widget.event!.eventId)
                                      .update({'eventStatus': 'EXPIRED'});
                                },
                              ),
                              ),),
                          ],
                        ),

                        // Expanded(child: Text('$locality, $country',
                        //   style: const TextStyle(overflow: TextOverflow.ellipsis,),),),
                      ],
                    ),
                ),
              ),
              Padding(padding: const EdgeInsets.only(right: 8), child: Badge(
                badgeColor: Constants.appColor,
                showBadge:
                widget.event!.eventEnrolledByIds.isEmpty ? false : true,
                position: BadgePosition.topEnd(top: 0, end: -8),
                animationDuration: const Duration(milliseconds: 300),
                animationType: BadgeAnimationType.fade,
                badgeContent: Text(
                    NumberFormat.compact()
                        .format(widget.event!.eventEnrolledByIds.length),
                    style: const TextStyle(color: Colors.white)),
                child: IconButton(
                  onPressed: widget.event!.eventStatus == 'EXPIRED'
                      ? null
                      : () async {
                    if (widget.event!.eventEnrolledByIds
                        .contains(currentUser.id)) {
                      widget.event!.eventEnrolledByIds
                          .remove(currentUser.id);
                      await eventsRef.doc(widget.event!.eventId).update({
                        'eventEnrolledByIds': List<dynamic>.from(
                            widget.event!.eventEnrolledByIds)
                      });
                    } else {
                      widget.event!.eventEnrolledByIds.add(currentUser.id);
                      await eventsRef.doc(widget.event!.eventId).update({
                        'eventEnrolledByIds': List<dynamic>.from(
                            widget.event!.eventEnrolledByIds)
                      });
                    }
                  },
                  icon: Icon(
                    Icons.supervised_user_circle,
                    size: 35,
                    color:
                    widget.event!.eventEnrolledByIds.contains(currentUser.id)
                        ? Constants.appColor
                        : Colors.grey,
                  ),
                ),
              ),),
            ],
          ),
        ),
      ),
    );
  }
}
