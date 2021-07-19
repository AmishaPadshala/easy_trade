import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:olx_clone/main.dart';
import 'package:olx_clone/model/cart.dart';
import 'package:olx_clone/model/product.dart';
import 'package:olx_clone/ui/cart_page/cart_item_builder.dart';
import 'package:olx_clone/ui/home_page/main_drawer.dart';
import 'package:olx_clone/ui/purchase_page/purchase_product.dart';
import 'package:olx_clone/utils/app.dart';
import 'package:olx_clone/utils/app_utils.dart';
import 'package:olx_clone/utils/colors.dart';
import 'package:olx_clone/utils/font.dart';
import 'package:olx_clone/utils/sign_in_utils/facebook_sign_in.dart';
import 'package:olx_clone/utils/sign_in_utils/google_sign_in.dart';
import 'package:olx_clone/utils/sign_in_utils/phone_sign_in.dart';

class MyCart extends StatefulWidget {
  static final String routeName = '/my_cart';

  @override
  _MyCartState createState() => new _MyCartState();
}

List<Product> productsInsideCart = [];

class _MyCartState extends State<MyCart> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
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
          'Cart',
          style: toolbarTitleStyle(),
        ),
        actions: <Widget>[
          buildSearchButton(Theme.of(context).primaryIconTheme.color),
        ],
      ),
      drawer: new MainDrawer(),
      body: buildCartList(),
    );
  }

  Widget buildCartList() {
    productsInsideCart.clear();

    return StreamBuilder(
      stream: Firestore.instance
          .collection(CARTS_COLLECTION)
          .document(googleAccountId ?? facebookAccessToken ?? phoneUserName)
          .snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (!snapshot.hasData || !snapshot.data.exists) {
          return _buildEmptyCartView(context);
        }
        Cart cart = Cart.fromMap(snapshot.data.data);
        return Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: cart.cartItemsCount,
                  itemBuilder: (BuildContext context, int i) {
                    return snapshot.data.exists
                        ? CartItem(
                            productId: cart.productsInCart[i],
                            positionInCart: i,
                            callback: () {
                              if (mounted) setState(() {});
                            },
                          )
                        : Container();
                  },
                ),
              ),
              _buildProceedToCheckoutBtn(context),
            ],
          ),
        );
      },
    );
  }

  RaisedButton _buildProceedToCheckoutBtn(BuildContext context) {
    return RaisedButton(
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return new PurchaseProduct(selectedQuantity);
        }));
      },
      child: new Text('PROCEED TO CHECKOUT'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(0.0)),
      ),
    );
  }

  Align _buildEmptyCartView(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            'Your cart is empty!',
            style:
                TextStyle(color: secondaryTextColor, fontSize: titleTextSize1),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Text(
              'Add items to it now.',
              style:
                  TextStyle(color: Colors.grey[600], fontSize: mediumTextSize1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 25.0),
            child: RaisedButton(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              onPressed: () {
                Navigator.of(context)
                    .popUntil(ModalRoute.withName(MainPage.routeName));
              },
              color: Theme.of(context).accentColor,
              child: Text(
                'Shop now',
                style:
                    TextStyle(fontSize: buttonTextSize2, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSearchButton(Color iconColor) {
    return Material(
      type: MaterialType.circle,
      color: Colors.transparent,
      child: new InkWell(
        child: new Padding(
          padding: const EdgeInsets.all(10.0),
          child: new Icon(Icons.search, color: iconColor),
        ),
        onTap: () {
          // TODO
        },
      ),
    );
  }
}
