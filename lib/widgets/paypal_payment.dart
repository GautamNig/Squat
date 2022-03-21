import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/user.dart';
import '../pages/Home.dart';

class PaypalPayment extends StatelessWidget {
  final double amount;
  final String currency;

  const PaypalPayment({Key? key, required this.amount, required this.currency})
      : super(key: key);

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
        gestureRecognizers: Set()
          ..add(Factory<DragGestureRecognizer>(
              () => VerticalDragGestureRecognizer())),
        onPageFinished: (value) {
        },
        navigationDelegate: (NavigationRequest request) async {
          if (request.url.contains('http://return_url/?status=success')) {
            Navigator.pop(context, 'success');
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
