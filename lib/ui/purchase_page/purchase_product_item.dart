import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:olx_clone/model/cart.dart';
import 'package:olx_clone/model/product.dart';
import 'package:olx_clone/ui/product_details_page/product_details.dart';
import 'package:olx_clone/ui/purchase_page/purchase_product.dart';
import 'package:olx_clone/utils/app_utils.dart';
import 'package:olx_clone/utils/colors.dart';
import 'package:olx_clone/utils/font.dart';
import 'package:olx_clone/utils/sign_in_utils/facebook_sign_in.dart';
import 'package:olx_clone/utils/sign_in_utils/google_sign_in.dart';
import 'package:olx_clone/utils/sign_in_utils/phone_sign_in.dart';
import 'package:olx_clone/utils/ui/my_dropdown.dart';

class PurchaseItem extends StatefulWidget {
  List<int> quantities = [];
  final Product product;
  final Function callback;

  PurchaseItem({@required this.product, this.callback});

  @override
  PurchaseItemState createState() => new PurchaseItemState();
}

class PurchaseItemState extends State<PurchaseItem> {
  generateQuantitiesList(Product product) {
    widget.quantities = [];
    int qty = 0;
    if (product.availability == IN_STOCK) {
      widget.quantities = List.generate(product.availableQty, (i) {
        return ++qty;
      });
    }

    selectedQuantities.putIfAbsent(product.id,
        () => widget.quantities.length == 0 ? 0 : widget.quantities[0]);
  }

  @override
  Widget build(BuildContext context) {
    // Generate different quantities the user will be able to choose from
    generateQuantitiesList(widget.product);

    // For displaying total price of all selected widget.products
    widget.product.selectedQty =
        selectedQuantities.containsKey(widget.product.id)
            ? selectedQuantities[widget.product.id]
            : 0;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return ProductDetails(widget.product);
            },
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
        child: Card(
          margin: EdgeInsets.all(0.0),
          elevation: 2.0,
          child: _buildProductCard(context),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildProductDetails(widget.product, context),
              Hero(
                tag: widget.product.id,
                child: CachedNetworkImage(
                  imageUrl: widget.product.imageUrl,
                  height: 80.0,
                  width: 80.0,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                widget.product.availability,
                style: TextStyle(
                  color: widget.product.availability == IN_STOCK
                      ? green
                      : Colors.red[700],
                  fontSize: mediumTextSize2,
                  fontWeight: FontWeight.w500,
                ),
              ),
              widget.product.availability == IN_STOCK &&
                      widget.product.availableQty > 0
                  ? _buildProductQtyDropDown(widget.product)
                  : Container(),
            ],
          ),
        ),
      ],
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
                  padding: EdgeInsets.all(8.0),
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
            if (mounted)
              setState(() {
                selectedQuantities.remove(product.id);
                selectedQuantities.putIfAbsent(product.id, () => value);
                selectedQtiesStream.add(0);
              });
          },
          value: selectedQuantities[product.id],
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
          padding: EdgeInsets.only(top: 10.0),
          child: Hero(
            tag: widget.product.id + widget.product.name,
            child: Material(
              color: Colors.transparent,
              child: Row(
                children: <Widget>[
                  Text(INDIAN_CURRENCY),
                  Text(
                    product.availableQty == 0
                        ? '0'
                        : '${product.price * selectedQuantities[product.id]}',
                    style: TextStyle(
                      fontSize: bigTitleTextSize1,
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
                  purchaseList.clear();
                  widget.callback();
                });
              } else {
                // If there are more than one product in Cart, update the cart
                reference.updateData(cart.toMap()).then((_) {
                  selectedQuantities.remove(product.id);
                  widget.callback();
                });
              }
            }
          },
        );
      },
    );
  }
}
