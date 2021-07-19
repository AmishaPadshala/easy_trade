import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:olx_clone/main.dart';
import 'package:olx_clone/utils/font.dart';

class OrderSuccessfulPage extends StatelessWidget {
  final Animation<double> _scaleAnimation;

  OrderSuccessfulPage(this._scaleAnimation);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 10.0,
        sigmaY: 10.0,
      ),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AnimatedOpacity(
                    opacity: _scaleAnimation.value,
                    duration: Duration(milliseconds: 1500),
                    // ignore: conflicting_dart_import
                    child: Image.asset(
                      'assets/order_completed.png',
                      height: _scaleAnimation.value *
                          (MediaQuery.of(context).size.width / 2),
                      width: _scaleAnimation.value *
                          (MediaQuery.of(context).size.width / 2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: AnimatedOpacity(
                      opacity: _scaleAnimation.value,
                      duration: Duration(milliseconds: 1500),
                      child: Text(
                        'Thank you',
                        // ignore: conflicting_dart_import
                        style: TextStyle(
                          fontSize: bigTitleTextSize1,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: AnimatedOpacity(
                      opacity: _scaleAnimation.value,
                      duration: Duration(milliseconds: 1500),
                      child: Text(
                        'Order successfully placed',
                        style: TextStyle(fontSize: bigTitleTextSize2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedOpacity(
              opacity: _scaleAnimation.value,
              duration: Duration(milliseconds: 1000),
              child: RaisedButton(
                onPressed: () {
                  Navigator
                      .of(context)
                      .popUntil(ModalRoute.withName(MainPage.routeName));
                },
                child: Text(
                  'Continue Shopping',
                  style: new TextStyle(
                    fontSize: buttonTextSize2,
                    color: Colors.white,
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                color: Theme.of(context).primaryColorDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(0.0)),
                ),
              ),
            ),
          ],
        ),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: new BoxDecoration(
          color: Colors.grey.shade100.withOpacity(0.1),
        ),
      ),
    );
  }
}
