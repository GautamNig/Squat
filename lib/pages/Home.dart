import 'dart:async';
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
import 'package:rive/rive.dart';
import 'package:squat/pages/comments.dart';
import 'package:squat/pages/donation.dart';
import 'package:squat/pages/squat_stat.dart';
import 'package:squat/pages/squatters.dart';
import '../helpers/Constants.dart';
import '../models/user.dart';
import 'create_account.dart';
import 'package:badges/badges.dart';
import 'package:odometer/odometer.dart';
import 'package:audioplayers/audioplayers.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final usersRef = FirebaseFirestore.instance.collection('users');
final commentsRef = FirebaseFirestore.instance.collection('comments');
// final squatsRef = FirebaseFirestore.instance.collection('squats');
// final settingsRef = FirebaseFirestore.instance.collection('settings');

late User currentUser;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  bool isAuth = false;
  String squatLocality = '';
  String squatCountry = '';
  PageController? pageController;
  int pageIndex = 0;
  SMIInput<bool>? _trigger;
  Artboard? _startArtBoard;
  late RiveAnimationController squatAnimationController;
  int squatersCount = 0;
  num totalGlobalSquatCount = 0;
  bool isClicked = false;

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

  static const _timerDuration = 5;
  StreamController _timerStream = StreamController<int>();
  int timerCounter = 0;
  late Timer _resendCodeTimer;
  AudioCache audioCache = AudioCache();

  // Usually we dispose the stuff created in init.
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    pageController?.dispose();
    animationController?.dispose();
    _timerStream.close();
    _resendCodeTimer.cancel();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    activeCounter();
    animationController =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
    animation =
        OdometerTween(begin: OdometerNumber(10000), end: OdometerNumber(12000))
            .animate(
      CurvedAnimation(curve: Curves.easeIn, parent: animationController!),
    );

    pageController = PageController();
    // Detects when user signed in
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
    });

    // Re-authenticate user when app is opened
    googleSignIn
        .signInSilently(suppressErrors: false)
        .then((account) => handleSignIn(account))
        .catchError((err) {
    });

    usersRef.snapshots().listen((querySnapshot) {
       var squattersList =  querySnapshot.docs
          .map((doc) => User.fromDocument(doc).squatCount);

       squatersCount = squattersList.where((element) => element > 0).length;

       num sum = 0;
       for (num e in squattersList) {
         sum += e;
       }
        totalGlobalSquatCount = sum;
    });

    getLocationAndSetupRive();
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
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    squatLocality = placemark.locality ?? '';
    squatCountry = placemark.country ?? '';
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
    await googleSignIn.signIn().then((result) {
    }).catchError((err) {
      print('error occured');
    });
    EasyLoading.dismiss();
  }

  logout() {
    googleSignIn.signOut();
  }

  createUserInFirestore() async {
    // 1) check if user exists in users collection in database (according to their id)
    final GoogleSignInAccount? user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.doc(user?.id).get();

    if (!doc.exists) {
      // 2) if the user doesn't exist, then we want to take them to the create account page
      final username = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));

      // 3) get username from create account, use it to make new user document in users collection
      usersRef.doc(user?.id).set({
        "id": user?.id,
        "username": username,
        "photoUrl": user?.photoUrl,
        "email": user?.email,
        "displayName": user?.displayName,
        "bio": "",
        "hasSquated": false,
        "amountDonated": 0,
        "squatCount": 0,
        "locality": squatLocality,
        "country": squatCountry,
        "lastSquatTime": DateTime.now(),
      });
      doc = await usersRef.doc(user?.id).get();
    }
    currentUser = User.fromDocument(doc);
    cacheImage(context, currentUser.photoUrl ?? '');
  }

  void _updatePositionList(_PositionItemType type, String displayValue) {
    _positionItems.add(_PositionItem(type, displayValue));
    setState(() {});
  }

  static Future cacheImage(BuildContext context, String urlImage) {
    if (urlImage.isNotEmpty)
      return precacheImage(CachedNetworkImageProvider(urlImage), context);
    return Future.value();
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      body: SafeArea(
          child: StreamBuilder(
              stream: _timerStream.stream,
              builder: (BuildContext ctx, AsyncSnapshot snapshot) {
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
                            Positioned(
                              top: 5,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Constants.appColor,shadowColor: Colors.white,
                                  elevation: 25,),
                                onPressed: snapshot.data == 0
                                    ? () async {
                                        _trigger?.value = true;
                                        currentUser.squatCount++;
                                        Future.delayed(const Duration(milliseconds: 1400), ()
                                        {
                                          audioCache.play('grunt.mp3');
                                        });
                                        await usersRef
                                            .doc(currentUser?.id)
                                            .update({
                                          "hasSquated": true,
                                          "squatCount": currentUser.squatCount,
                                          "lastSquatTime": DateTime.now()
                                        });
                                        var doc = await usersRef
                                            .doc(googleSignIn.currentUser?.id)
                                            .get();
                                        _timerStream.sink.add(5);
                                        activeCounter();
                                        setState(() {
                                          currentUser = User.fromDocument(doc);
                                        });
                                      }
                                    : null,
                                child: Center(
                                    child: snapshot.data == 0
                                        ? const Text('Squat for Ukraine', style: Constants.appHeaderTextSTyle,)
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                  'Resting for ${snapshot.hasData ? snapshot.data.toString() : 5} sec'),
                                            ],
                                          )),
                              ),
                            ),
                            Positioned(
                              top: 5,
                              right: 2,
                              child: IconButton(
                                onPressed: () {
                                  googleSignIn.signOut();
                                },
                                icon: const Icon(
                                  Icons.logout_sharp,
                                  color: Constants.appColor,
                                ),
                              ),
                            ),
                            Positioned(
                              top: MediaQuery.of(context).size.height * 0.60,
                              left: 5,
                              child: Column(
                                children: [
                                  Card(
                                    shape: BeveledRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    color: Constants.appColor,
                                    child: Container(
                                      height: 60,
                                      width: 60,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            AnimatedSlideOdometerNumber(
                                              letterWidth: 18,
                                              odometerNumber: OdometerNumber(
                                                  currentUser.squatCount),
                                              duration: const Duration(seconds: 1),
                                              numberTextStyle: const TextStyle(
                                                  fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
                                            ),
                                            const Text('SQUATS', style: TextStyle(color: Colors.white, fontSize: 10),)
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                ],
                              ),
                            ),
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.60,
                        right: 5,
                        child: Column(
                          children: [
                            Card(
                              shape: BeveledRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              color: Constants.appColor,
                              child: Container(
                                height: 60,
                                width: 60,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AnimatedSlideOdometerNumber(
                                        letterWidth: 18,
                                        odometerNumber: OdometerNumber(
                                            totalGlobalSquatCount.toInt()),
                                        duration: const Duration(seconds: 1),
                                        numberTextStyle: const TextStyle(
                                            fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                      const Text('WORLD SQUATS', style: TextStyle(color: Colors.white, fontSize: 7),)
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                            Constants.createAttributionAlignWidget('Lumberjack Squats by Dante @rive.app')
                          ]),
                    Comments(userId: currentUser.id),
                    Squaters(),
                    SquatStat(),
                    Donation()
                    // ActivityFeed(),
                    // Upload(currentUser:currentUser),
                    // Search(),
                    // Profile(profileId: currentUser.id ?? '')
                  ],
                  controller: pageController,
                  onPageChanged: onPageChanged,
                  physics: const NeverScrollableScrollPhysics(),
                );
              })),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Theme.of(context).primaryColor,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.whatshot),
          ),
          const BottomNavigationBarItem(
              icon: Icon(
            Icons.comment_bank_outlined,
          )),
          BottomNavigationBarItem(
            icon: Badge(
              child: const Icon(Icons.list_alt),
              shape: BadgeShape.square,
              position: BadgePosition.bottomEnd(bottom: -15),
              badgeContent: Text(
                NumberFormat.compact().format(squatersCount),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.stacked_bar_chart)),
          const BottomNavigationBarItem(
              icon: Icon(Icons.monetization_on_sharp)),
          // BottomNavigationBarItem(icon: Icon(Icons.search)),
          // BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
        ],
      ),
    );
  }

  buildUnAuthScreen() {
    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Image.asset('assets/images/soilder.jpg'),
            const Text(
              'Squat for Ukraine',
              style: Constants.appHeaderTextSTyle,
            ),
            GestureDetector(
              onTap: login,
              child: Container(
                width: 260,
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
