import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:squat/pages/comments.dart';
import 'package:rive/rive.dart';
import '../models/user.dart';
import 'create_account.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final usersRef = FirebaseFirestore.instance.collection('users');
final commentsRef = FirebaseFirestore.instance.collection('comments');
final DateTime timestamp = DateTime.now();
User? currentUser;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  PageController? pageController;
  int pageIndex = 0;
  SMIInput<bool>? _trigger;
  Artboard? _startArtBoard;
  late RiveAnimationController squatAnimationController;

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

    loadDataAsync();
  }

  Future loadDataAsync() async {

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

  static Future cacheImage(BuildContext context, String urlImage) {
    if (urlImage.isNotEmpty)
      return precacheImage(CachedNetworkImageProvider(urlImage), context);
    return Future.value();
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
        "timestamp": timestamp
      });
      doc = await usersRef.doc(user?.id).get();
    }
    currentUser = User.fromDocument(doc);
    cacheImage(context, currentUser?.photoUrl ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  Scaffold buildAuthScreen() {
    var id = currentUser == null ? '' : currentUser?.id;
    return Scaffold(
      body: SafeArea(
        child: PageView(
          children: <Widget>[
            // Timeline(),
            _startArtBoard == null
                ? const SizedBox() : Stack(
                    alignment: Alignment.center,
                    children: [
                      Rive(
                        artboard: _startArtBoard!,
                        fit: BoxFit.fill,
                      ),
                      Positioned(
                        top: 5,

                        child: ElevatedButton(onPressed: (){
                          _trigger?.value = true;
                        }, child: const Text(
                          'Squat for Ukraine',
                          style: TextStyle(
                              fontFamily: "Signatra", fontSize: 30, color: Colors.white),
                        ),),
                      )
                  ]),
            Comments(userId: id!),
            ElevatedButton(onPressed: logout, child: const Text('Logout')),
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
          BottomNavigationBarItem(icon: Icon(Icons.whatshot)),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active)),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.photo_camera,
                size: 35,
              )),
          // BottomNavigationBarItem(icon: Icon(Icons.search)),
          // BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
        ],
      ),
    );
  }

  buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //       begin: Alignment.topRight,
        //       end: Alignment.bottomLeft,
        //       colors: [
        //         Theme.of(context).primaryColor,
        //         Theme.of(context).colorScheme.secondary
        //       ]),
        // ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Squat for Ukraine',
              style: TextStyle(
                  fontFamily: "Signatra", fontSize: 90, color: Colors.white),
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