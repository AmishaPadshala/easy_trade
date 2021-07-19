import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:olx_clone/model/category.dart';
import 'package:olx_clone/model/user.dart';
import 'package:olx_clone/ui/address_page/edit_address.dart';
import 'package:olx_clone/ui/cart_page/my_cart.dart';
import 'package:olx_clone/ui/filter_page/filter_products.dart';
import 'package:olx_clone/ui/home_page/main_drawer.dart';
import 'package:olx_clone/ui/home_page/main_nested_scroll.dart';
import 'package:olx_clone/ui/launcher_page/launcher.dart';
import 'package:olx_clone/ui/login_page/login_page.dart';
import 'package:olx_clone/ui/login_page/phone_auth_number_input_page.dart';
import 'package:olx_clone/ui/my_orders_page/my_orders.dart';
import 'package:olx_clone/utils/app.dart';
import 'package:olx_clone/utils/app_utils.dart';
import 'package:olx_clone/utils/colors.dart';
import 'package:olx_clone/utils/sign_in_utils/facebook_sign_in.dart';
import 'package:olx_clone/utils/sign_in_utils/google_sign_in.dart';
import 'package:olx_clone/utils/sign_in_utils/phone_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(new MaterialApp(
    home: new LauncherPage(),
    debugShowCheckedModeBanner: false,
    routes: <String, WidgetBuilder>{
      LoginPage.routeName: (context) => new LoginPage(),
      MainPage.routeName: (context) => new MainPage(),
      FilterPage.routeName: (context) => new FilterPage(),
      MyCart.routeName: (context) => new MyCart(),
      EditAddress.routeName: (context) => new EditAddress(),
      MyOrders.routeName: (context) => new MyOrders(),
      PhoneAuth.routeName: (context) => new PhoneAuth(),
    },
    theme: kTheme,
  ));
}

MainPageState mainPageState = new MainPageState();

class MainPage extends StatefulWidget {
  static final String routeName = '/main';

  @override
  MainPageState createState() => mainPageState;
}

final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
List<StreamSubscription<QuerySnapshot>> deliveryStreams = [];

class MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  SharedPreferences preferences;

  @override
  void initState() {
    loadProfiles();
    super.initState();

    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.configure(onLaunch: ((Map<String, dynamic> map) {
      print('onLaunch: $map');
    }), onMessage: ((Map<String, dynamic> map) {
      print('onMessage: ${map.toString()}');
    }), onResume: ((Map<String, dynamic> map) {
      print('onResume: $map');
    }));
  }

  loadProfiles() async {
    preferences = await SharedPreferences.getInstance();
    phoneAccountId = preferences.getString(PHONE_ACCOUNT_ID_KEY);
    phoneUserName = preferences.getString(PHONE_USERNAME_KEY);
    googleAccountId = preferences.getString(GOOGLE_ACCOUNT_ID_KEY);
    googleRegToken = preferences.getString(GOOGLE_REGISTRATION_TOKEN_KEY);
    googleProfileUrl = preferences.getString(GOOGLE_PROFILE_URL_KEY);
    googleUserName = preferences.getString(GOOGLE_USERNAME_KEY);
    googleEmailID = preferences.getString(GOOGLE_EMAIL_ID_KEY);
    facebookAccessToken = preferences.getString(FACEBOOK_ACCESS_TOKEN_KEY);
    facebookRegToken = preferences.getString(FACEBOOK_REGISTRATION_TOKEN_KEY);
    facebookProfileUrl = preferences.getString(FACEBOOK_PROFILE_URL_KEY);
    facebookUserName = preferences.getString(FACEBOOK_USERNAME_KEY);
    facebookEmailID = preferences.getString(FACEBOOK_EMAIL_ID_KEY);
    isSignedInWithGoogle =
        preferences.getBool(IS_SIGNED_IN_WITH_GOOGLE_KEY) ?? false;
    isSignedInWithFacebook =
        preferences.getBool(IS_SIGNED_IN_WITH_FACEBOOK_KEY) ?? false;
    isSignedInWithPhone =
        preferences.getBool(IS_SIGNED_IN_WITH_PHONE_KEY) ?? false;
    selectedProfile = preferences.getString(SELECTED_ACCOUNT_KEY) ?? GOOGLE;

    _firebaseMessaging.onTokenRefresh.listen((token) {
      Firestore.instance
          .collection(USERS_COLLECTION)
          .document(googleAccountId ?? facebookAccessToken ?? phoneUserName)
          .get()
          .then((snapshot) {
        if (snapshot.exists) {
          User user = User.fromMap(snapshot.data);
          if (user.registrationToken == null ||
              user.registrationToken != token) {
            // New Registration token generated. Hence update server
            Firestore.instance.runTransaction((transaction) async {
              user.registrationToken = token;
              await transaction.update(snapshot.reference, user.toMap());
            });
          }
        }
      });
    });

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (StreamSubscription<QuerySnapshot> stream in deliveryStreams) {
      stream?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPressed,
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColorDark,
        body: SafeArea(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: LightAccentColor.withAlpha(255),
              shape: BoxShape.rectangle,
            ),
            child: MainNestedScrollView(),
          ),
        ),
        drawer: MainDrawer(),
      ),
    );
  }

  Future<bool> onBackPressed() {
    if (selectedCategory != null) {
      setState(() => setSelectedCategory(null));
      return Future.value(false);
    }

    return Future.value(true);
  }
}
