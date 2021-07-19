import 'dart:async';

import 'package:flutter/material.dart';
import 'package:olx_clone/model/address.dart';
import 'package:olx_clone/model/product.dart';
import 'package:olx_clone/ui/address_page/edit_address.dart';
import 'package:olx_clone/ui/purchase_page/purchase_product.dart';
import 'package:olx_clone/utils/app_utils.dart';
import 'package:olx_clone/utils/colors.dart';
import 'package:olx_clone/utils/font.dart';
import 'package:olx_clone/utils/sign_in_utils/facebook_sign_in.dart';
import 'package:olx_clone/utils/sign_in_utils/google_sign_in.dart';
import 'package:olx_clone/utils/sign_in_utils/phone_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

int addressCount = 0, chosenAddress = 0;
List<Address> savedAddresses = [];
SharedPreferences preferences;
StreamSubscription selectedQtiesSubscription;

class PriceDetails extends StatefulWidget {
  final Function onEditCompleteCallback;
  bool isPriceDetailsExpanded = false;

  PriceDetails(this.onEditCompleteCallback);

  @override
  _PriceDetailsState createState() => new _PriceDetailsState();
}

class _PriceDetailsState extends State<PriceDetails> {
  @override
  void initState() {
    super.initState();

    if (!selectedQtiesStream.hasListener)
      selectedQtiesSubscription = selectedQtiesStream.stream.listen((_) {
        if (mounted) setState(() {});
      });
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
    return Container(
      child: ExpansionTile(
        title: Align(
          alignment: Alignment.centerLeft,
          child: widget.isPriceDetailsExpanded
              ? Text(
                  _getTotalCost(),
                  style: Theme.of(context).textTheme.button,
                )
              : Column(
                  children: <Widget>[
                    Text(
                      _getTotalCost(),
                      style: Theme.of(context).textTheme.button,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '(Click for more details)',
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ),
                  ],
                ),
        ),
        children: <Widget>[
          purchaseList.length == 0
              ? Container()
              : Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _buildOrderSummary(context),
                      _buildShippingAddress(context),
                    ],
                  ),
                ),
        ],
        onExpansionChanged: ((isExpanded) {
          if (mounted)
            setState(() {
              widget.isPriceDetailsExpanded = !widget.isPriceDetailsExpanded;
            });
        }),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryDarkColor.withOpacity(0.1),
            primaryDarkColor.withOpacity(0.2),
            primaryDarkColor.withOpacity(0.2),
          ],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
      ),
    );
  }

  String _getTotalCost() {
    var totalItems = getPurchasableProductsCount();

    if (totalItems == 0) {
      return 'No item to purchase';
    } else if (totalItems == 1) {
      return 'Total (${totalItems.toString()} item): ${_totalPrice()}';
    } else {
      return 'Total (${totalItems.toString()} items): ${_totalPrice()}';
    }
  }

  int getPurchasableProductsCount() {
    int totalItems = 0;
    for (Product product in purchaseList) {
      if (product.availableQty > 0) totalItems++;
    }

    return totalItems;
  }

  String _totalPrice() {
    var totalPrice = 0;
    for (Product product in purchaseList) {
      if (product.availableQty > 0)
        totalPrice += selectedQuantities[product.id] * product.price;
    }

    return '$INDIAN_CURRENCY$totalPrice';
  }

  Widget _buildShippingAddress(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 10.0),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Text(
              SHIPPING_ADDRESS,
              style: new TextStyle(
                fontSize: titleTextSize3,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        new Text(
                          savedAddresses.length == 0
                              ? isSignedInWithGoogle
                                  ? googleUserName
                                  : isSignedInWithFacebook
                                      ? facebookUserName
                                      : phoneUserName
                              : savedAddresses[chosenAddress].personName,
                          style: new TextStyle(fontSize: mediumTextSize1),
                        ),
                        new Text(
                          savedAddresses.length == 0
                              ? 'Not Set'
                              : savedAddresses[chosenAddress].formFullAddress(),
                          style: new TextStyle(fontSize: mediumTextSize1),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    onPressed: () async {
                      await Navigator.of(context)
                          .pushNamed(EditAddress.routeName);
                      // Refresh address after closing EditAddress page
                      widget.onEditCompleteCallback();
                      loadAddresses();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Card _buildOrderSummary(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Text(
              ORDER_SUMMARY,
              style: new TextStyle(
                fontSize: titleTextSize3,
                fontWeight: FontWeight.bold,
              ),
            ),
            buildOrderSummary(),
          ],
        ),
      ),
    );
  }

  Widget buildOrderSummary() {
    return new Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: new Column(
        children: <Widget>[
          buildOrderSummaryItem(
            leading: 'Items',
            trailing: getPurchasableProductsCount().toString(),
          ),
          new Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: buildOrderSummaryItem(
              leading: 'Total Price',
              trailing: _totalPrice(),
              isBold: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOrderSummaryItem(
      {String leading, String trailing, bool isBold = false}) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        new Text(
          '$leading',
          style: new TextStyle(
            fontSize: isBold ? mediumTextSize2 : titleTextSize4,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
          ),
        ),
        new Text(
          '$trailing',
          style: new TextStyle(
            fontSize: titleTextSize4,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
