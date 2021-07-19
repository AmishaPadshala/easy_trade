import 'package:flutter/material.dart';
import 'package:olx_clone/model/address.dart';
import 'package:olx_clone/ui/address_page/edit_address.dart';
import 'package:olx_clone/utils/app_utils.dart';
import 'package:olx_clone/utils/ui/ensure_visible_when_focused.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditAddressDetails extends StatefulWidget {
  final Function editCompleteCallback;
  final Address addressToBeEdited;

  EditAddressDetails(
      {@required this.editCompleteCallback, this.addressToBeEdited});

  @override
  _EditAddressDetailsState createState() => new _EditAddressDetailsState();
}

class _EditAddressDetailsState extends State<EditAddressDetails> {
  TextEditingController _nameController,
      _flatNoController,
      _areaController,
      _cityController,
      _pinCodeController,
      _landmarkController,
      _phoneController;

  List<FocusNode> focusNodes = [
    new FocusNode(),
    new FocusNode(),
    new FocusNode(),
    new FocusNode(),
    new FocusNode(),
    new FocusNode(),
    new FocusNode(),
  ];

  String nameError, flatNoError, areaError, cityError, pinCodeError;

  @override
  void initState() {
    super.initState();

    initControllers();
    _nameController.addListener(() => _onNameChanged(_nameController.text));
    _flatNoController
        .addListener(() => _onFlatNoChanged(_flatNoController.text));
    _areaController.addListener(() => _onAreaChanged(_areaController.text));
    _cityController.addListener(() => _onCityChanged(_cityController.text));
    _pinCodeController
        .addListener(() => _onPinCodeChanged(_pinCodeController.text));
  }

  initControllers() {
    _nameController = TextEditingController(
        text: widget.addressToBeEdited != null
            ? widget.addressToBeEdited.personName
            : '');
    _flatNoController = TextEditingController(
        text: widget.addressToBeEdited != null
            ? widget.addressToBeEdited.flatNo
            : '');
    _areaController = TextEditingController(
        text: widget.addressToBeEdited != null
            ? widget.addressToBeEdited.area
            : '');
    _cityController = TextEditingController(
        text: widget.addressToBeEdited != null
            ? widget.addressToBeEdited.city
            : '');
    _pinCodeController = TextEditingController(
        text: widget.addressToBeEdited != null
            ? widget.addressToBeEdited.pinCode
            : '');
    _landmarkController = TextEditingController(
        text: widget.addressToBeEdited != null
            ? widget.addressToBeEdited.landmark
            : '');
    _phoneController = TextEditingController(
        text: widget.addressToBeEdited != null
            ? widget.addressToBeEdited.phoneNo.substring(3)
            : '');
  }

  @override
  void dispose() {
    _nameController.removeListener(() {});
    _flatNoController.removeListener(() {});
    _areaController.removeListener(() {});
    _cityController.removeListener(() {});
    _pinCodeController.removeListener(() {});

    disposeFocusNodes();
    super.dispose();
  }

  disposeFocusNodes() {
    for (FocusNode focusNode in focusNodes) {
      focusNode.dispose();
    }
  }

  _onNameChanged(String name) {
    if (_isNameValid(name)) {
      if (nameError != null && mounted)
        setState(() {
          nameError = null;
        });
    }
  }

  _onFlatNoChanged(String flatNo) {
    if (_isFlatNoValid(flatNo)) {
      if (flatNoError != null && mounted)
        setState(() {
          flatNoError = null;
        });
    }
  }

  _onAreaChanged(String area) {
    if (_isAreaValid(area)) {
      if (areaError != null && mounted)
        setState(() {
          areaError = null;
        });
    }
  }

  _onCityChanged(String city) {
    if (_isCityValid(city)) {
      if (cityError != null && mounted)
        setState(() {
          cityError = null;
        });
    }
  }

