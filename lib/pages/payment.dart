// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_braintree/flutter_braintree.dart';
// import 'package:http/http.dart' as http;
//
// import '../widgets/header.dart';
//
// class Payment extends StatefulWidget {
//   const Payment({Key? key}) : super(key: key);
//
//   @override
//   State<Payment> createState() => _PaymentState();
// }
//
// class _PaymentState extends State<Payment> {
//
//   late TextEditingController amountTextEditingController;
//   String url = 'https://us-central1-squat-c1feb.cloudfunctions.net/paypalPayment';
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     amountTextEditingController = TextEditingController();
//   }
//
//   void onGooglePayResult(paymentResult) {
//     // Send the resulting Google Pay token to your server / PSP
//   }
//
//   bool isNumeric(String s) {
//     if (s.isEmpty) {
//       return false;
//     }
//     return double.tryParse(s) != null;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         appBar: header(context, titleText: "Donate"),
//         body: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             const Text('Help the developer.', style: TextStyle(fontSize: 50,
//               fontFamily: "Signatra", color: Colors.teal),),
//           Padding(
//             padding: const EdgeInsets.all(18.0),
//             child: TextField(
//               onChanged: (text) => setState(() => ''),
//               controller: amountTextEditingController,
//               decoration: InputDecoration(
//                 prefixIcon: const Icon(Icons.monetization_on_outlined, color: Colors.grey),
//                 hintText: 'Payment in USD',
//                 errorText: isNumeric(amountTextEditingController.text) == true ? null : 'Please enter a numeric value to donate.',
//                 contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0,0),
//               ),
//             ),
//           ),
//           ElevatedButton(onPressed: isNumeric(amountTextEditingController.text) == false ? null :() async{
//             var request = BraintreeDropInRequest(
//               tokenizationKey: 'sandbox_7b3tw3qt_qr37trqc9mxpmkd9',
//               collectDeviceData: true,
//               paypalRequest: BraintreePayPalRequest(amount: amountTextEditingController.text, displayName: 'App Theatre')
//             );
//
//             BraintreeDropInResult? result = await BraintreeDropIn.start(request);
//             if(result != null){
//                print('PaymentMethodNonce description: ${result.paymentMethodNonce.description}');
//                print('PaymentMethodNonce nonce: ${result.paymentMethodNonce.nonce}');
//
//                Map data = {
//                  'amt': amountTextEditingController.text,
//                  'payment_method_nonce': result.paymentMethodNonce.nonce,
//                  'device_data': result.deviceData
//                };
//                final http.Response response = await http.post(Uri.parse(url), body: data);
//
//                final payResult = jsonDecode(response.body);
//                print(payResult['result']);
//                if(payResult['result'] == 'success'){
//                   print('Payment done.');
//                }
//             }
//           }, child: const Text('Pay'))
//         ],),
//       ),
//     );
//   }
// }
