import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:olx_clone/model/country.dart';
import 'package:olx_clone/ui/login_page/sms_code_dialog.dart';
import 'package:olx_clone/utils/app.dart';
import 'package:olx_clone/utils/app_utils.dart';
import 'package:olx_clone/utils/colors.dart';
import 'package:olx_clone/utils/font.dart';
import 'package:olx_clone/utils/sign_in_utils/phone_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

const double _kPickerItemHeight = 32.0;

class PhoneAuth extends StatefulWidget {
  static final String routeName = '/ui/login_page/phone_auth_number_input_page';

  @override
  _PhoneAuthState createState() => _PhoneAuthState();
}

class _PhoneAuthState extends State<PhoneAuth> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final FocusNode nameFocusNode = FocusNode();

  String numberError = 'Please enter a valid mobile number';
  String nameError = 'Please let us know your name';
  bool showNumberError = false,
      showNameError = false,
      gettingCode = false,
      showNumberPrefix = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        titleSpacing: 0.0,
        title: Text(
          'Phone Authentication',
          style: toolbarTitleStyle(),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(20.0),
              children: <Widget>[
                Text(
                  'We will send you an SMS containing a verification code. You can use that code to verify your mobile number.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: secondaryTextColor, fontSize: mediumTextSize1),
                ),
                GestureDetector(
                  onTap: gettingCode
                      ? null
                      : () async {
                          await showModalBottomSheet<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return _buildBottomPicker(_buildColorPicker());
                            },
                          );
                        },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15.0,
                        horizontal: 5.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Country',
                            style: TextStyle(fontSize: titleTextSize4),
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                Country
                                    .countryNames[Country.selectedCountryIndex],
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: mediumTextSize1,
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: Theme.of(context).primaryColor,
                              ),
                            ],
                          )
                        ],
                      ),
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            side: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 1.5,
                            )),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: TextField(
                    enabled: !gettingCode,
                    controller: _numberController,
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: mediumTextSize1,
                    ),
                    decoration: InputDecoration(
                      errorText: showNumberError ? numberError : null,
                      prefix: showNumberPrefix
                          ? Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Text(
                                '+${Country.countryCodes[Country.selectedCountryIndex]}',
                                overflow: TextOverflow.fade,
                              ),
                            )
                          : Container(width: 0.0),
                      labelText: 'Mobile number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                    onSubmitted: (text) {
                      FocusScope.of(context).requestFocus(nameFocusNode);
                    },
                    onChanged: (value) {
                      if (value.isEmpty) {
                        if (mounted)
                          setState(() {
                            showNumberPrefix = false;
                          });
                      } else {
                        if (showNumberError) {
                          if (mounted)
                            setState(() {
                              showNumberError = false;
                            });
                        }
                        if (mounted)
                          setState(() {
                            showNumberPrefix = true;
                          });
                      }
                    },
                    cursorColor: Theme.of(context).primaryColor,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      BlacklistingTextInputFormatter(new RegExp('[^0-9]')),
                    ],
                    maxLength: 10,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: TextField(
                    enabled: !gettingCode,
                    controller: _nameController,
                    focusNode: nameFocusNode,
                    textCapitalization: TextCapitalization.sentences,
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: mediumTextSize1,
                    ),
                    decoration: InputDecoration(
                      errorText: showNameError ? nameError : null,
                      labelText: 'Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    cursorColor: Theme.of(context).primaryColor,
                    keyboardType: TextInputType.text,
                    maxLength: 30,
                  ),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.all(16.0),
            child: FloatingActionButton(
              child: Icon(Icons.arrow_forward),
              onPressed: gettingCode
                  ? null
                  : () async {
                      if (!_isNumberValid()) {
                        if (mounted)
                          setState(() {
                            showNumberError = true;
                          });
                      } else if (!_isNameValid()) {
                        if (mounted)
                          setState(() {
                            showNumberError = false;
                            showNameError = true;
                          });
                      } else {
                        if (mounted)
                          setState(() {
                            gettingCode = true;
                            showNumberError = false;
                            showNameError = false;
                          });

                        SharedPreferences preferences =
                            await SharedPreferences.getInstance();
                        phoneUserName = _nameController.text;
                        await preferences.setString(
                            PHONE_USERNAME_KEY, _nameController.text);
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            return SMSCodeDialog(_numberController.text);
                          },
                        );
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPicker(Widget picker) {
    return Container(
      height: MediaQuery.of(context).size.height / 2,
      color: CupertinoColors.white,
      child: DefaultTextStyle(
        style: TextStyle(
          color: Theme.of(context).primaryColorDark,
          fontSize: 22.0,
        ),
        child: GestureDetector(
          // Blocks taps from propagating to the modal sheet and popping.
          onTap: () {},
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Select country',
                    style: Theme.of(context)
                        .textTheme
                        .title
                        .copyWith(color: primaryDarkColor),
                  ),
                ),
                Expanded(child: picker),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    final FixedExtentScrollController scrollController =
        new FixedExtentScrollController(
            initialItem: Country.selectedCountryIndex);
    return new CupertinoPicker(
      looping: true,
      magnification: 1.3,
      scrollController: scrollController,
      itemExtent: _kPickerItemHeight,
      backgroundColor: CupertinoColors.white,
      onSelectedItemChanged: (int index) {
        setState(() {
          Country.selectedCountryIndex = index;
        });
      },
      children:
          new List<Widget>.generate(Country.countryNames.length, (int index) {
        return new Center(
          child: new Text(Country.countryNames[index]),
        );
      }),
    );
  }

  bool _isNumberValid() {
    return _numberController.text.isNotEmpty;
  }

  bool _isNameValid() {
    return _nameController.text.isNotEmpty;
  }
}