  _onPinCodeChanged(String pinCode) {
    if (_isPinCodeValid(pinCode)) {
      if (pinCodeError != null && mounted)
        setState(() {
          pinCodeError = null;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildEditAddress();
  }

  Widget _buildEditAddress() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        ListView(
          padding: EdgeInsets.all(10.0),
          shrinkWrap: true,
          children: <Widget>[
            _buildCompulsoryFieldsNote(),
            _buildInputField(
              labelText: 'Name*',
              controller: _nameController,
              errorText: nameError,
              focusNodePos: 0,
            ),
            _buildInputField(
              labelText: 'Flat No*',
              controller: _flatNoController,
              isFlatNo: true,
              errorText: flatNoError,
              focusNodePos: 1,
            ),
            _buildInputField(
              labelText: 'Area or Street*',
              controller: _areaController,
              errorText: areaError,
              focusNodePos: 2,
            ),
            _buildInputField(
              labelText: 'Landmark (Optional)',
              controller: _landmarkController,
              errorText: null,
              focusNodePos: 3,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: _buildInputField(
                    labelText: 'City*',
                    controller: _cityController,
                    errorText: cityError,
                    focusNodePos: 4,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 8.0, top: 24.0),
                    child: _buildInputField(
                      labelText: 'Pincode*',
                      controller: _pinCodeController,
                      isPinCode: true,
                      errorText: pinCodeError,
                      focusNodePos: 5,
                    ),
                  ),
                ),
              ],
            ),
            _buildInputField(
              labelText: 'Phone No (Optional)',
              controller: _phoneController,
              isPhoneNumber: true,
              errorText: null,
              focusNodePos: 6,
            ),
          ],
        ),
        Container(
          width: double.infinity,
          child: RaisedButton(
            onPressed: () {
              _validateAndSaveAddress();
            },
            child: Text('Save address'),
          ),
        ),
      ],
    );
  }

  Widget _buildCompulsoryFieldsNote() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        IMPORTANT_ADDRESS_FIELDS_NOTE,
        style: Theme.of(context).textTheme.button,
      ),
    );
  }

  Widget _buildInputField({
    @required String labelText,
    @required TextEditingController controller,
    @required String errorText,
    @required int focusNodePos,
    bool isFlatNo = false,
    bool isPhoneNumber = false,
    bool isPinCode = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Theme(
        data: Theme.of(context)
            .copyWith(primaryColor: Theme.of(context).accentColor),
        child: EnsureVisibleWhenFocused(
          focusNode: focusNodes[focusNodePos],
          child: TextField(
            textCapitalization: TextCapitalization.words,
            focusNode: focusNodes[focusNodePos],
            textInputAction:
                isPhoneNumber ? TextInputAction.done : TextInputAction.next,
            keyboardType: isPhoneNumber || isPinCode
                ? TextInputType.number
                : TextInputType.text,
            maxLength: isPhoneNumber ? 10 : isPinCode ? 6 : null,
            controller: controller,
            decoration: InputDecoration(
              prefixText: isPhoneNumber ? '+91' : isFlatNo ? 'No. ' : '',
              labelText: labelText,
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 5.0,
                  color: Colors.red,
                ),
              ),
              errorText: errorText,
            ),
            onSubmitted: (_) {
              if (focusNodes.length - 1 > focusNodePos)
                FocusScope.of(context)
                    .requestFocus(focusNodes[focusNodePos + 1]);
            },
          ),
        ),
      ),
    );
  }

  _validateAndSaveAddress() async {
    if (!_isNameValid(_nameController.text) && mounted) {
      setState(() {
        nameError = 'Name must not be empty!';
      });
    } else if (!_isFlatNoValid(_flatNoController.text) && mounted) {
      setState(() {
        nameError = null;
        flatNoError = 'Flat number must not be empty!';
      });
    } else if (!_isAreaValid(_areaController.text) && mounted) {
      setState(() {
        flatNoError = null;
        areaError = 'Area or Street must not be empty!';
      });
    } else if (!_isCityValid(_cityController.text) && mounted) {
      setState(() {
        areaError = null;
        cityError = 'City must not be empty!';
      });
    } else if (!_isPinCodeValid(_pinCodeController.text) && mounted) {
      setState(() {
        cityError = null;
        pinCodeError = 'Invalid PinCode!';
      });
    } else {
      // Everything is good. Save the address
      nameError = null;
      flatNoError = null;
      areaError = null;
      cityError = null;
      pinCodeError = null;

      SharedPreferences preferences = await SharedPreferences.getInstance();
      int currentAddressCount = preferences.getInt(ADDRESS_COUNT_KEY);

      int addressSavedPosition;
      int newAddressCount;
      if (widget.addressToBeEdited != null) {
        // Edit address
        for (int i = 0; i < savedAddresses.length; i++) {
          if (widget.addressToBeEdited.id == savedAddresses[i].id) {
            addressSavedPosition = i;
            newAddressCount = currentAddressCount;
          }
        }
      } else {
        // Add new address
        newAddressCount =
            currentAddressCount == null ? 1 : currentAddressCount + 1;
        addressSavedPosition = newAddressCount - 1;
      }

      preferences.setInt(ADDRESS_COUNT_KEY, newAddressCount);
      preferences.setString('$ADDRESS_NAME_KEY $addressSavedPosition', name);
      preferences.setString(
          '$ADDRESS_FLAT_NO_KEY $addressSavedPosition', flatNo);
      preferences.setString('$ADDRESS_AREA_KEY $addressSavedPosition', area);
      preferences.setString(
          '$ADDRESS_LANDMARK_KEY $addressSavedPosition', landmark ?? '');
      preferences.setString('$ADDRESS_CITY_KEY $addressSavedPosition', city);
      preferences.setString(
          '$ADDRESS_PINCODE_KEY $addressSavedPosition', pinCode);
      preferences.setString(
          '$ADDRESS_PHONE_NUMBER_KEY $addressSavedPosition', '+91$phoneNo');

      editAddressScaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Address saved.'),
        backgroundColor: Theme.of(context).accentColor,
      ));
      widget.editCompleteCallback();
    }
  }

  bool _isNameValid(String name) {
    return name.trim().isNotEmpty;
  }

  bool _isFlatNoValid(String flatNo) {
    return flatNo.trim().isNotEmpty;
  }

  bool _isAreaValid(String area) {
    return area.trim().isNotEmpty;
  }

  bool _isCityValid(String city) {
    return city.trim().isNotEmpty;
  }

  bool _isPinCodeValid(String pinCode) {
    return pinCode.length == 6;
  }

  String get name => _nameController.text.trim();

  String get flatNo => _flatNoController.text.trim();

  String get area => _areaController.text.trim();

  String get landmark => _landmarkController.text.trim();

  String get city => _cityController.text.trim();

  String get pinCode => _pinCodeController.text.trim();

  String get phoneNo => _phoneController.text.trim();
}
