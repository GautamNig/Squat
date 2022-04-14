import 'dart:async';
import 'dart:convert';
import 'dart:math';
import "package:intl/intl.dart";
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:rive/rive.dart';
import 'package:rxdart/rxdart.dart';
import 'package:squat/pages/comments.dart';
import 'package:squat/pages/donation.dart';
import 'package:squat/pages/events.dart';
import 'package:squat/pages/polls_view.dart';
import 'package:squat/pages/squatters.dart';
import '../helpers/Constants.dart';
import '../json_parsers/json_parser_firebase_appSettings.dart';
import '../models/poll.dart';
import '../models/user.dart';
import '../widgets/progress.dart';
import 'create_account.dart';
import 'package:badges/badges.dart';
import 'package:odometer/odometer.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'news_latest.dart';
import 'news_page.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final usersRef = FirebaseFirestore.instance.collection('users');
final eventsRef = FirebaseFirestore.instance.collection('events');
final commentsRef = FirebaseFirestore.instance.collection('comments');
final appSettingsRef = FirebaseFirestore.instance.collection('settings');
final pollsRef = FirebaseFirestore.instance.collection('polls');
final random = Random();
late User currentUser;
List<User>? squattersList = [];
List<Poll> pollsList = [];

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  bool isAuth = false;
  String squatLocality = '';
  String squatCountry = '';
  String isoCountryCode = '';
  PageController? pageController;
  int pageIndex = 0;
  SMIInput<bool>? _trigger;
  Artboard? _startArtBoard;
  int squatersCount = 0;
  num totalGlobalSquatCount = 0;

  AnimationController? animationController;
  late Animation<OdometerNumber> animation;

  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  final List<_PositionItem> _positionItems = <_PositionItem>[];
  bool positionStreamStarted = false;

  static const String _kLocationServicesDisabledMessage =
      'Location services are disabled.';
  static const String _kPermissionDeniedMessage = 'Permission denied.';
  static const String _kPermissionDeniedForeverMessage =
      'Permission denied forever.';
  static const String _kPermissionGrantedMessage = 'Permission granted.';

  static num _timerDuration = 0;
  final StreamController _timerStream = BehaviorSubject();
  int timerCounter = 0;
  late Timer _resendCodeTimer;
  AudioCache audioCache = AudioCache();
  bool _fireworksVisibility = false;

  int min = 5;
  int max = 100;

  String? snackBarText;

  // Usually we dispose the stuff created in init.
  @override
  void dispose() {
    super.dispose();
    pageController?.dispose();
    animationController?.dispose();
    _timerStream.close();
    _resendCodeTimer.cancel();
  }

  @override
  void initState() {
    super.initState();
    activeCounter();
    animationController =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
    animation =
        OdometerTween(begin: OdometerNumber(10000), end: OdometerNumber(12000))
            .animate(
      CurvedAnimation(curve: Curves.bounceIn, parent: animationController!),
    );

    usersRef.get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        squattersList?.add(User.fromDocument(doc));
      });

      pollsRef.get().then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          pollsList!.add(Poll.fromDocument(doc));
        });});

      squatersCount =
          squattersList!.where((element) => element.squatCount > 0).length;
    });

    pageController = PageController();
    // Detects when user signed in
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {});

    // Re-authenticate user when app is opened
    googleSignIn
        .signInSilently(suppressErrors: false)
        .then((account) => handleSignIn(account))
        .catchError((err) {});

    getLocationAndSetupRive();
    appSettingsRef.get().then((value) {
      Constants.appSettings =
          Configuration.fromJson(value.docs.first.data()).appSettings!;
      _timerDuration = int.parse(Constants.appSettings!.squatWaitTime![0]);
      if (_timerDuration == 0) {
        _timerDuration = min + random.nextInt(max - min);
      }

      snackBarText = Constants.appSettings?.developerMessages?.first;
      if (snackBarText != null && snackBarText!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(snackBarText!),
          backgroundColor: Constants.appColor,
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }

  Future getLocationAndSetupRive() async {
    await getUserLocation();
    rootBundle.load('assets/rives/squat.riv').then((data) {
      final file = RiveFile.import(data);
      final artBoard = file.mainArtboard;
      var controller =
          StateMachineController.fromArtboard(artBoard, 'Don\'t Skip Leg Day');
      if (controller != null) {
        artBoard.addController(controller);
        _trigger = controller.findInput('Squat');
      }
      setState(() {
        _startArtBoard = artBoard;
      });
    });
  }

  getUserLocation() async {
    final hasPermission = await _handlePermission();

    if (hasPermission != null && !hasPermission) {
      return;
    }

    final position = await _geolocatorPlatform.getCurrentPosition();
    _updatePositionList(
      _PositionItemType.position,
      position.toString(),
    );

    List<Placemark> placemarks = await GeocodingPlatform.instance
        .placemarkFromCoordinates(position.latitude, position.longitude, localeIdentifier: "en");
    Placemark placemark = placemarks[0];
    squatLocality = placemark.locality ?? '';
    squatCountry = placemark.country ?? '';
    isoCountryCode = placemark.isoCountryCode ?? '';
  }

  handleSignIn(GoogleSignInAccount? account) async {
    if (account != null) {
      await createUserInFirestore();
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  Future<bool?> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      _updatePositionList(
        _PositionItemType.log,
        _kLocationServicesDisabledMessage,
      );

      return false;
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        _updatePositionList(
          _PositionItemType.log,
          _kPermissionDeniedMessage,
        );

        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      _updatePositionList(
        _PositionItemType.log,
        _kPermissionDeniedForeverMessage,
      );

      return false;
    }
  }

  login() async {
    EasyLoading.show();
    await googleSignIn.signIn().then((result) {}).catchError((err) {});
    EasyLoading.dismiss();
  }

  logout() {
    googleSignIn.signOut();
  }

  createUserInFirestore() async {
    final GoogleSignInAccount? user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.doc(user?.id).get();

    if (!doc.exists) {
      final username = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));

      usersRef.doc(user?.id).set({
        "id": user?.id,
        "username": username,
        "photoUrl": user?.photoUrl,
        "email": user?.email,
        "displayName": user?.displayName,
        "bio": "",
        "amountDonated": 0,
        "squatCount": 0,
        "locality": squatLocality,
        "country": squatCountry,
        "isoCountryCode": isoCountryCode,
        "lastSquatTime": DateTime.now(),
        "joiningDateTime": DateTime.now(),
      });
      doc = await usersRef.doc(user?.id).get();
    }
    currentUser = User.fromDocument(doc);
    cacheImage(context, currentUser.photoUrl);
  }

  void _updatePositionList(_PositionItemType type, String displayValue) {
    _positionItems.add(_PositionItem(type, displayValue));
  }

  static Future cacheImage(BuildContext context, String urlImage) {
    if (urlImage.isNotEmpty)
      return precacheImage(CachedNetworkImageProvider(urlImage), context);
    return Future.value();
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
          child: StreamBuilder(
              stream: _timerStream.stream,
              builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: usersRef.snapshots(),
                    builder: (context, snapshotUsers) {
                      if (!snapshotUsers.hasData) return circularProgress();

                      if (snapshot.data == 0) _fireworksVisibility = false;

                      squattersList = snapshotUsers.data?.docs
                          .map((e) => User.fromDocument(e))
                          .toList();
                      // squattersList?.sort((a,b) => b.joiningDateTime.compareTo(a.joiningDateTime));
                      var squattersSquatCountList =
                          squattersList?.map((e) => e.squatCount);

                      currentUser = squattersList?.firstWhere(
                              (element) => element.id == currentUser.id) ??
                          User(
                            id: '',
                            email: '',
                            username: '',
                            photoUrl: '',
                            displayName: '',
                            bio: '',
                            amountDonated: 0,
                            squatCount: 0,
                            locality: '',
                            country: '',
                            isoCountryCode: '',
                            lastSquatTime: Timestamp.fromDate(DateTime.now()),
                            joiningDateTime: Timestamp.fromDate(DateTime.now()),
                          );

                      squatersCount = squattersSquatCountList!
                          .where((element) => element > 0)
                          .length;

                      num sum = 0;
                      for (num e in squattersSquatCountList) {
                        sum += e;
                      }
                      totalGlobalSquatCount = sum;

                      return PageView(
                        children: <Widget>[
                          // Timeline(),
                          _startArtBoard == null
                              ? const SizedBox()
                              : Stack(alignment: Alignment.center, children: [
                                  Rive(
                                    artboard: _startArtBoard!,
                                    fit: BoxFit.fill,
                                  ),
                                  Visibility(
                                      visible: _fireworksVisibility,
                                      child: Lottie.asset(
                                          'assets/json/fireworks.json')),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child:
                                        Lottie.asset('assets/json/flame.json'),
                                  ),
                                  Positioned(
                                    top: MediaQuery.of(context).size.height *
                                        0.67,
                                    right: 10,
                                    child: Tooltip(
                                      decoration: const BoxDecoration(
                                          color: Constants.appColor),
                                      message:
                                          'Perform a squat against russian bullying.',
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            elevation: 8),
                                        onPressed: snapshot.data == 0
                                            ? () async {
                                                _timerStream.sink
                                                    .add(_timerDuration);
                                                activeCounter();

                                                _trigger?.value = true;
                                                Future.delayed(
                                                    const Duration(
                                                        milliseconds: 1400),
                                                    () {
                                                  audioCache.play('grunt.mp3');
                                                  //_fireworksVisibility = true;
                                                });

                                                Future.delayed(
                                                    const Duration(
                                                        milliseconds: 2000),
                                                    () async {
                                                  currentUser.squatCount++;
                                                  await usersRef
                                                      .doc(currentUser.id)
                                                      .update({
                                                    "squatCount":
                                                        currentUser.squatCount,
                                                    "lastSquatTime":
                                                        DateTime.now()
                                                  });
                                                  audioCache
                                                      .play('doorclose.wav');
                                                });
                                                Future.delayed(
                                                    const Duration(
                                                        milliseconds: 2600),
                                                    () async {
                                                  _fireworksVisibility = true;
                                                });
                                              }
                                            : null,
                                        child: Center(
                                            child: snapshot.data == 0
                                                ? const Text(
                                                    'Squat it',
                                                    style: Constants
                                                        .appHeaderTextSTyle,
                                                  )
                                                : Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Text(
                                                          'Rest: ${snapshot.hasData ? snapshot.data.toString() : _timerDuration} sec'),
                                                    ],
                                                  )),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: MediaQuery.of(context).size.height *
                                        0.67,
                                    left: 10,
                                    child: Tooltip(
                                      decoration: const BoxDecoration(
                                          color: Constants.appColor),
                                      message: 'Logout',
                                      child: IconButton(
                                        onPressed: () {
                                          Alert(
                                              context: context,
                                              type: AlertType.info,
                                              title: "Logout",
                                              desc:
                                                  "Do you wish to logout of the app?",
                                              buttons: [
                                                DialogButton(
                                                    child: const Text(
                                                      "Yes",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 20),
                                                    ),
                                                    onPressed: () async {
                                                      googleSignIn.signOut();
                                                      Navigator.pop(context);
                                                    }),
                                                DialogButton(
                                                  child: const Text(
                                                    "No",
                                                    style: TextStyle(color: Colors.white, fontSize: 20),
                                                  ),
                                                  onPressed: () => Navigator.pop(context),
                                                )
                                              ]).show();
                                        },
                                        icon: const Icon(Icons.logout_sharp,
                                            color: Constants.appColor),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: MediaQuery.of(context).size.height *
                                        0.025,
                                    left: 3,
                                    child: Column(
                                      children: [
                                        Card(
                                          shape: BeveledRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          color: Colors.blueGrey,
                                          child: Container(
                                            height: 60,
                                            width: 100,
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  AnimatedSlideOdometerNumber(
                                                    letterWidth: 15,
                                                    odometerNumber:
                                                        OdometerNumber(
                                                            currentUser
                                                                .squatCount),
                                                    duration: const Duration(
                                                        seconds: 1),
                                                    numberTextStyle:
                                                        const TextStyle(
                                                            fontSize: 30,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                  ),
                                                  const Text(
                                                    'MY SQUATS',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: MediaQuery.of(context).size.height *
                                        0.025,
                                    right: 1,
                                    child: Column(
                                      children: [
                                        Card(
                                          shape: BeveledRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          color: Colors.blueGrey,
                                          child: Container(
                                            height: 60,
                                            width: 100,
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  AnimatedSlideOdometerNumber(
                                                    letterWidth: 15,
                                                    odometerNumber:
                                                        OdometerNumber(
                                                            totalGlobalSquatCount
                                                                .toInt()),
                                                    duration: const Duration(
                                                        seconds: 1),
                                                    numberTextStyle:
                                                        const TextStyle(
                                                            fontSize: 30,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                  ),
                                                  const Text(
                                                    'WORLD SQUATS',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Constants.createAttributionAlignWidget(
                                      'Lumberjack Squats by Dante @rive.app'),
                                  Constants.createAttributionAlignWidget(
                                      'Akiko/Tom Fabre @Lottie Files',
                                      alignmentGeometry: Alignment.bottomLeft)
                                ]),
                          Squaters(),
                          Comments(userId: currentUser.id),
                          Events(),
                          const NewsPage(),
                          PollView(),
                          const Donation(),
                          // ActivityFeed(),
                          // Upload(currentUser:currentUser),
                          // Search(),
                          // Profile(profileId: currentUser.id ?? '')
                        ],
                        controller: pageController,
                        onPageChanged: onPageChanged,
                        physics: const NeverScrollableScrollPhysics(),
                      );
                    });
              })),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Constants.appColor,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.whatshot),
          ),
          BottomNavigationBarItem(
            icon: Badge(
              child: const Icon(Icons.supervisor_account_sharp),
              badgeColor: Constants.appColor,
              shape: BadgeShape.square,
              position: BadgePosition.bottomEnd(bottom: -15),
              badgeContent: Text(
                NumberFormat.compact().format(squatersCount),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          const BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.solidCommentDots, size: 24)),
          const BottomNavigationBarItem(
              icon: Icon(Icons.event_available_rounded)),
          const BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.earthAmericas, size: 24)),
          const BottomNavigationBarItem(
              icon: Icon(Icons.how_to_vote_outlined)),
          const BottomNavigationBarItem(
              icon: Icon(Icons.monetization_on_sharp)),
        ],
      ),
    );
  }

  buildUnAuthScreen() {
    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 12.0),
                child: Image.asset('assets/images/bear.png'),
              ),
            ),
            const Text(
              'Squat against the russian bear',
              style: TextStyle(
                  fontFamily: "Signatra", fontSize: 40, color: Colors.black),
            ),
            GestureDetector(
              onTap: login,
              child: Container(
                width: 200,
                height: 60,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                            'assets/images/google_signin_button.png'),
                        fit: BoxFit.cover)),
              ),
            )
          ],
        ),
      ),
    );
  }

  void onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  void onTap(int pageIndex) {
    pageController?.animateToPage(pageIndex,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  activeCounter() {
    _resendCodeTimer =
        Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_timerDuration - timer.tick > 0) {
        _timerStream.sink.add(_timerDuration - timer.tick);
      } else {
        _timerStream.sink.add(0);
        _resendCodeTimer.cancel();
      }
    });
  }
}

enum _PositionItemType {
  log,
  position,
}

class _PositionItem {
  _PositionItem(this.type, this.displayValue);

  final _PositionItemType type;
  final String displayValue;
}
