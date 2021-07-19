import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:olx_clone/main.dart';
import 'package:olx_clone/model/country.dart';
import 'package:olx_clone/ui/login_page/login_page.dart';
import 'package:olx_clone/utils/colors.dart';
import 'package:olx_clone/utils/font.dart';
import 'package:olx_clone/utils/sign_in_utils/phone_sign_in.dart';
import 'package:olx_clone/utils/ui/my_text_field.dart';

class SMSCodeDialog extends StatefulWidget {
  final String numberToVerify;

  SMSCodeDialog(this.numberToVerify);

  @override
  SMSCodeDialogState createState() => SMSCodeDialogState();
}

class SMSCodeDialogState extends State<SMSCodeDialog> {
  final FocusNode focusNode1 = FocusNode();
  final FocusNode focusNode2 = FocusNode();
  final FocusNode focusNode3 = FocusNode();
  final FocusNode focusNode4 = FocusNode();
  final FocusNode focusNode5 = FocusNode();
  final FocusNode focusNode6 = FocusNode();

  final TextEditingController controller1 = TextEditingController();
  final TextEditingController controller2 = TextEditingController();
  final TextEditingController controller3 = TextEditingController();
  final TextEditingController controller4 = TextEditingController();
  final TextEditingController controller5 = TextEditingController();
  final TextEditingController controller6 = TextEditingController();

  bool isVerificationInProgress = false,
      autoVerificationInProgress = true,
      numberVerified = false;
  int focusedIndex = 0, autoVerificationTimerRemTime = 5;

  Timer autoVerificationTimer;

