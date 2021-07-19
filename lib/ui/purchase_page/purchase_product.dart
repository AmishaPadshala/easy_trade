import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:olx_clone/model/cart.dart';
import 'package:olx_clone/model/order.dart';
import 'package:olx_clone/model/product.dart';
import 'package:olx_clone/ui/home_page/main_drawer.dart';
import 'package:olx_clone/ui/purchase_page/order_successful.dart';
import 'package:olx_clone/ui/purchase_page/price_details.dart';
import 'package:olx_clone/ui/purchase_page/purchase_product_item.dart';
import 'package:olx_clone/utils/app.dart';
import 'package:olx_clone/utils/app_utils.dart';
import 'package:olx_clone/utils/notification.dart';
import 'package:olx_clone/utils/sign_in_utils/facebook_sign_in.dart';
import 'package:olx_clone/utils/sign_in_utils/google_sign_in.dart';
import 'package:olx_clone/utils/sign_in_utils/phone_sign_in.dart';

List<Product> purchaseList = [];
List<Order> _orderList = [];
Map selectedQuantities = {};
StreamController selectedQtiesStream;
bool orderCompleted = false;

class PurchaseProduct extends StatefulWidget {
  Map selectedQties = {};
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  bool metricsChanged = false;

  PurchaseProduct(this.selectedQties) {
    selectedQuantities.clear();
    selectedQuantities.addAll(selectedQties);
  }

  @override
  _PurchaseProductState createState() => new _PurchaseProductState();
}

class _PurchaseProductState extends State<PurchaseProduct>
    with SingleTickerProviderStateMixin {
  AnimationController _scaleAnimationController;
  Animation<double> _scaleAnimation;
  bool isPlacingOrder = false;

  @override
  void initState() {
    super.initState();

    orderCompleted = false;

    selectedQtiesStream = new StreamController();
    _loadProductsInCart();

    _scaleAnimationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));
    _scaleAnimation = new Tween(begin: 0.0, end: 1.0).animate(
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
      key: widget._scaffoldKey,
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 10.0,
        titleSpacing: 0.0,
        leading: new IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: new Text(
          'Purchase',
          style: toolbarTitleStyle(),
        ),
      ),
      body: Stack(
        children: <Widget>[
          buildProductsList(),
          orderCompleted && !isPlacingOrder
              ? OrderSuccessfulPage(_scaleAnimation)
              : Container(),
        ],
      ),
      drawer: MainDrawer(),
    );
  }

  _loadProductsInCart() {
    Firestore.instance
        .collection(CARTS_COLLECTION)
        .document(googleAccountId ?? facebookAccessToken ?? phoneUserName)
        .get()
        .then((DocumentSnapshot document) async {
      if (document.exists) {
        purchaseList.clear();
        Cart cart = Cart.fromDocument(document);
        List<dynamic> productIds = cart.productsInCart;
        for (int i = 0; i < productIds.length; i++) {
          purchaseList.add(await _loadProduct(productIds[i]));
        }

        if (mounted) setState(() {});
      }
    });
  }

  Future<Product> _loadProduct(String productId) async {
    Product product;
    await Firestore.instance
        .collection(PRODUCTS_COLLECTION)
        .document(productId)
        .get()
        .then((DocumentSnapshot document) {
      product = Product.fromDocument(document);
    });
    return product;
  }

  Widget buildProductsList() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: purchaseList.length == 0
                ? Center(
                    child: SpinKitCircle(
                      color: Theme.of(context).primaryColorDark,
                    ),
                  )
                : Column(
                    children: <Widget>[
                      Expanded(
                        child: ListView.builder(
                          physics: BouncingScrollPhysics(),
                          itemCount: purchaseList.length,
                          itemBuilder: (BuildContext context, int i) {
                            return PurchaseItem(
                              product: purchaseList[i],
                              callback: () {
                                if (mounted) setState(() {});
                              },
                            );
                          },
                        ),
                      ),
                      PriceDetails(_loadProductsInCart),
                    ],
                  ),
          ),
          _buildPurchaseBtn(context),
        ],
      ),
    );
  }

  int getPurchasableProductsCount() {
    int totalItems = 0;
    for (Product product in purchaseList) {
      if (product.availableQty > 0) totalItems++;
    }

    return totalItems;
  }

  RaisedButton _buildPurchaseBtn(BuildContext context) {
    return RaisedButton(
      disabledColor: Theme.of(context).textSelectionColor,
      onPressed: getPurchasableProductsCount() == 0 || isPlacingOrder
          ? null
          : () {
              if (savedAddresses.isEmpty) {
                widget._scaffoldKey.currentState.showSnackBar(
                  SnackBar(
                    content: Text('Please add a delivery address first!'),
                    backgroundColor: Theme.of(context).accentColor,
                  ),
                );
              } else {
                if (mounted)
                  setState(() {
                    isPlacingOrder = true;
                  });
                _orderList.clear();

                String randomReference = Firestore.instance
                    .collection(ORDERS_COLLECTION)
                    .document()
                    .documentID;

                for (Product product in purchaseList) {
                  if (product.availableQty > 0) {
                    addToPurchaseList(product, randomReference);
                    orderCompleted = true;
                  }
                }

                if (orderCompleted) {
                  for (Order order in _orderList) placeOrder(order.toMap());
                  sendOrderCompleteNotificationToSeller(_orderList);
                  isPlacingOrder = false;
                }
              }
            },
      child: new Text(!isPlacingOrder ? PLACE_ORDER : 'PLACING ORDER'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(0.0)),
      ),
    );
  }

  List<Widget> getPurchasedProductNames() {
    return new List.generate(
      purchaseList.length,
      (i) {
        return Text(purchaseList[i].name + purchaseList[i].price.toString());
      },
    );
  }

  void addToPurchaseList(Product product, String randomReference) {
    // If product will become un available after purchase, then update availability of product
    if (product.availableQty == product.selectedQty) {
      product.availability = 'Out of Stock';
    }

    Order order = new Order(
      orderId: randomReference,
      productId: product.id,
      productName: product.name,
      thumbnailUrl: product.imageUrl,
      category: product.category,
      orderedQuantity: product.selectedQty,
      timeOrdered: DateTime.now().millisecondsSinceEpoch,
      price: product.price,
      priceUnit: product.priceUnit,
      googleAccountId: googleAccountId ?? '',
      facebookAccessToken: facebookAccessToken ?? '',
      customerAddress: savedAddresses[chosenAddress].formFullAddress(),
      customerName: googleUserName ?? facebookUserName,
    );

    _orderList.add(order);

    // Decrease product availability
    product.availableQty = product.availableQty - product.selectedQty;
    Map productMap = product.toMap();
    Firestore.instance
        .collection(PRODUCTS_COLLECTION)
        .document(product.id)
        .updateData(productMap)
        .then((_) {
      product.selectedQty = 1;
      selectedQuantities.remove(product.id);
      selectedQuantities.putIfAbsent(product.id, () => 1);
      selectedQtiesStream.add(0);
    });
  }

  void placeOrder(Map orderMap) {
    Firestore.instance
        .collection(ORDERS_COLLECTION)
        .document()
        .setData(orderMap)
        .then((_) {
      if (mounted)
        setState(() {
          _scaleAnimationController.forward();
        });
    });
  }
}
