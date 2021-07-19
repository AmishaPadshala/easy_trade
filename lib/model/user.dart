import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:olx_clone/utils/app_utils.dart';

class User {
  final accountId, accountType, displayName, email, loginStatus;
  var registrationToken;

  User({
    @required this.accountId,
    @required this.accountType,
    @required this.displayName,
    @required this.email,
    @required this.loginStatus,
    @required this.registrationToken,
  });

  User.fromDocument(DocumentSnapshot document)
      : accountId = document[ACCOUNT_ID],
        accountType = document[ACCOUNT_TYPE],
        displayName = document[DISPLAY_NAME],
        email = document[EMAIL],
        loginStatus = document[LOGIN_STATUS],
        registrationToken = document[REGISTRATION_TOKEN];

  User.fromMap(Map document)
      : accountId = document[ACCOUNT_ID],
        accountType = document[ACCOUNT_TYPE],
        displayName = document[DISPLAY_NAME],
        email = document[EMAIL],
        loginStatus = document[LOGIN_STATUS],
        registrationToken = document[REGISTRATION_TOKEN];

  Map<String, dynamic> toMap() {
    return {
      ACCOUNT_ID: accountId,
      ACCOUNT_TYPE: accountType,
      DISPLAY_NAME: displayName,
      EMAIL: email,
      LOGIN_STATUS: loginStatus,
      REGISTRATION_TOKEN: registrationToken,
    };
  }
}
