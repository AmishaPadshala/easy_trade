import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:olx_clone/model/order.dart';
import 'package:olx_clone/model/user.dart';
import 'package:olx_clone/utils/app_utils.dart';
import 'package:olx_clone/utils/sign_in_utils/facebook_sign_in.dart';
import 'package:olx_clone/utils/sign_in_utils/google_sign_in.dart';

void sendOrderCompleteNotificationToSeller(List<Order> orderList) async {
  String registrationToken = await _getSellerRegistrationToken();
  var body = '{"notification": {"body": "${_formNotificationBody(
      orderList)}"}, "data": {"click_action": "FLUTTER_NOTIFICATION_CLICK"}, '
      '"to": "$registrationToken"}';
  http.Response res = await http.post(FCM_MESSAGE_URL, body: body, headers: {
    'Authorization': 'key=$SERVER_KEY',
    'Content-Type': 'application/json'
  });
  print('Response: ${res.body}');
}

Future<String> _getSellerRegistrationToken() async {
  String registrationToken;
  await Firestore.instance
      .collection(USERS_COLLECTION)
      .document('111153882638691938175')
      .get()
      .then((snapshot) {
    if (snapshot.exists) {
      User user = User.fromMap(snapshot.data);

      registrationToken = user.registrationToken;
    }
  });

  return registrationToken;
}

String _formNotificationBody(List<Order> orderList) {
  List<String> itemNameAndQty = [];
  String body;

  for (Order order in orderList) {
    itemNameAndQty
        .add('${order.orderedQuantity} ${order.orderedQuantity > 1 ? order
        .priceUnit + "s" : order.priceUnit} of ${order.productName}');
  }

  body = '${googleUserName ?? facebookUserName} ordered';
  for (String nameAndQty in itemNameAndQty) {
    body += '\n' + nameAndQty;
  }

  return body;
}
