import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:olx_clone/model/main_navigation_item.dart';
import 'package:olx_clone/utils/app_utils.dart';
import 'package:olx_clone/utils/font.dart';
import 'package:olx_clone/utils/sign_in_utils/facebook_sign_in.dart';
import 'package:olx_clone/utils/sign_in_utils/google_sign_in.dart';
import 'package:olx_clone/utils/sign_in_utils/phone_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

String selectedProfile = GOOGLE;

class MainDrawer extends StatefulWidget {
  const MainDrawer({
    Key key,
  }) : super(key: key);

  @override
  MainDrawerState createState() {
    return MainDrawerState();
  }
}

SharedPreferences _pref;

class MainDrawerState extends State<MainDrawer> {
  @override
  void initState() {
    super.initState();

    getSharedPrefInstance();
  }

  getSharedPrefInstance() async {
    _pref = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColorDark,
        body: Column(
          children: <Widget>[
            ListView(
              shrinkWrap: true,
              children: <Widget>[
                buildUserProfileHeader(),
              ]
                ..addAll(getNavigationItems(context))
                ..add(
                  Container(
                    color: Colors.white,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        buildSocialAccountButton(context, isSignedInWithGoogle,
                            'assets/google_logo.png', () async {
                          if (isSignedInWithGoogle) {
                            await logoutFromGoogle();
                            if (mounted) setState(() {});
                          } else {
                            FirebaseUser user =
                                await signInWithGoogleSilently();
                            if (user == null) {
                              // Not signed in previously
                              FirebaseUser user = await signInWithGoogle();
                              if (user != null) {
                                if (mounted) setState(() {});
                              }
                            }
                          }
                        }),
                        SizedBox(width: 10.0),
                        buildSocialAccountButton(
                          context,
                          isSignedInWithFacebook,
                          'assets/facebook_logo_without_outline.png',
                          () async {
                            if (isSignedInWithFacebook) {
                              await logoutFromFacebook();
                              if (mounted) setState(() {});
                            } else {
                              FirebaseUser user =
                                  await signInWithFacebook(context);
                              if (user != null) {
                                if (mounted) setState(() {});
                              }
                            }
                          },
                        ),
//              buildSocialAccountButton(true, 'mail.png', () {}),
                      ],
                    ),
                  ),
                ),
            ),
            Expanded(child: Container(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  void addToOtherProfile(List<Widget> otherAccProfilePictures,
      String profileUrl, String profileName, bool isPhone) {
    otherAccProfilePictures.add(
      InkWell(
        child: Material(
          type: MaterialType.circle,
          color:
              isPhone ? Theme.of(context).primaryColorDark : Colors.transparent,
          child: isPhone
              ? Center(
                  child: Text(
                    phoneUserName.substring(0, 1),
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : Image.network(profileUrl ?? ''),
        ),
        onTap: () {
          if (mounted)
            setState(() {
              selectedProfile = profileName;
              _pref.setString(SELECTED_ACCOUNT_KEY, selectedProfile);
            });
        },
      ),
    );
  }

  Widget buildUserProfileHeader() {
    Widget currentAccPicture, accName, accEmail;
    List<Widget> otherAccProfilePictures = [];
    if (!isSignedInWithGoogle &&
        !isSignedInWithFacebook &&
        !isSignedInWithPhone) {
      // Not signed in with Google or Facebook
      currentAccPicture = Container();
      accName = Text(NOT_SIGNED_IN);
      accEmail = Text(SIGN_IN_MESSAGE);
    } else {
      if (isSignedInWithGoogle && selectedProfile == GOOGLE) {
        currentAccPicture = CircleAvatar(
          backgroundImage: NetworkImage(googleProfileUrl ?? ''),
        );
        accName = Text(
          googleUserName ?? '',
          style: TextStyle(color: Colors.white, fontSize: mediumTextSize1),
        );
        accEmail = Text(
          googleEmailID ?? '',
          style: TextStyle(color: Colors.grey[400], fontSize: mediumTextSize2),
        );
      } else if (isSignedInWithFacebook && selectedProfile == FACEBOOK) {
        currentAccPicture = CircleAvatar(
          backgroundImage: NetworkImage(googleProfileUrl ?? ''),
        );
        accName = Text(
          googleUserName ?? '',
          style: TextStyle(color: Colors.white, fontSize: mediumTextSize1),
        );
        accEmail = Text(
          googleEmailID ?? '',
          style: TextStyle(color: Colors.grey[400], fontSize: mediumTextSize2),
        );
      } else if (isSignedInWithPhone && selectedProfile == PHONE) {
        currentAccPicture = CircleAvatar(
          child: Text(
            phoneUserName.substring(0, 1),
            style: TextStyle(
              fontSize: bigTitleTextSize1,
              color: Colors.white,
            ),
          ),
        );
        accName = Text(
          phoneUserName ?? '',
          style: TextStyle(color: Colors.white, fontSize: mediumTextSize1),
        );
        accEmail = Text(
          phoneAccountId ?? '',
          style: TextStyle(color: Colors.grey[400], fontSize: mediumTextSize2),
        );
      }

      if (isSignedInWithGoogle && selectedProfile != GOOGLE)
        addToOtherProfile(
            otherAccProfilePictures, googleProfileUrl, GOOGLE, false);
      else if (isSignedInWithFacebook && selectedProfile != FACEBOOK)
        addToOtherProfile(
            otherAccProfilePictures, facebookProfileUrl, FACEBOOK, false);
      else if (isSignedInWithPhone && selectedProfile != PHONE)
        addToOtherProfile(otherAccProfilePictures, '', PHONE, true);
    }
    return Container(
      color: Colors.white,
      child: UserAccountsDrawerHeader(
        currentAccountPicture: currentAccPicture,
        accountName: accName,
        accountEmail: accEmail,
        otherAccountsPictures: otherAccProfilePictures,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: <Color>[
            Theme.of(context).primaryColorDark.withOpacity(0.9),
            Theme.of(context).primaryColorDark.withOpacity(0.7),
            Theme.of(context).primaryColorDark.withOpacity(0.5),
          ], begin: Alignment.bottomLeft, end: Alignment.topRight),
        ),
      ),
    );
  }
}

Padding buildSocialAccountButton(
    BuildContext context, bool isLoggedIn, String assetPath, Function onTap) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 8.0),
    child: Material(
      elevation: isLoggedIn ? 8.0 : 0.0,
      type: MaterialType.circle,
      color: isLoggedIn
          ? Colors.white
          : Theme.of(context).accentColor.withOpacity(0.1),
      child: InkWell(
        splashColor: isLoggedIn ? Colors.grey[600] : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(13.0),
          child: Image.asset(
            assetPath,
            height: 23.0,
            width: 23.0,
            color: isLoggedIn
                ? null
                : assetPath.contains('facebook')
                    ? Colors.indigo.withOpacity(0.5)
                    : Theme.of(context).primaryColorDark.withOpacity(0.6),
          ),
        ),
        onTap: onTap,
      ),
    ),
  );
}
