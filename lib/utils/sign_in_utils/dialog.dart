import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:olx_clone/utils/font.dart';

showSigningInDialog(BuildContext context) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              height: 50.0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SpinKitCircle(
                    color: Theme.of(context).primaryColorDark,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Text(
                      'Signing in...',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: mediumTextSize1,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      });
}
