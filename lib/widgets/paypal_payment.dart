import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:lottie/lottie.dart';
import '../helpers/Constants.dart';
import '../models/user.dart';
import '../pages/Home.dart';

class PaypalPayment extends StatelessWidget {
  final double amount;
  final String currency;

  const PaypalPayment({Key? key, required this.amount, required this.currency})
      : super(key: key);

  // final String jwt = 'eyJhbGciOiJSUzI1NiIsImtpZCI6ImQ2M2RiZTczYWFkODhjODU0ZGUwZDhkNmMwMTRjMzZkYzI1YzQyOTIiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJhY2NvdW50cy5nb29nbGUuY29tIiwiYXpwIjoiNjE4MTA0NzA4MDU0LTlyOXMxYzRhbGczNmVybGl1Y2hvOXQ1Mm4zMm42ZGdxLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwiYXVkIjoiNjE4MTA0NzA4MDU0LTlyOXMxYzRhbGczNmVybGl1Y2hvOXQ1Mm4zMm42ZGdxLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwic3ViIjoiMTAzNDM0MDEzNzc5NTU0MDU4NzA3IiwiZW1haWwiOiJuaWdhbS5uZWVydWJhbGFAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImF0X2hhc2giOiJtTHBENkd4Z0hzTVc4NXdzMldzMVZRIiwiaWF0IjoxNjQ2ODg0MTYzLCJleHAiOjE2NDY4ODc3NjMsImp0aSI6ImM1MTliMjA4YTJlZWJkYzJhOWZkYWY2OWE1ZWFjNzFhYjkwZDQwZjAifQ.lg7JzSuMAAole7rrdhERT61TFzC1qUw60v4by9jdvB_Pq2CyawMK0-uaB02PtCAxQ_R3vuJ7E0HcfZ9LkxAggoJflUYR-9fgGc2MA2EFdYIgL7J-woCMUetY1pe7TY_2vOriNV0UQ3rjtb0-HzaaaxW-6D_bbSsdInII-OAh7z7UlFOya0WEob1i3PV7I86Zn2EWdIrFD_M0AUCNGUlfvJxw1-3XCJNWVplbA5I1AAEZ3qIyvymrwqlE0-oeEw8BN9HP64j3HIQ0ZSB81iKE4HRCF2-Cw4NXl1TlM2PGgPW-eCqLTBDC3_Yk-oQRzzpRJxBRxOnyMw5YBNkgFGw8fQ';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: WebView(
        initialUrl:
            'https://us-central1-squat-c1feb.cloudfunctions.net/createPaypalPayment?amount=$amount&currency=$currency',
        javascriptMode: JavascriptMode.unrestricted,
        // onWebViewCreated: (WebViewController webViewController) {
        //         //   Map<String, String> headers = {"Authorization": "Bearer " + idToken};
        //         //   webViewController.loadUrl( 'https://us-central1-squat-c1feb.cloudfunctions.net/createPaypalPayment?amount=$amount&currency=$currency',
        //         //       headers: headers);
        //         // },
        gestureRecognizers: Set()
          ..add(Factory<DragGestureRecognizer>(
              () => VerticalDragGestureRecognizer())),
        onPageFinished: (value) {
          print('onPageFinished..');
          print(value);
        },
        navigationDelegate: (NavigationRequest request) async {
          if (request.url.contains('http://return_url/?status=success')) {
            Navigator.pop(context, 'success');
            print('return url on success');
            var donationTotal = currentUser.amountDonated + amount;

            commentsRef
                .where("userId", isEqualTo: currentUser.id)
                .get()
                .then((value){
                      WriteBatch batch = FirebaseFirestore.instance.batch();
                      for (var documentSnapshot in value.docs)
                        {
                          batch.update(commentsRef.doc(documentSnapshot.id),
                              {"isCommentMadeByDonationUser": true});
                        }

                        batch.commit();
                    });

            // Commit the batch
            usersRef
                .doc(currentUser?.id)
                .update({"amountDonated": donationTotal});

            var doc = await usersRef.doc(currentUser?.id).get();
            currentUser = User.fromDocument(doc);
          }
          if (request.url.contains('http://cancel_url')) {
            Navigator.pop(context, 'cancel');
          }
          return NavigationDecision.navigate;
        },
      ),
    );
  }
}
