import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../helpers/Constants.dart';
import '../models/event.dart';
import '../pages/Home.dart';

class EventDetail extends StatelessWidget {
  final Event event;

  EventDetail({required this.event}) : super();

  @override
  Widget build(BuildContext context) {

    final topContentText = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 50.0),
        const FaIcon(
          FontAwesomeIcons.peopleGroup,
          color: Colors.white,
          size: 20.0,
        ),
        Container(
          width: 90.0,
          child: const Divider(color: Colors.green),
        ),
        const SizedBox(height: 10.0),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Tooltip(
            decoration: const BoxDecoration(color: Constants.appColor),
            message: event.eventName,
            child: Constants.getAutoSizeText(event.eventName, color: Colors.white),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              const FaIcon(FontAwesomeIcons.user, color: Colors.white),
              const SizedBox(width: 10,),
              Text(
                event.createdByUsername,
                style: const TextStyle(color: Colors.white, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              const FaIcon(FontAwesomeIcons.locationArrow, color: Colors.white),
              const Text(' '),
              Expanded(
                child: Tooltip(
                  decoration: const BoxDecoration(color: Constants.appColor),
                  message: event.eventLocation,
                  child: Text(event.eventLocation,
                    style: const TextStyle(color: Colors.white, overflow: TextOverflow.ellipsis),),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Constants.createEventDetailscontainer('Participants: ${event.eventEnrolledByIds.length.toString()}'),
        ),
      ],
    );

    final topContent = Stack(
      children: <Widget>[
        event!.giphyUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: event!.giphyUrl,
                imageBuilder: (context, imageProvider) => Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              )
            : Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.5,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/nobully.png'),
                      fit: BoxFit.cover,
                    ))),
        Container(
          height: MediaQuery.of(context).size.height * 0.5,
          padding: const EdgeInsets.all(10.0),
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(color: Color.fromRGBO(58, 66, 86, .8)),
          child: topContentText,
        ),
        Positioned(
          left: 8.0,
          top: 30.0,
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        )
      ],
    );

    final bottomContentText = Text(
      event.eventDescription,
      style: const TextStyle(fontSize: 18.0),
    );
    // final readButton = Container(
    //     padding: const EdgeInsets.symmetric(vertical: 16.0),
    //     width: MediaQuery.of(context).size.width,
    //     child: RaisedButton(
    //       onPressed: () => {},
    //       color: const Color.fromRGBO(58, 66, 86, 1.0),
    //       child:
    //       const Text("TAKE THIS LESSON", style: TextStyle(color: Colors.white)),
    //     ));
    final bottomContent = Expanded(child: SingleChildScrollView(
      child: Container(padding: const EdgeInsets.symmetric(horizontal: 14), child: bottomContentText),
    ));

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: <Widget>[topContent, bottomContent],
        ),
      ),
    );
  }
}
