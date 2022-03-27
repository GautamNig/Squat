import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../helpers/Constants.dart';
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
      return true;
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
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    amountTextEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Constants.appColor,
        title: const Center(
          child:
              Text('Help the developer!', style: Constants.appHeaderTextSTyle),
        ),
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Lottie.asset('assets/json/donategirl.json', height: MediaQuery.of(context).size.height/2),
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: TextField(
                        onChanged: (text) => setState(() => ''),
                        cursorColor: Constants.appColor,
                        keyboardType: TextInputType.number,
                        controller: amountTextEditingController,
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Constants.appColor, width: 0.0),
                          ),
                          prefixIcon: const Icon(Icons.monetization_on_outlined,
                              color: Colors.grey),
                          hintText: 'Enter amount in USD',
                          errorText:
                              isNumeric(amountTextEditingController.text) ==
                                      true
                                  ? null
                                  : 'Please enter a numeric value.',
                          contentPadding:
                              const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 0),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: ElevatedButton(
                        onPressed:
                        (isNumeric(amountTextEditingController.text) == false ||
                            amountTextEditingController.text.isNotEmpty == false)
                                ? null
                                : () async {
                                    final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PaypalPayment(
                                              amount: double.parse(
                                                  amountTextEditingController
                                                      .text),
                                              currency:
                                                  'USD' //,idToken: idToken!.token!
                                              ),
                                        ));

                                    if (result == 'success') {
                                      amountTextEditingController.clear();
                                      FocusManager.instance.primaryFocus?.unfocus();
                                      const snackBar = SnackBar(
                                          backgroundColor: Constants.appColor,
                                          content: Text(
                                              'Payment completed, Thanks for your donation!'));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                    }
                                  },
                        style: ElevatedButton.styleFrom(primary: Constants.appColor),
                        child: const Text(
                          'Donate',
                          style: Constants.appHeaderTextSTyle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Constants.createAttributionAlignWidget('Tam Doan @Lottiefiles.com')
            ],
          ),
        ],
      ),
    );
  }
}
