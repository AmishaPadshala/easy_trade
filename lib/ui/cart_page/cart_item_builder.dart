import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:olx_clone/model/cart.dart';
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

Map selectedQuantity = {};

class CartItem extends StatefulWidget {
  List<int> quantities = [];
  final String productId;
  final int positionInCart;
  final Function callback;

  CartItem(
      {@required this.productId, @required this.positionInCart, this.callback});

  @override
  CartItemState createState() => new CartItemState();
}

class CartItemState extends State<CartItem> {
  generateQuantitiesList(Product product) {
    widget.quantities = [];
    int qty = 0;
    if (product.availability == IN_STOCK) {
      widget.quantities = List.generate(product.availableQty, (i) {
        return ++qty;
      });
    }

    selectedQuantity.putIfAbsent(widget.productId,
        () => widget.quantities.length == 0 ? 0 : widget.quantities[0]);
  }

  @override
  Widget build(BuildContext context) {
    // Cart contains product IDs of products inside the cart. Get the actual product details using these IDs
    return StreamBuilder(
      stream: Firestore.instance
          .collection(PRODUCTS_COLLECTION)
          .document(widget.productId)
          .snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (!snapshot.hasData || !snapshot.data.exists) {
          // Product details not yet loaded
          return Container();
        }
        Product product = Product.fromDocument(snapshot.data);

        // Generate different quantities the user will be able to choose from
        generateQuantitiesList(product);

        product.price *= product.availability == IN_STOCK
            ? selectedQuantity.containsKey(product.id)
                ? selectedQuantity[product.id]
                : 0
            : 0;
        // For displaying total price of all selected products
        product.selectedQty = selectedQuantity.containsKey(product.id)
            ? selectedQuantity[product.id]
            : 0;

        // Adding Product details into a list of Products
        bool matchFound = false;
        for (int i = 0; i < productsInsideCart.length; i++) {
          if (productsInsideCart[i].id == product.id) {
            matchFound = true;
            productsInsideCart.removeAt(i);
            // Don't add products which are not available for purchase
            if (product.availability == IN_STOCK)
              productsInsideCart.insert(i, product);
          }
        }

        if (!matchFound) {
          productsInsideCart.add(product);
        }

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              new MaterialPageRoute(
                builder: (context) {
                  return new ProductDetails(product);
                },
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
            child: Card(
              margin: const EdgeInsets.all(0.0),
              elevation: 3.0,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildProductDetails(product, context),
                        Hero(
                          tag: product.id,
                          child: CachedNetworkImage(
                            imageUrl: product.imageUrl,
                            height: 80.0,
                            width: 80.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          product.availability,
                          style: new TextStyle(
                            color: product.availability == IN_STOCK
                                ? green
                                : Colors.red[700],
                            fontSize: mediumTextSize2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        product.availability == IN_STOCK &&
                                product.availableQty > 0
                            ? _buildProductQtyDropDown(product)
                            : Container(),
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _buildActionBtn(
                          ADD_TO_FAVOURITES,
                          Icons.star,
                          addToFavourites,
                          product,
                        ),
                      ),
                      Expanded(
                        child: _buildActionBtn(
                          'Remove',
                          Icons.delete,
                          removeProductFromCart,
                          product,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  RaisedButton _buildActionBtn(
      String title, IconData icon, Function callback, Product product) {
    return RaisedButton.icon(
      onPressed: () => callback(product),
      icon: Icon(
        icon,
        size: 17.0,
        color: Colors.black54.withOpacity(0.6),
      ),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Text(
          title,
          style: TextStyle(color: Colors.black54.withOpacity(0.7)),
        ),
      ),
      color: Colors.white,
      shape: BorderDirectional(
        top: BorderSide(color: Colors.black.withOpacity(0.3), width: 0.5),
      ),
    );
  }

  Container _buildProductQtyDropDown(Product product) {
    return Container(
      alignment: Alignment.center,
      width: 80.0,
      child: MyDropdownButtonHideUnderline(
        child: MyDropdownButton<int>(
          items: widget.quantities.map(
            (int quantity) {
              return MyDropdownMenuItem<int>(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '$quantity',
                    style: new TextStyle(fontSize: mediumTextSize1),
                  ),
                ),
                value: quantity,
              );
            },
          ).toList(),
          onChanged: (value) {
            if (mounted)
              setState(() {
                selectedQuantity.remove(product.id);
                selectedQuantity.putIfAbsent(product.id, () => value);
              });
          },
          value: selectedQuantity[product.id],
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
    );
  }

  Widget _buildProductDetails(Product product, BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          product.name,
          style:
              TextStyle(fontSize: mediumTextSize1, fontWeight: FontWeight.w500),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Hero(
            tag: product.id + product.name,
            child: Material(
              color: Colors.transparent,
              child: Row(
                children: <Widget>[
                  new Text(
                    INDIAN_CURRENCY,
                    style: TextStyle(color: secondaryTextColor),
                  ),
                  new Text(
                    '${product.price}',
                    style: new TextStyle(
                      fontSize: bigTitleTextSize1,
                      color: secondaryTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  removeProductFromCart(Product product) {
    Firestore.instance.runTransaction(
      (transaction) {
        // Get the Cart details from server
        DocumentReference reference = Firestore.instance
            .collection(CARTS_COLLECTION)
            .document(googleAccountId ?? facebookAccessToken ?? phoneUserName);
        reference.get().then(
          (DocumentSnapshot snapshot) {
            if (snapshot.exists) {
              Cart cart = Cart.fromDocument(snapshot);
              List productsInCart = [];

              for (String productId in cart.productsInCart) {
                productsInCart.add(productId);
              }
              // Remove the current product which the user wants to remove from the new cart list
              productsInCart.remove(product.id);

              cart.productsInCart = productsInCart;
              cart.cartItemsCount -= 1; // Decrease cart count
              if (cart.cartItemsCount == 0) {
                // If there is only one product in Cart, delete the entire cart
                reference.delete().then((_) {
                  // Clear local list
                  productsInsideCart.clear();
                  widget.callback();
                });
              } else {
                // If there are more than one product in Cart, update the cart
                reference.updateData(cart.toMap()).then((_) {
                  selectedQuantity.remove(product.id);
                  widget.callback();
                });
              }
            }
          },
        );
      },
    );
  }

  addToFavourites() async {}
}
