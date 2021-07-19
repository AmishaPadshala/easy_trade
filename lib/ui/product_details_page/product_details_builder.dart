import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:olx_clone/model/product.dart';
import 'package:olx_clone/ui/cart_page/my_cart.dart';
import 'package:olx_clone/ui/product_details_page/product_details.dart';
import 'package:olx_clone/utils/app_utils.dart';
import 'package:olx_clone/utils/colors.dart';
import 'package:olx_clone/utils/font.dart';
import 'package:olx_clone/utils/sign_in_utils/facebook_sign_in.dart';
import 'package:olx_clone/utils/sign_in_utils/google_sign_in.dart';
import 'package:olx_clone/utils/sign_in_utils/phone_sign_in.dart';
import 'package:olx_clone/utils/ui/my_dropdown.dart';

Widget buildCartIcon(BuildContext context, Color iconColor) {
  return StreamBuilder(
    stream: Firestore.instance
        .collection(CARTS_COLLECTION)
        .document(googleAccountId ?? facebookAccessToken ?? phoneUserName)
        .snapshots(),
    builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
      return Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          IconButton(
            iconSize: 28.0,
            icon: Icon(
              snapshot.hasData && snapshot.data.exists
                  ? Icons.shopping_cart
                  : Icons.add_shopping_cart,
              color: iconColor,
            ),
            onPressed: () {
              Navigator.of(context).pushNamed(MyCart.routeName);
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0, left: 15.0),
            child: snapshot.hasData && snapshot.data.exists
                ? CircleAvatar(
                    backgroundColor: Colors.red[700],
                    child: Text(
                      '${snapshot.data.data[CART_ITEMS_COUNT]}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    radius: 7.0,
                  )
                : Container(),
          ),
        ],
      );
    },
  );
}

Row buildNameAndRating(Product product, BuildContext context) {
  Color starColor = Colors.yellow[800];
  return Row(
    children: <Widget>[
//      Text(
//        product.name,
//        style: TextStyle(
//          fontWeight: FontWeight.bold,
//          fontSize: titleTextSize3,
//        ),
//      ),
      Expanded(child: new Container()),
      Icon(Icons.star, color: starColor),
      Icon(Icons.star, color: starColor),
      Icon(Icons.star, color: starColor),
      Icon(Icons.star_half, color: starColor),
      Icon(Icons.star_border, color: starColor),
      Padding(
        padding: const EdgeInsets.only(left: 5.0),
        child: Text(
          '234', // TODO
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: mediumTextSize2,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
      ),
    ],
  );
}

Row buildPrice(BuildContext context, Product product, Function callback) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Hero(
        tag: product.id + product.name,
        child: Material(
          color: Colors.transparent,
          child: Row(
            children: <Widget>[
              Text(INDIAN_CURRENCY),
              Text(
                '${product.price}',
                style: new TextStyle(
                  fontSize: bigTitleTextSize1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      product.availability == IN_STOCK
          ? Row(
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  width: 80.0,
                  child: MyDropdownButtonHideUnderline(
                    child: MyDropdownButton<int>(
                      items: quantities.map(
                        (int quantity) {
                          return MyDropdownMenuItem<int>(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '$quantity',
                                style: TextStyle(fontSize: mediumTextSize1),
                              ),
                            ),
                            value: quantity,
                          );
                        },
                      ).toList(),
                      onChanged: (value) {
                        selectedQuantity = value;
                        product.selectedQty = value;
                        callback();
                      },
                      value: selectedQuantity,
                    ),
                  ),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Theme.of(context).splashColor,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Text(
                    product.priceUnit,
                    style: TextStyle(fontSize: mediumTextSize1),
                  ),
                ),
              ],
            )
          : Container(),
    ],
  );
}

Widget buildDescription(Product product) {
  return Padding(
    padding: const EdgeInsets.only(top: 12.0),
    child: Text(product.description.toString().isEmpty
        ? 'No description available'
        : product.description),
  );
}

Padding buildAvailability(Product product, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(top: 8.0, bottom: 10.0),
    child: Text(
      product.availability,
      style: TextStyle(
        color: product.availability == IN_STOCK ? green : Colors.red[700],
        fontSize: mediumTextSize2,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}