  @override
  void initState() {
    super.initState();

    verifyPhoneNumber(
        context: context,
        numberToVerify:
            '+${Country.countryCodes[Country.selectedCountryIndex]}${widget.numberToVerify}',
        onVerificationCompleted: () {
          if (mounted)
            setState(() {
              numberVerified = true;
              autoVerificationInProgress = false;
              autoVerificationTimer.cancel();
              Navigator.of(context).popAndPushNamed(MainPage.routeName);
            });
        },
        onVerificationFailed: () {
          _showToast('Unable to verify your mobile number. Please try again.');
          Navigator.popUntil(context, ModalRoute.withName(LoginPage.routeName));
        });
    autoVerificationTimer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (mounted)
        setState(() {
          autoVerificationTimerRemTime--;
          if (autoVerificationTimerRemTime == 0) {
            autoVerificationInProgress = false;
            autoVerificationTimer.cancel();
          }
        });
    });

    _initFocusNodeListeners();
  }

  void _initFocusNodeListeners() {
    focusNode1.addListener(() {
      if (focusNode1.hasFocus && mounted)
        setState(() {
          focusedIndex = 0;
        });
    });
    focusNode2.addListener(() {
      if (focusNode2.hasFocus && mounted)
        setState(() {
          focusedIndex = 1;
        });
    });
    focusNode3.addListener(() {
      if (focusNode3.hasFocus && mounted)
        setState(() {
          focusedIndex = 2;
        });
    });
    focusNode4.addListener(() {
      if (focusNode4.hasFocus && mounted)
        setState(() {
          focusedIndex = 3;
        });
    });
    focusNode5.addListener(() {
      if (focusNode5.hasFocus && mounted)
        setState(() {
          focusedIndex = 4;
        });
    });
    focusNode6.addListener(() {
      if (focusNode6.hasFocus && mounted)
        setState(() {
          focusedIndex = 5;
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 5.0),
      title: Center(
        child: Text(
          autoVerificationInProgress
              ? 'Auto verification'
              : 'Enter verification code',
        ),
      ),
      children: <Widget>[
        Column(
          children: <Widget>[
            Text(
              autoVerificationInProgress
                  ? 'Waiting for the verification code sent to your mobile number.'
                  : 'Enter verification code sent to your mobile number to continue.',
              textAlign: TextAlign.center,
            ),
            isVerificationInProgress || autoVerificationInProgress
                ? Image.asset(
                    'assets/spinner.gif',
                    width: 100.0,
                    height: 100.0,
                  )
                : Container(),
            autoVerificationInProgress
                ? Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      'Waiting for code $autoVerificationTimerRemTime\s',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  )
                : Container(),
            autoVerificationInProgress
                ? Container()
                : Padding(
                    padding: EdgeInsets.only(
                        top: isVerificationInProgress ? 5.0 : 25.0,
                        bottom: 10.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        _buildCodeBox(
                          controller: controller1,
                          focusNode: focusNode1,
                          topLeft: true,
                          bottomLeft: true,
                          onChanged: (String value) {
                            if (value.isNotEmpty) {
                              FocusScope.of(context).requestFocus(focusNode2);
                            }
                          },
                          index: 0,
                        ),
                        _buildCodeBox(
                          controller: controller2,
                          focusNode: focusNode2,
                          onChanged: (String value) {
                            if (value.isNotEmpty) {
                              FocusScope.of(context).requestFocus(focusNode3);
                            } else {
                              FocusScope.of(context).requestFocus(focusNode1);
                            }
                          },
                          index: 1,
                        ),
                        _buildCodeBox(
                          controller: controller3,
                          focusNode: focusNode3,
                          topRight: true,
                          bottomRight: true,
                          onChanged: (String value) {
                            if (value.isNotEmpty) {
                              FocusScope.of(context).requestFocus(focusNode4);
                            } else {
                              FocusScope.of(context).requestFocus(focusNode2);
                            }
                          },
                          index: 2,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            '-',
                            style: TextStyle(fontSize: bigTitleTextSize2),
                          ),
                        ),
                        _buildCodeBox(
                          controller: controller4,
                          focusNode: focusNode4,
                          topLeft: true,
                          bottomLeft: true,
                          onChanged: (String value) {
                            if (value.isNotEmpty) {
                              FocusScope.of(context).requestFocus(focusNode5);
                            } else {
                              FocusScope.of(context).requestFocus(focusNode3);
                            }
                          },
                          index: 3,
                        ),
                        _buildCodeBox(
                          controller: controller5,
                          focusNode: focusNode5,
                          onChanged: (String value) {
                            if (value.isNotEmpty) {
                              FocusScope.of(context).requestFocus(focusNode6);
                            } else {
                              FocusScope.of(context).requestFocus(focusNode4);
                            }
                          },
                          index: 4,
                        ),
                        _buildCodeBox(
                          controller: controller6,
                          focusNode: focusNode6,
                          topRight: true,
                          bottomRight: true,
                          onChanged: (String value) {
                            if (value.isNotEmpty) {
                              focusNode6.unfocus();
                            } else {
                              FocusScope.of(context).requestFocus(focusNode5);
                            }
                          },
                          index: 5,
                        ),
                      ],
                    ),
                  ),
            autoVerificationInProgress
                ? Container()
                : Container(
                    width: double.infinity,
                    child: RaisedButton(
                      color: Theme.of(context).primaryColorDark,
                      padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 10.0,
                      ),
                      onPressed: isVerificationInProgress
                          ? null
                          : () async {
                              if (!_isCodeValid()) {
                                _showToast('Please enter a valid code');
                              } else {
                                if (mounted)
                                  setState(() {
                                    isVerificationInProgress = true;
                                  });
                                bool signedIn = await signInWithPhoneNumber(
                                  context,
                                  '${controller1.text}'
                                      '${controller2.text}'
                                      '${controller3.text}'
                                      '${controller4.text}'
                                      '${controller5.text}'
                                      '${controller6.text}',
                                );

                                if (signedIn) {
                                  Navigator.of(context)
                                      .popAndPushNamed(MainPage.routeName);
                                } else {
                                  if (mounted)
                                    setState(() {
                                      autoVerificationInProgress = false;
                                      isVerificationInProgress = false;
                                      autoVerificationTimer.cancel();
                                    });
                                  _showToast(
                                      'The verification code you entered is invalid. Please the enter correct code to continue.');
                                }
                              }
                            },
                      child: Text('Verify Code'),
                    ),
                  ),
          ],
        ),
      ],
    );
  }

  Expanded _buildCodeBox({
    @required TextEditingController controller,
    @required FocusNode focusNode,
    bool topLeft = false,
    bool bottomLeft = false,
    bool topRight = false,
    bottomRight = false,
    @required onChanged,
    @required int index,
  }) {
    return Expanded(
      child: Container(
        child: MyTextField(
          cursorColor: Theme.of(context).primaryColor,
          showCounter: false,
          maxLength: 1,
          controller: controller,
          focusNode: focusNode,
          textInputAction:
              index == 5 ? TextInputAction.done : TextInputAction.next,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [
            BlacklistingTextInputFormatter(new RegExp('[^0-9]')),
          ],
          style: TextStyle(
            fontSize: bigTitleTextSize2,
            color: secondaryTextColor,
          ),
          decoration: InputDecoration(border: InputBorder.none),
          onChanged: (value) => onChanged(value),
        ),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(topLeft ? 5.0 : 0.0),
              bottomLeft: Radius.circular(bottomLeft ? 5.0 : 0.0),
              topRight: Radius.circular(topRight ? 5.0 : 0.0),
              bottomRight: Radius.circular(bottomRight ? 5.0 : 0.0),
            ),
            side: BorderSide(
              color: focusedIndex == index
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade500,
              width: focusedIndex == index ? 1.0 : 0.5,
            ),
          ),
        ),
      ),
    );
  }

  bool _isCodeValid() {
    if (controller1.text.isEmpty) return false;
    if (controller2.text.isEmpty) return false;
    if (controller3.text.isEmpty) return false;
    if (controller4.text.isEmpty) return false;
    if (controller5.text.isEmpty) return false;
    if (controller6.text.isEmpty) return false;

    return true;
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 3,
        bgcolor: "#000000",
        textcolor: '#ffffff');
  }
}
