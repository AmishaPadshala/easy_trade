import 'dart:async';

import 'package:flutter/material.dart';
import 'package:olx_clone/model/address.dart';
import 'package:olx_clone/ui/address_page/edit_address_details.dart';
import 'package:olx_clone/utils/app.dart';
import 'package:olx_clone/utils/app_utils.dart';
import 'package:olx_clone/utils/font.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<ScaffoldState> editAddressScaffoldKey = new GlobalKey();

int addressCount = 0, chosenAddress = 0;
List<Address> savedAddresses = [];
SharedPreferences preferences;

class EditAddress extends StatefulWidget {
  static final String routeName = '/ui/address_page/edit_address';

  @override
  _EditAddressState createState() => new _EditAddressState();
}

class _EditAddressState extends State<EditAddress> {
  bool isEditingAddress = false;
  Address addressToBeEdited;

  @override
  void initState() {
    super.initState();

    loadAddresses();
  }

  loadAddresses() async {
    savedAddresses.clear();
    addressCount = 0;

    preferences = await SharedPreferences.getInstance();

    addressCount = preferences.getInt(ADDRESS_COUNT_KEY) ?? 0;
    chosenAddress = preferences.getInt(CHOSEN_ADDRESS) ?? 0;

    for (int i = 0; i < addressCount; i++) {
      savedAddresses.add(loadAddress(i));
    }

    if (mounted) setState(() {});
  }

  Address loadAddress(int pos) {
    String name = preferences.getString('$ADDRESS_NAME_KEY $pos');
    String flatNo = preferences.getString('$ADDRESS_FLAT_NO_KEY $pos');
    String area = preferences.getString('$ADDRESS_AREA_KEY $pos');
    String landmark = preferences.getString('$ADDRESS_LANDMARK_KEY $pos');
    String city = preferences.getString('$ADDRESS_CITY_KEY $pos');
    String pinCode = preferences.getString('$ADDRESS_PINCODE_KEY $pos');
    String phoneNumber =
        preferences.getString('$ADDRESS_PHONE_NUMBER_KEY $pos');

    return Address(
        personName: name,
        flatNo: flatNo,
        area: area,
        landmark: landmark,
        city: city,
        pinCode: pinCode,
        phoneNo: phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: editAddressScaffoldKey,
      resizeToAvoidBottomPadding: true,
      backgroundColor: Theme.of(context).cardColor,
      appBar: AppBar(
        title: Text(
          'Delivery Addresses',
          style: toolbarTitleStyle(),
        ),
        titleSpacing: 0.0,
      ),
      body: WillPopScope(
        onWillPop: onBackPressed,
        child: savedAddresses.length == 0 && !isEditingAddress
            ? _buildEmptyDeliveryAddressView()
            : ListView(
                children: <Widget>[
                  isEditingAddress
                      ? EditAddressDetails(
                          editCompleteCallback: onEditCompleted,
                          addressToBeEdited:
                              isEditingAddress ? addressToBeEdited : null,
                        )
                      : _buildAddressList(),
                ],
              ),
      ),
      floatingActionButton: isEditingAddress
          ? Container()
          : FloatingActionButton(
              onPressed: () {
                addNewAddress();
              },
              child: Icon(Icons.add),
            ),
    );
  }

  Future<bool> onBackPressed() async {
    if (isEditingAddress && mounted) {
      setState(() {
        isEditingAddress = false;
      });
      return false;
    }
    return true;
  }

  onEditCompleted() async {
    isEditingAddress = false;
    await loadAddresses();
  }

  addNewAddress() {
    if (mounted)
      setState(() {
        addressToBeEdited = null;
        isEditingAddress = true;
      });
  }

