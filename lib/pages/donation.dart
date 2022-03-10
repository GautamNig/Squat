import 'package:flutter/material.dart';

import '../widgets/paypal_payment.dart';

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
                onPressed: () {
                  // lets assume that product price is 5.99 usd
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaypalPayment(
                          amount: double.parse(amountTextEditingController.text),
                          currency: 'USD',
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