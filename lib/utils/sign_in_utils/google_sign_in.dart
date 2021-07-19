import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:olx_clone/model/user.dart';
import 'package:olx_clone/utils/app_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

GoogleSignIn googleSignIn = new GoogleSignIn();
GoogleSignInAccount currentUser;
final FirebaseAuth auth = FirebaseAuth.instance;
FirebaseUser firebaseUserGoogle;
String googleUserName = '';
String googleEmailID = '';
String googleProfileUrl = '';
String googleAccountId;
String googleRegToken;
bool isSignedInWithGoogle = false;
SharedPreferences preferences;

Future<FirebaseUser> signInWithGoogle() async {
  try {
    preferences = await SharedPreferences.getInstance();

    currentUser = await googleSignIn.signInSilently();
    if (currentUser == null) {
      // No previous sign in
      currentUser = await googleSignIn.signIn();
    }
    GoogleSignInAuthentication googleAuth = await currentUser.authentication;
    firebaseUserGoogle = await auth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    googleUserName = firebaseUserGoogle.displayName;
    googleEmailID = firebaseUserGoogle.email;
    googleProfileUrl = firebaseUserGoogle.photoUrl;
    print("Signed in as ${firebaseUserGoogle.displayName}");

    await preferences.setString(GOOGLE_ACCOUNT_ID_KEY, currentUser.id);
    await preferences.setString(GOOGLE_USERNAME_KEY, googleUserName);
    await preferences.setString(GOOGLE_EMAIL_ID_KEY, googleEmailID);
    await preferences.setString(GOOGLE_PROFILE_URL_KEY, googleProfileUrl);
    await preferences.setBool(IS_SIGNED_IN_WITH_GOOGLE_KEY, true);

    await Firestore.instance
        .collection(USERS_COLLECTION)
        .where(EMAIL, isEqualTo: googleEmailID)
        .getDocuments()
        .then((QuerySnapshot snapshots) {
      if (snapshots.documents.isEmpty) {
        // Add user in server
        Firestore.instance
            .collection(USERS_COLLECTION)
            .document(currentUser.id)
            .setData(
              User(
                accountId: currentUser.id,
                accountType: GOOGLE,
                displayName: googleUserName,
                email: googleEmailID,
                loginStatus: LOGGED_IN,
                registrationToken: '',
              ).toMap(),
            );
      } else {
        // Update user in server
        Firestore.instance
            .collection(USERS_COLLECTION)
            .document(currentUser.id)
            .updateData(
              User(
                accountId: currentUser.id,
                accountType: GOOGLE,
                displayName: googleUserName,
                email: googleEmailID,
                loginStatus: LOGGED_IN,
                registrationToken: '',
              ).toMap(),
            );
      }
    });

    isSignedInWithGoogle = true;
    return firebaseUserGoogle;
  } catch (e) {
    print(e);
    return null;
  }
}

Future<FirebaseUser> signInWithGoogleSilently() async {
  preferences = await SharedPreferences.getInstance();
  currentUser = await googleSignIn.signInSilently();
  if (currentUser != null) {
    GoogleSignInAuthentication googleAuth = await currentUser.authentication;
    firebaseUserGoogle = await auth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    googleUserName = firebaseUserGoogle.displayName;
    googleEmailID = firebaseUserGoogle.email;
    googleProfileUrl = firebaseUserGoogle.photoUrl;
    print("Signed in as ${firebaseUserGoogle.displayName}");

    await preferences.setString(GOOGLE_USERNAME_KEY, googleUserName);
    await preferences.setString(GOOGLE_EMAIL_ID_KEY, googleEmailID);
    await preferences.setString(GOOGLE_PROFILE_URL_KEY, googleProfileUrl);
    await preferences.setBool(IS_SIGNED_IN_WITH_GOOGLE_KEY, true);

    isSignedInWithGoogle = true;
    return firebaseUserGoogle;
  } else {
    return null;
  }
}

logoutFromGoogle() async {
  preferences = await SharedPreferences.getInstance();
  googleSignIn.signOut();
  auth.signOut();
  await preferences.setBool(IS_SIGNED_IN_WITH_GOOGLE_KEY, false);

  isSignedInWithGoogle = false;

  Firestore.instance.runTransaction((transaction) async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    String id = preference.getString(GOOGLE_ACCOUNT_ID_KEY);
    await transaction
        .delete(Firestore.instance.collection(USERS_COLLECTION).document(id));
  });
}
