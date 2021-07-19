import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:olx_clone/model/address.dart';
import 'package:olx_clone/model/order.dart';
import 'package:olx_clone/model/product.dart';
import 'package:olx_clone/ui/address_page/edit_address.dart';
import 'package:olx_clone/ui/purchase_page/order_successful.dart';
import 'package:olx_clone/utils/app_utils.dart';
import 'package:olx_clone/utils/font.dart';
import 'package:olx_clone/utils/notification.dart';
import 'package:olx_clone/utils/sign_in_utils/facebook_sign_in.dart';
import 'package:olx_clone/utils/sign_in_utils/google_sign_in.dart';
import 'package:olx_clone/utils/sign_in_utils/phone_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences preferences;
int addressCount = 0, chosenAddress = 0;
List<Address> savedAddresses = [];
GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

class OrderConfirmation extends StatefulWidget {
  final Product product;
  final Function callback;

  OrderConfirmation(this.product, this.callback);

  @override
  OrderConfirmationState createState() => new OrderConfirmationState();
}

class OrderConfirmationState extends State<OrderConfirmation>
    with SingleTickerProviderStateMixin {
  bool orderPlacedSuccessfully = false;
  AnimationController _scaleAnimationController;
  Animation<double> _scaleAnimation;
  bool isPlacingOrder = false;

  @override
  void initState() {
    super.initState();

    loadAddresses();
    _scaleAnimationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));
    _scaleAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleAnimationController,
        curve: Curves.bounceOut,
      ),
    )..addListener(() {
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _scaleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      body: orderPlacedSuccessfully
          ? OrderSuccessfulPage(_scaleAnimation)
          : Container(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: GestureDetector(
                  onTap: () {
                    // Dummy onTap to avoid the BottomSheet getting closed when this card is tapped
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height / 3,
                        child: CachedNetworkImage(
                          imageUrl: widget.product.imageUrls[0],
                          placeholder: Center(
                            child: SpinKitThreeBounce(
                              color: Theme.of(context).primaryColorDark,
                            ),
                          ),
                        ),
                      ),
                      _buildOrderSummary(context),
                      _buildShippingAddress(context),
                      RaisedButton(
                        disabledColor: Theme.of(context).textSelectionColor,
                        onPressed: isPlacingOrder
                            ? null
                            : () {
                                addToPurchaseList(widget.product);
                              },
                        child: Text(PLACE_ORDER),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(0.0)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildShippingAddress(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              SHIPPING_ADDRESS,
              style: Theme.of(context).textTheme.title,
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          savedAddresses.length == 0
                              ? isSignedInWithGoogle
                                  ? googleUserName
                                  : isSignedInWithFacebook
                                      ? facebookUserName
                                      : phoneUserName
                              : savedAddresses[chosenAddress].personName,
                          style: TextStyle(fontSize: mediumTextSize1),
                        ),
                        Text(
                          savedAddresses.length == 0
                              ? 'Not Set'
                              : savedAddresses[chosenAddress].formFullAddress(),
                          style: TextStyle(fontSize: mediumTextSize1),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () async {
                      await Navigator.of(context)
                          .pushNamed(EditAddress.routeName);
                      // Refresh address after closing EditAddress page
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

  Card _buildOrderSummary(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10.0),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              ORDER_SUMMARY,
              style: Theme.of(context).textTheme.title,
            ),
            buildOrderSummary(),
          ],
        ),
      ),
    );
  }

  Widget buildOrderSummary() {
    return Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: Column(
        children: <Widget>[
          buildOrderSummaryItem(
            leading: 'Items',
            trailing: widget.product.selectedQty.toString(),
          ),
          Padding(
            padding: EdgeInsets.only(top: 5.0),
            child: buildOrderSummaryItem(
              leading: 'Total Price',
              trailing:
                  '$INDIAN_CURRENCY ${widget.product.price * widget.product.selectedQty}',
              isBold: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOrderSummaryItem(
      {String leading, String trailing, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          '$leading',
          style: TextStyle(
              fontSize: isBold ? mediumTextSize2 : titleTextSize4,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w400),
        ),
        Text(
          '$trailing',
          style: TextStyle(
              fontSize: isBold ? mediumTextSize1 : titleTextSize4,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w400),
        ),
      ],
    );
  }

  addToPurchaseList(Product product) {
    if (savedAddresses.isEmpty) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Please add a delivery address first!'),
        backgroundColor: Theme.of(context).accentColor,
      ));

      return;
    }

    if (mounted)
      setState(() {
        isPlacingOrder = true;
      });

    // If product will become un available after purchase, then update availability of product
    if (product.availableQty == widget.product.selectedQty) {
      product.availability = 'Out of Stock';
    }

    String randomReference =
        Firestore.instance.collection(ORDERS_COLLECTION).document().documentID;

    Order order = Order(
      orderId: randomReference,
      productId: product.id,
      productName: product.name,
      thumbnailUrl: product.imageUrl,
      category: product.category,
      orderedQuantity: widget.product.selectedQty,
      timeOrdered: DateTime.now().millisecondsSinceEpoch,
      price: product.price,
      priceUnit: product.priceUnit,
      googleAccountId: googleAccountId ?? '',
      facebookAccessToken: facebookAccessToken ?? '',
      customerAddress: savedAddresses[chosenAddress].formFullAddress(),
      customerName: googleUserName ?? facebookUserName,
    );

    // Decrease product availability
    product.availableQty = product.availableQty - widget.product.selectedQty;
    Map productMap = product.toMap();
    Firestore.instance
        .collection(PRODUCTS_COLLECTION)
        .document(product.id)
        .updateData(productMap);

    placeOrder(order.toMap(), order);
  }

  void placeOrder(Map orderMap, Order order) {
    Firestore.instance
        .collection(ORDERS_COLLECTION)
        .document()
        .setData(orderMap)
        .then((_) {
      if (mounted)
        setState(() {
          _scaleAnimationController.forward();
          orderPlacedSuccessfully = true;
        });
    });

    sendOrderCompleteNotificationToSeller([order]);
  }
}
