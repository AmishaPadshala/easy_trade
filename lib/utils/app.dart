import 'package:flutter/material.dart';
import 'package:olx_clone/utils/colors.dart';
import 'package:olx_clone/utils/font.dart';

final ThemeData kTheme = _buildShrineTheme();

TextTheme get kTextTheme => _buildTextTheme(ThemeData.light().textTheme);

ThemeData _buildShrineTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    accentColor: accentColor,
    primaryColor: primaryColor,
    primaryColorDark: primaryDarkColor,
    indicatorColor: Colors.white,
    splashColor: Colors.white24,
    splashFactory: InkRipple.splashFactory,
    canvasColor: Colors.white,
    buttonColor: primaryDarkColor,
    scaffoldBackgroundColor: primaryTextColor,
    cardColor: primaryTextColor,
    textSelectionColor: primaryLightColor,
    backgroundColor: Colors.white,
    errorColor: kErrorRed,
    buttonTheme: base.buttonTheme.copyWith(
      buttonColor: primaryDarkColor,
      textTheme: ButtonTextTheme.primary,
      disabledColor: accentColor.withOpacity(0.5),
      padding: const EdgeInsets.symmetric(vertical: 15.0),
    ),
    iconTheme: base.iconTheme.copyWith(color: primaryTextColor),
//    primaryIconTheme: base.iconTheme.copyWith(color: kBrown900),
    textTheme: _buildTextTheme(base.textTheme),
    primaryTextTheme: _buildTextTheme(base.primaryTextTheme),
    accentTextTheme: _buildTextTheme(base.accentTextTheme),
  );
}

TextTheme _buildTextTheme(TextTheme base) {
  return base
      .copyWith(
        headline: base.headline.copyWith(
          fontWeight: FontWeight.w500,
        ),
        title: base.title.copyWith(fontSize: titleTextSize3),
        caption: base.caption.copyWith(
          fontWeight: FontWeight.w400,
          fontSize: mediumTextSize2,
        ),
        body2: base.body2.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: mediumTextSize1,
        ),
      )
      .apply(
        fontFamily: 'Rubik',
        displayColor: secondaryTextColor,
        bodyColor: secondaryTextColor,
      );
}

TextStyle toolbarTitleStyle() {
  return TextStyle(
    color: Colors.white,
    fontSize: titleTextSize3,
    fontWeight: FontWeight.w500,
  );
}
