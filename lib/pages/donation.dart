import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:squat/json_parsers/json_parser_firebase_appSettings.dart';

import '../widgets/paypal_payment.dart';
import 'Home.dart';

class Donation extends StatefulWidget {
  const Donation({Key? key}) : super(key: key);

  @override
  State<Donation> createState() => _DonationState();
}

class _DonationState extends State<Donation> {

  late TextEditingController amountTextEditingController;

  bool isNumeric(String s) {
    if (s.isEmpty) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    amountTextEditingController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Center(child: const Text('Paypal Payment')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text('Help the developer.', style: TextStyle(fontSize: 50,
                fontFamily: "Signatra", color: Colors.teal),),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: TextField(
                onChanged: (text) => setState(() => ''),
                controller: amountTextEditingController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.monetization_on_outlined, color: Colors.grey),
                  hintText: 'Payment in USD',
                  errorText: isNumeric(amountTextEditingController.text) == true ? null : 'Please enter a numeric value to donate.',
                  contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0,0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: TextButton(
                onPressed: isNumeric(amountTextEditingController.text) == false ? null : () async{
                  // var doc = await settingsRef.doc('appSettings').get();
                  // Configuration config = Configuration.fromJson(doc.data()!);
                  //
                  // var result = await FirebaseAuth.instance.signInWithCustomToken(config.appSettings!.customToken!.first!);
                  // var idToken = await result.user?.getIdTokenResult(true);
                  //
                  //
                  // print('Token Id');
                  // print(idToken?.token);

                  // String idTok = 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1aWQiOiIxMDM0MzQwMTM3Nzk1NTQwNTg3MDciLCJjbGFpbXMiOnsicHJlbWl1bUFjY291bnQiOnRydWUsIm1heEFnZSI6MzYwMH0sImlzcyI6ImZpcmViYXNlLWFkbWluc2RrLTR0am9nQHNxdWF0LWMxZmViLmlhbS5nc2VydmljZWFjY291bnQuY29tIiwic3ViIjoiZmlyZWJhc2UtYWRtaW5zZGstNHRqb2dAc3F1YXQtYzFmZWIuaWFtLmdzZXJ2aWNlYWNjb3VudC5jb20iLCJhdWQiOiJodHRwczovL2lkZW50aXR5dG9vbGtpdC5nb29nbGVhcGlzLmNvbS9nb29nbGUuaWRlbnRpdHkuaWRlbnRpdHl0b29sa2l0LnYxLklkZW50aXR5VG9vbGtpdCIsImV4cCI6MTY0Njk5NTAyMiwiaWF0IjoxNjQ2OTkxNDIyfQ.LJh0feTKbl_GxlBjE8olRkW_HVqHQmzj6zB9owoxbprGvzOHvtBcCBZZX4Ew1LtpZSQLRTXJ0AlUcjTwmPqVVaN4q754m4W3BkxKfEmFapttebQTmVDPu-9QYc6wW5P9TZgwe_GBMwvk4zhovA59H2LjqABGhtqRY_8Zj66NDqq4C1z7FEi2D_0c0xxMlx2CseOXpyA5VJqefh4guw66s-BJDdibmNonYS_w_oIhi28j8V9EmyPzk5iB2DyC6WmYXU5Bler7zDqcmBpSAjyA-ligshSRdfRHWL0GqsEMnRBSsXO1B0y5Q5vJBvwlBaXMEBgm1EtRmzCQuvNiyYJ-Yw';

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaypalPayment(
                          amount: double.parse(amountTextEditingController.text),
                          currency: 'USD'//,idToken: idToken!.token!
                        ),
                      ));
                },
                style: ButtonStyle(
                  backgroundColor:
                  MaterialStateProperty.resolveWith((states) => Colors.blue),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Image(
                      image: AssetImage('assets/images/paypal.png'),
                      height: 40,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      'Pay with Paypal',
                      style: TextStyle(color: Colors.black),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}