const functions = require("firebase-functions");
const admin = require("firebase-admin");
const paypal = require("paypal-rest-sdk");
const {SecretManagerServiceClient} = require('@google-cloud/secret-manager');

admin.initializeApp();

let getSecret = async function (secretName) {
    try {
        if (!secretName) {
            throw new TypeError('secretName argument is required to getSecret()');
        }

        if (typeof secretName !== 'string') {
            throw new TypeError('secretName must be a string to getSecret()');
        }

        // Instantiates a client
        console.info('Creating a SecretManagerServiceClient')
        const client = new SecretManagerServiceClient();

        console.info('Calling a accessSecretVersion')
        const [version] = await client.accessSecretVersion({
            name: secretName,
        });

        // Extract the payload as a string.
        const payload = version.payload.data.toString();

        return { Payload: payload }

    } catch (error) {
        error.name = "SecretAccessError"
        console.error(error)
        throw error;
    }
}

exports.createPaypalPayment = functions.https.onRequest( async (req, res) => {
    const amount = req.query.amount;
    const currency = req.query.currency.toUpperCase();

    let result = await getSecret('projects/256669154700/secrets/PAYPAL_SECRET/versions/latest');

    paypal.configure({
        'mode': 'sandbox',
        'client_id': functions.config().paypal.key,
        'client_secret': result.Payload
    });

    var create_payment_json = {
        "intent": "sale",
        "payer": {
            "payment_method": "paypal"
        },
        /// Return url which will be executed once the intent is created.
        /// "https://us-central1-paypal.cloudfunctions.net/paypalTestPaymentExecute",
        ///
		"note_to_payer": "Thank you for your donation.",
        "redirect_urls": {
            "return_url": `https://us-central1-squat-c1feb.cloudfunctions.net/execute?amount=${amount}&currency=${currency}`,
            "cancel_url": "http://cancel.url"
        },
        "transactions": [{
            "item_list": {
                "items": [{
                    "name": "dontation",
					"description": "dontation",
                    "sku": "1",
                    "price": amount,
                    "currency": currency,
                    "quantity": 1
                }]
            },
            "amount": {
                "currency": currency,
                "total": amount
            },
            "description": "Donation for the developer."
        }]
    };

    paypal.payment.create(create_payment_json, function (error, payment) {
        if (error) {
            console.log(error);
            throw error;
        } else {
            console.log('create payment response');
            console.log(payment);
            for (var index = 0; index < payment.links.length; index++) {
                if (payment.links[index].rel === 'approval_url') {
                    res.redirect(payment.links[index].href);
                }
            }
        }
    });
 });
 
exports.execute = functions.https.onRequest( async (req, res) => {
	const amount = req.query.amount;
    const currency = req.query.currency.toUpperCase();

    let result = await getSecret('projects/256669154700/secrets/PAYPAL_SECRET/versions/1');

    paypal.configure({
            'mode': 'sandbox',
            'client_id': functions.config().paypal.key,
            'client_secret': result.Payload
        });

    var execute_payment_json = {
        "payer_id": req.query.PayerID,
        "transactions": [{
            "amount": {
                "currency": currency,
                "total": amount
            }
        }]
    };
    const paymentId = req.query.paymentId;
    paypal.payment.execute(paymentId, execute_payment_json, function (error, payment) {
        if (error) {
            console.log('ERROR--------->');
            console.log(error);
            throw error;
        } else {
            console.log(JSON.stringify(payment));
            res.redirect("http://return_url/?status=success&id=" + payment.id + "&state=" + payment.state);
        }
    });
 });

//exports.onCreateSquat = functions.firestore
//    .document('squats/{squatId}')
//    .onCreate(async (snapshot, context) => {
//           functions.logger.log("Snapshot Data UserId", snapshot.data().userId);
//           const userId = snapshot.data().userId;
//           const userRef = admin.firestore().doc(userId);
//           const doc = await userRef.get()
//
//           // 2) Once we have user, check if they have a notification token; send notification, if they have a token
//           const androidNotificationToken = doc.data().androidNotificationToken;
//           const createdSquatItem = snapshot.data();
//           if (androidNotificationToken) {
//             sendNotification(androidNotificationToken, createdSquatItem);
//           } else {
//             console.log("No token for user, cannot send notification");
//           }
//
//           function sendNotification(androidNotificationToken, squat) {
//             let body = `${userRef.displayName} performed a squat at ${squat.locality}, ${squat.country}`;
//
//             // 4) Create message for push notification
//             const message = {
//               notification: { body },
//               token: androidNotificationToken,
//               data: { recipient: userId }
//             };
//
//             // 5) Send message with admin.messaging()
//             admin
//               .messaging()
//               .send(message)
//               .then(response => {
//                 // Response is a message ID string
//                 functions.logger.log("Successfully sent message", response);
//               })
//               .catch(error => {
//                 functions.logger.log("Error sending message", error);
//               });
//           }
//    });
