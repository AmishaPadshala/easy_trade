import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:olx_clone/main.dart';
import 'package:olx_clone/ui/login_page/phone_auth_number_input_page.dart';
import 'package:olx_clone/utils/app_utils.dart';
import 'package:olx_clone/utils/colors.dart';
import 'package:olx_clone/utils/font.dart';
import 'package:olx_clone/utils/sign_in_utils/dialog.dart';
import 'package:olx_clone/utils/sign_in_utils/facebook_sign_in.dart';
import 'package:olx_clone/utils/sign_in_utils/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  static final String routeName = '/login_page';

  @override
  LoginPageState createState() => new LoginPageState();
}

GlobalKey<ScaffoldState> _loginScaffoldKey = new GlobalKey();

class LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _loginScaffoldKey,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            'assets/shopping.jpg',
            fit: BoxFit.cover,
            color: Colors.black54,
            colorBlendMode: BlendMode.darken,
          ),
          FractionallySizedBox(
            alignment: Alignment.center,
            widthFactor: 0.85,
            heightFactor: 0.5,
            child: Column(
              children: <Widget>[
                buildLogoPart(),
                Expanded(child: Container()),
                buildFacebookButton(context),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(child: buildGoogleButton(context)),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 6.0),
                          child: buildPhoneButton(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLogoPart() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          'assets/easy_trade_logo.png',
          height: 140.0,
          width: 140.0,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            APP_NAME,
            style: TextStyle(
              color: primaryTextColor,
              fontSize: titleTextSize1,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  MaterialButton buildPhoneButton() {
    return MaterialButton(
      elevation: 5.0,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Icon(
            Icons.phone_android,
            size: 24.0,
            color: Colors.black,
          ),
          Text(
            PHONE_CAPS,
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: buttonTextSize2,
            ),
          ),
        ],
      ),
      onPressed: () {
        Navigator.pushNamed(context, PhoneAuth.routeName);
      },
    );
  }

  MaterialButton buildGoogleButton(BuildContext context) {
    return MaterialButton(
      elevation: 5.0,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Image.asset(GOOGLE_LOGO_ASSET, width: 24.0, height: 24.0),
          Text(
            GOOGLE_CAPS,
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: buttonTextSize2,
            ),
          ),
        ],
      ),
      onPressed: () {
        loginWithGoogle(context);
      },
    );
  }

  loginWithGoogle(BuildContext context) async {
    showSigningInDialog(context);
    FirebaseUser user = await signInWithGoogle();
    if (user == null) {
      Navigator.of(context).pop(); // Remove dialog
      _loginScaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
          GOOGLE_SIGN_IN_ERROR,
        ),
        backgroundColor: Theme.of(context).accentColor,
      ));
    } else {
      Navigator.of(context).pop(); // Remove dialog
      Navigator.pushReplacementNamed(context, MainPage.routeName);
    }
  }

  loginWithFacebook(BuildContext context) async {
    showSigningInDialog(context);

    if (await isLoggedInWithFacebook()) {
      Navigator.of(context).pop(); // Remove dialog
      Navigator.pushReplacementNamed(context, MainPage.routeName);
    } else {
      FirebaseUser user = await signInWithFacebook(context);
      if (user == null) {
        Navigator.of(context).pop(); // Remove dialog
        _loginScaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text(
              FACEBOOK_SIGN_IN_ERROR,
            ),
            backgroundColor: Theme.of(context).accentColor,
          ),
        );
      } else {
        Navigator.of(context).pop(); // Remove dialog
        Navigator.pushReplacementNamed(context, MainPage.routeName);
      }
    }
  }

  MaterialButton buildFacebookButton(BuildContext context) {
    return MaterialButton(
      elevation: 5.0,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      color: Colors.blue[800],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset('assets/facebook_logo.png',
              color: Colors.white, width: 24.0, height: 24.0),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              'LOGIN  WITH  FACEBOOK',
              style:
                  TextStyle(color: primaryTextColor, fontSize: buttonTextSize2),
            ),
          ),
        ],
      ),
      onPressed: () {
        loginWithFacebook(context);
      },
    );
  }
}
