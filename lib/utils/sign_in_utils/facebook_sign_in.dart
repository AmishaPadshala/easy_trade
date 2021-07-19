import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:olx_clone/model/user.dart';
import 'package:olx_clone/utils/app_utils.dart';
import 'package:olx_clone/utils/sign_in_utils/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

FirebaseUser firebaseUserFacebook;
FacebookLogin facebookLogin;
String _facebookAccessToken = '';
String facebookUserName = '';
String facebookEmailID = '';
String facebookAccessToken;
String facebookRegToken;
String facebookProfileUrl = '';
bool isSignedInWithFacebook = false;

SharedPreferences preferences;

Future<bool> isLoggedInWithFacebook() async {
  preferences = await SharedPreferences.getInstance();
  facebookLogin = new FacebookLogin();
  facebookLogin.loginBehavior = FacebookLoginBehavior.nativeOnly;

  await Firestore.instance
      .collection(USERS_COLLECTION)
      .document(preferences.getString(FACEBOOK_ACCESS_TOKEN_KEY))
      .get()
      .then((document) {
    if (document.exists && document.data[LOGIN_STATUS] == LOGGED_IN) {
      print('Already logged in as: ${preferences.getString(
          'FACEBOOK_USER_NAME')}');
      isSignedInWithFacebook = true;
      return isSignedInWithFacebook;
    }
  });
  return isSignedInWithFacebook;
}

Future<FirebaseUser> signInWithFacebook(BuildContext context) async {
  facebookLogin = new FacebookLogin();
  facebookLogin.loginBehavior = FacebookLoginBehavior.webOnly;
  var result = await facebookLogin.logInWithReadPermissions(['email']);

  switch (result.status) {
    case FacebookLoginStatus.loggedIn:
      firebaseUserFacebook =
          await auth.signInWithFacebook(accessToken: result.accessToken.token);

      _facebookAccessToken = result.accessToken.token;
      facebookUserName = firebaseUserFacebook.displayName;
      facebookEmailID = firebaseUserFacebook.email;
      facebookProfileUrl = firebaseUserFacebook.photoUrl;
      print("Signed in as ${firebaseUserFacebook.displayName}");

      preferences = await SharedPreferences.getInstance();
      await preferences.setString(
          FACEBOOK_ACCESS_TOKEN_KEY, result.accessToken.token);
      await preferences.setString(FACEBOOK_USERNAME_KEY, facebookUserName);
      await preferences.setString(FACEBOOK_EMAIL_ID_KEY, facebookEmailID);
      await preferences.setString(FACEBOOK_PROFILE_URL_KEY, facebookProfileUrl);
      await preferences.setBool(IS_SIGNED_IN_WITH_FACEBOOK_KEY, true);

      isSignedInWithFacebook = true;

      // Add user in server
      Firestore.instance
          .collection(USERS_COLLECTION)
          .document(_facebookAccessToken)
          .setData(
            User(
              accountId: result.accessToken.token,
              accountType: FACEBOOK,
              displayName: facebookUserName,
              email: facebookEmailID,
              loginStatus: LOGGED_IN,
              registrationToken: '',
            ).toMap(),
          );
      return firebaseUserFacebook;

    case FacebookLoginStatus.cancelledByUser:
      return null;

    case FacebookLoginStatus.error:
      print(
          'Unable to sign into your facebook account. ${result.errorMessage}');
      return null;
    default:
      return null;
  }
}

logoutFromFacebook() async {
  facebookLogin = new FacebookLogin();
  facebookLogin.logOut();
  auth.signOut();
  preferences = await SharedPreferences.getInstance();
  await preferences.setBool(IS_SIGNED_IN_WITH_FACEBOOK_KEY, false);

  isSignedInWithFacebook = false;
  Firestore.instance.runTransaction((transaction) async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    String token = preference.getString(FACEBOOK_ACCESS_TOKEN_KEY);
//    Firestore.instance.collection(USERS_COLLECTION).document(token).delete();
    await transaction.delete(
        Firestore.instance.collection(USERS_COLLECTION).document(token));
  });
}
