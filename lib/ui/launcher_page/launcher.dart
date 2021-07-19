import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:olx_clone/main.dart';
import 'package:olx_clone/ui/login_page/login_page.dart';
import 'package:olx_clone/utils/app_utils.dart';
import 'package:olx_clone/utils/sign_in_utils/facebook_sign_in.dart';
import 'package:olx_clone/utils/sign_in_utils/google_sign_in.dart';
import 'package:olx_clone/utils/sign_in_utils/phone_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LauncherPage extends StatefulWidget {
  @override
  LauncherPageState createState() {
    return new LauncherPageState();
  }
}

class LauncherPageState extends State<LauncherPage> {
  @override
  void initState() {
    super.initState();

    attemptSilentSignIn();
  }

  attemptSilentSignIn() async {
    FirebaseUser user = await signInWithGoogleSilently();
    if (user == null) {
      // Not signed in with google previously
      if (await isLoggedInWithFacebook()) {
        // Signed in with facebook before
        Navigator.pushReplacementNamed(context, MainPage.routeName);
      } else {
        // Not signed in with facebook previously
        SharedPreferences preferences = await SharedPreferences.getInstance();
        isSignedInWithPhone =
            preferences.getBool(IS_SIGNED_IN_WITH_PHONE_KEY) ?? false;
        if (isSignedInWithPhone) {
          // Signed in with phone number before
          Navigator.pushReplacementNamed(context, MainPage.routeName);
        } else {
          // Not signed in with phone number previously
          Navigator.pushReplacementNamed(context, LoginPage.routeName);
        }
      }
    } else {
      // Signed in with google before
      Navigator.pushReplacementNamed(context, MainPage.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: SpinKitCircle(
          color: Theme.of(context).primaryColorDark,
        ),
      ),
    );
  }
}
