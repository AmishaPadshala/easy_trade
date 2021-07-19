import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:olx_clone/model/user.dart';
import 'package:olx_clone/utils/app_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
String _verificationId;
String phoneAccountId, phoneUserName, phoneRegToken = '';
bool isSignedInWithPhone = false;

Future<void> verifyPhoneNumber({
  @required BuildContext context,
  @required String numberToVerify,
  Function onVerificationCompleted,
  Function onVerificationFailed,
}) async {
  final PhoneVerificationCompleted verificationCompleted = (FirebaseUser user) {
    print('verificationCompleted');
    onVerificationCompleted();
  };

  final PhoneVerificationFailed verificationFailed =
      (AuthException authException) {
    print('verificationFailed: ${authException.message}');
    onVerificationFailed();
  };

  final PhoneCodeSent codeSent =
      (String verificationId, [int forceResendingToken]) async {
    _verificationId = verificationId;

    print('code sent');
  };

  final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
      (String verificationId) {
    _verificationId = verificationId;
    print('codeAutoRetrievalTimeout');
  };

  await _auth.verifyPhoneNumber(
      phoneNumber: numberToVerify,
      timeout: const Duration(seconds: 5),
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
}

Future<bool> signInWithPhoneNumber(BuildContext context, String smsCode) async {
  try {
    final FirebaseUser user = await _auth.signInWithPhoneNumber(
      verificationId: _verificationId,
      smsCode: smsCode,
    );

    final FirebaseUser currentUser = await _auth.currentUser();

    if (currentUser != null && user.uid == currentUser.uid) {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      await preferences.setString(SELECTED_ACCOUNT_KEY, PHONE);
      await preferences.setString(
          PHONE_ACCOUNT_ID_KEY, currentUser.phoneNumber);
      await preferences.setBool(IS_SIGNED_IN_WITH_PHONE_KEY, true);

      await Firestore.instance
          .collection(USERS_COLLECTION)
          .where(ACCOUNT_ID, isEqualTo: currentUser.phoneNumber)
          .getDocuments()
          .then((QuerySnapshot snapshots) {
        if (snapshots.documents.isEmpty) {
          // Add user in server
          Firestore.instance
              .collection(USERS_COLLECTION)
              .document(currentUser.phoneNumber)
              .setData(
                User(
                  accountId: currentUser.phoneNumber,
                  accountType: PHONE,
                  displayName: phoneUserName,
                  email: '',
                  loginStatus: LOGGED_IN,
                  registrationToken: '',
                ).toMap(),
              );
        } else {
          // Update user in server
          Firestore.instance
              .collection(USERS_COLLECTION)
              .document(currentUser.phoneNumber)
              .updateData(
                User(
                  accountId: currentUser.phoneNumber,
                  accountType: PHONE,
                  displayName: phoneUserName,
                  email: '',
                  loginStatus: LOGGED_IN,
                  registrationToken: '',
                ).toMap(),
              );
        }
      });

      isSignedInWithPhone = true;

      return true;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}
