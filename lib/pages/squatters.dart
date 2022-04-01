import 'package:animations/animations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flag/flag.dart';
import 'package:flag/flag_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:squat/pages/profile_page.dart';
import 'package:squat/pages/squat_stat.dart';
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
                  .map((e) => Column(
                    children: [
                      UserWidget(user: e),
                      const Divider(),
                    ],
                  )).toList(),
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
    return  ListTile(
      title: Text(widget.user.username, style: const TextStyle(
          color: Constants.appColor),),
      leading: CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(
            widget.user.photoUrl
        ),
      ),
      subtitle: Text('Squats: ${widget.user.squatCount.toString()}'),
      trailing: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Flag.fromString(
                widget.user.isoCountryCode,
                height: 30,
                width: 30,
                replacement:
                Container(),
              ),
            ),
            Text('${widget.user.locality}, ${widget.user.country}',
            style: const TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic, overflow: TextOverflow.ellipsis,
                color: Constants.appColor),)
          ],
        ),
      ),
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ProfilePage(user: widget.user)));
      },
    );
  }
}