  Widget _buildEmptyDeliveryAddressView() {
    return Align(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset('assets/empty_address_list.png'),
          Text(
            ADD_ADDRESS_HINT,
            style: TextStyle(
                fontSize: titleTextSize4,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressList() {
    return Column(
      children: <Widget>[
        ListView.builder(
          shrinkWrap: true,
          itemCount: savedAddresses.length,
          itemBuilder: (context, i) {
            return GestureDetector(
              onTap: () => onDeliveryAddressChanged(i),
              child: Card(
                margin: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 3.0),
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(1.0)),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 10.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Radio(
                        value: i,
                        groupValue: chosenAddress,
                        onChanged: (value) => onDeliveryAddressChanged(value),
                        activeColor: Theme.of(context).accentColor,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Text(
                                savedAddresses[i].personName,
                                style: new TextStyle(fontSize: titleTextSize2),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  savedAddresses[i].formFullAddress(),
                                  style: TextStyle(fontSize: mediumTextSize1),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    _buildActionBtn('Edit', Icons.edit,
                                        () => editAddress(savedAddresses[i])),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: _buildActionBtn(
                                          'Delete',
                                          Icons.delete,
                                          () => deleteAddress(
                                              i, savedAddresses[i])),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  onDeliveryAddressChanged(int pos) {
    if (chosenAddress != pos && mounted) {
      setState(() {
        preferences = preferences ?? SharedPreferences.getInstance();
        preferences.setInt(CHOSEN_ADDRESS, pos);
        loadAddresses();
      });
    }
  }

  editAddress(Address address) {
    if (mounted)
      setState(() {
        isEditingAddress = true;
        addressToBeEdited = address;
      });
  }

  deleteAddress(int pos, Address address) async {
    int currentAddressCount = preferences.getInt(ADDRESS_COUNT_KEY);

    int addressDeletedPosition;
    for (int i = 0; i < savedAddresses.length; i++) {
      if (address.id == savedAddresses[i].id) {
        addressDeletedPosition = i;
      }
    }

    preferences.setString('$ADDRESS_NAME_KEY $addressDeletedPosition', null);
    preferences.setString('$ADDRESS_FLAT_NO_KEY $addressDeletedPosition', null);
    preferences.setString('$ADDRESS_AREA_KEY $addressDeletedPosition', null);
    preferences.setString(
        '$ADDRESS_LANDMARK_KEY $addressDeletedPosition', null);
    preferences.setString('$ADDRESS_CITY_KEY $addressDeletedPosition', null);
    preferences.setString('$ADDRESS_PINCODE_KEY $addressDeletedPosition', null);
    preferences.setString(
        '$ADDRESS_PHONE_NUMBER_KEY $addressDeletedPosition', null);

    _reSaveAddressesNextToDeletedAddress(
        addressDeletedPosition, currentAddressCount);
    await loadAddresses();

    editAddressScaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text('Address deleted.'),
        backgroundColor: Theme.of(context).accentColor,
        action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              // TODO
            }),
      ),
    );

    if (mounted) setState(() {});
  }

  _reSaveAddressesNextToDeletedAddress(
      int addressDeletedPosition, int currentAddressCount) {
    for (int i = addressDeletedPosition + 1; i < currentAddressCount; i++) {
      _moveAddressOnePositionBackwards(i);
    }

    preferences.setInt(ADDRESS_COUNT_KEY, currentAddressCount - 1);
    // Set first address as chosen address
    preferences.setInt(CHOSEN_ADDRESS, null);
  }

  _moveAddressOnePositionBackwards(int currentPosition) {
    Address address = loadAddress(currentPosition);

    preferences.setString('$ADDRESS_NAME_KEY $currentPosition', null);
    preferences.setString('$ADDRESS_FLAT_NO_KEY $currentPosition', null);
    preferences.setString('$ADDRESS_AREA_KEY $currentPosition', null);
    preferences.setString('$ADDRESS_LANDMARK_KEY $currentPosition', null);
    preferences.setString('$ADDRESS_CITY_KEY $currentPosition', null);
    preferences.setString('$ADDRESS_PINCODE_KEY $currentPosition', null);
    preferences.setString('$ADDRESS_PHONE_NUMBER_KEY $currentPosition', null);

    preferences.setString(
        '$ADDRESS_NAME_KEY ${currentPosition - 1}', address.personName);
    preferences.setString(
        '$ADDRESS_FLAT_NO_KEY ${currentPosition - 1}', address.flatNo);
    preferences.setString(
        '$ADDRESS_AREA_KEY ${currentPosition - 1}', address.area);
    preferences.setString(
        '$ADDRESS_LANDMARK_KEY ${currentPosition - 1}', address.landmark ?? '');
    preferences.setString(
        '$ADDRESS_CITY_KEY ${currentPosition - 1}', address.city);
    preferences.setString(
        '$ADDRESS_PINCODE_KEY ${currentPosition - 1}', address.pinCode);
    preferences.setString(
        '$ADDRESS_PHONE_NUMBER_KEY ${currentPosition - 1}', address.phoneNo);
  }

  RaisedButton _buildActionBtn(String title, IconData icon, Function callback) {
    return RaisedButton.icon(
      onPressed: () {
        callback();
      },
      icon: Icon(
        icon,
        size: 17.0,
        color: Colors.black.withOpacity(0.5),
      ),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.black.withOpacity(0.6),
          ),
        ),
      ),
      color: Colors.white,
    );
  }
}
