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
import 'home.dart';

class Squaters extends StatefulWidget {
  @override
  State<Squaters> createState() => _SquatsState();
}

class _SquatsState extends State<Squaters> {
  String searchText = '';

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
                  icon: const FaIcon(
                    FontAwesomeIcons.chartPie,
                    color: Colors.white,
                  ),
                  onPressed: openContainer,
                );
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                buildSearchField(),
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: searchText.isNotEmpty
                        ? squattersList!
                            .where((element) => element.displayName
                                .toLowerCase()
                                .contains(searchText.toLowerCase()))
                            .map((e) => Column(
                                  children: [
                                    UserWidget(user: e),
                                    const Divider(),
                                  ],
                                ))
                            .toList()
                        : squattersList!
                            .map((e) => Column(
                                  children: [
                                    UserWidget(user: e),
                                    const Divider(),
                                  ],
                                ))
                            .toList(),
                  ),
                ),
              ],
            ),
            Constants.createAttributionAlignWidget('Sachin @Lottie Files'),
          ],
        ));
  }

  TextFormField buildSearchField() {
    return TextFormField(
      onChanged: (value) {
        setState(() {
          searchText = value;
        });
      },
      decoration: const InputDecoration(
        hintText: "Search for a user...",
        filled: true,
        prefixIcon: Icon(
          Icons.account_circle_rounded,
          size: 28.0,
        ),
      ),
    );
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
    return ListTile(
      title: Text(
        widget.user.username,
        style: const TextStyle(color: Constants.appColor),
      ),
      leading: CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(widget.user.photoUrl),
      ),
      subtitle: Text('Squats: ${widget.user.squatCount.toString()}'),
      trailing: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            getFlagForCountry(),
            (widget.user.locality.isEmpty || widget.user.country.isEmpty)
                ? const SizedBox()
                : Text(
                    '${widget.user.locality}, ${widget.user.country}',
                    style: const TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        overflow: TextOverflow.ellipsis,
                        color: Constants.appColor),
                  )
          ],
        ),
      ),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProfilePage(user: widget.user)));
      },
    );
  }

  Widget getFlagForCountry(){
    try{
      Flag flag = Flag.fromString(
        widget.user.isoCountryCode,
        height: 30,
        width: 30,
        replacement: Container(),
      );

      return Expanded(
        child: widget.user.isoCountryCode.isNotEmpty
            ? flag
            : const SizedBox(),
      );
    }catch(e){
      return const Expanded(child: SizedBox());
    }
  }
}
