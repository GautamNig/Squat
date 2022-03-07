import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rive/rive.dart';
import 'package:squat/pages/comments.dart';
import 'package:squat/pages/payment.dart';
import 'package:squat/pages/squat_stat.dart';
import 'package:squat/pages/squats.dart';
import '../models/user.dart';
import 'create_account.dart';
import 'package:badges/badges.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final usersRef = FirebaseFirestore.instance.collection('users');
final commentsRef = FirebaseFirestore.instance.collection('comments');
final squatsRef = FirebaseFirestore.instance.collection('squats');
final DateTime timestamp = DateTime.now();

late User currentUser;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  String squatLocality = '';
  String squatCountry = '';
  PageController? pageController;
  int pageIndex = 0;
  SMIInput<bool>? _trigger;
  Artboard? _startArtBoard;
  late RiveAnimationController squatAnimationController;
  int squatCount = 0;

  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  final List<_PositionItem> _positionItems = <_PositionItem>[];
  bool positionStreamStarted = false;

  static const String _kLocationServicesDisabledMessage =
      'Location services are disabled.';
  static const String _kPermissionDeniedMessage = 'Permission denied.';
  static const String _kPermissionDeniedForeverMessage =
      'Permission denied forever.';
  static const String _kPermissionGrantedMessage = 'Permission granted.';

  // Usually we dispose the stuff created in init.
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    pageController?.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageController = PageController();
    // Detects when user signed in
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      print('Error signing in : $err');
    });

    // Re-authenticate user when app is opened
    googleSignIn
        .signInSilently(suppressErrors: false)
        .then((account) => handleSignIn(account))
        .catchError((err) {
      print('Error signing in : $err');
    });

    usersRef.snapshots().listen((querySnapshot) {
      squatCount = querySnapshot.docs.where((doc) => User.fromDocument(doc).hasSquated == true).length;
    });

    getLocationAndSetupRive();
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

  login() {
    googleSignIn.signIn();
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
        "timestamp": timestamp,
        "hasSquated": false,
      });
      doc = await usersRef.doc(user?.id).get();
    }
    currentUser = User.fromDocument(doc);
    cacheImage(context, currentUser?.photoUrl ?? '');
  }

  addSquat() {
    squatsRef.add({
      "username": currentUser?.username,
      "timestamp": timestamp,
      "avatarUrl": currentUser?.photoUrl,
      "userId": currentUser?.id,
      "locality": squatLocality.isEmpty ? 'Unknown' : squatLocality,
      "country": squatCountry.isEmpty ? 'Unknown' : squatCountry,
    });
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
    var id = currentUser == null ? '' : currentUser?.id;
    return Scaffold(
      body: SafeArea(
        child: PageView(
          children: <Widget>[
            // Timeline(),
            _startArtBoard == null
                ? const SizedBox()
                : Stack(alignment: Alignment.center, children: 
                  [
                    Rive(
                      artboard: _startArtBoard!,
                      fit: BoxFit.fill,
                    ),
                    Positioned(
                      top: 5,
                      child: ElevatedButton(
                        onPressed: currentUser.hasSquated ? null : () async {
                          _trigger?.value = true;
                          addSquat();
                          await usersRef
                              .doc(currentUser?.id)
                              .update({"hasSquated": true});
                          var doc = await usersRef.doc(googleSignIn.currentUser?.id).get();
                          setState(() {
                            currentUser = User.fromDocument(doc);
                          });
                        },
                        child: const Text(
                          'Squat for Ukraine',
                          style: TextStyle(
                              fontFamily: "Signatra",
                              fontSize: 30,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 2,
                      child: IconButton(
                        onPressed: () {
                          googleSignIn.signOut();
                        },
                        icon: const Icon(Icons.logout_sharp),
                      ),
                    ),
                    Positioned(
                      bottom: 2,
                      child: Text('Lumberjack Squats by Dante @rive.app', style: TextStyle(color: Colors.black,
                      fontSize: 8),)
                    ),
                  ]),
            Comments(userId: id!),
            Squats(),
            SquatStat(),
            Payment()
            // ActivityFeed(),
            // Upload(currentUser:currentUser),
            // Search(),
            // Profile(profileId: currentUser?.id ?? '')
          ],
          controller: pageController,
          onPageChanged: onPageChanged,
          physics: const NeverScrollableScrollPhysics(),
        ),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(icon: Badge(child: Icon(Icons.whatshot),
              shape: BadgeShape.square,
              position: BadgePosition.bottomEnd(bottom: -15),
              badgeContent:
          Text(squatCount.toString(), style: const TextStyle(color: Colors.white),))),
          BottomNavigationBarItem(
              icon: Icon(
            Icons.comment_bank_outlined,
            size: 35,
          )),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active)),
          BottomNavigationBarItem(icon: Icon(Icons.stacked_bar_chart)),
          BottomNavigationBarItem(icon: Icon(Icons.monetization_on_sharp)),
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
              style: TextStyle(
                  fontFamily: "Signatra", fontSize: 70, color: Colors.black),
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
