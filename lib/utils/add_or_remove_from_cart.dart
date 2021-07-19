import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:olx_clone/model/cart.dart';
import 'package:olx_clone/model/product.dart';
import 'package:olx_clone/utils/app_utils.dart';
import 'package:olx_clone/utils/sign_in_utils/facebook_sign_in.dart';
import 'package:olx_clone/utils/sign_in_utils/google_sign_in.dart';
import 'package:olx_clone/utils/sign_in_utils/phone_sign_in.dart';

void addItemToCart({
  Product product,
  BuildContext context,
  GlobalKey<ScaffoldState> scaffoldKey,
}) async {
  SnackBar snackbar;
  final TransactionHandler transactionHandler =
      (Transaction transaction) async {
    await transaction
        .get(Firestore.instance
            .collection(CARTS_COLLECTION)
            .document(googleAccountId ?? facebookAccessToken ?? phoneUserName))
        .then(
      (DocumentSnapshot snapshot) async {
        if (snapshot.exists) {
          Cart cart = Cart.fromMap(snapshot.data);
          cart.cartItemsCount += 1;
          List productsInCart = [];
          for (String productId in cart.productsInCart) {
            productsInCart.add(productId);
          }
          if (!productsInCart.contains(product.id)) {
            productsInCart.add(product.id);
            cart.productsInCart = productsInCart;
            await transaction.update(snapshot.reference, cart.toMap()).then(
              (_) {
                if (scaffoldKey != null) {
                  snackbar = SnackBar(
                    content: Text(ITEM_ADDED_TO_CART),
                    duration: Duration(seconds: 2),
                    backgroundColor: Theme.of(context).accentColor,
                  );
                  scaffoldKey.currentState.showSnackBar(snackbar);
                }
              },
              onError: () {
                if (scaffoldKey != null) {
                  snackbar = SnackBar(
                    content: Text(UNABLE_TO_ADD_ITEM_TO_CART),
                    duration: Duration(seconds: 2),
                    backgroundColor: Theme.of(context).accentColor,
                  );
                  scaffoldKey.currentState.showSnackBar(snackbar);
                }
              },
            );
          } else {
            if (scaffoldKey != null) {
              snackbar = SnackBar(
                content: Text(ITEM_ALREADY_IN_CART),
                duration: Duration(seconds: 2),
                backgroundColor: Theme.of(context).accentColor,
              );
              scaffoldKey.currentState.showSnackBar(snackbar);
            }
          }
        } else {
          await snapshot.reference
              .setData(
                  Cart(productsInCart: [product.id], cartItemsCount: 1).toMap())
              .then(
            (_) {
              if (scaffoldKey != null) {
                snackbar = SnackBar(
                  content: Text(ITEM_ADDED_TO_CART),
                  duration: Duration(seconds: 2),
                  backgroundColor: Theme.of(context).accentColor,
                );
                scaffoldKey.currentState.showSnackBar(snackbar);
              }
            },
            onError: () {
              if (scaffoldKey != null) {
                snackbar = SnackBar(
                  content: Text(UNABLE_TO_ADD_ITEM_TO_CART),
                  duration: Duration(seconds: 2),
                  backgroundColor: Theme.of(context).accentColor,
                );
                scaffoldKey.currentState.showSnackBar(snackbar);
              }
            },
          );
        }
      },
      onError: () {
        if (scaffoldKey != null) {
          snackbar = SnackBar(
            content: Text(UNABLE_TO_ADD_ITEM_TO_CART),
            duration: Duration(seconds: 2),
            backgroundColor: Theme.of(context).accentColor,
          );
          scaffoldKey.currentState.showSnackBar(snackbar);
        }
      },
    );
  };

  Firestore.instance.runTransaction(transactionHandler);
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
              reference.delete();
            } else {
              // If there are more than one product in Cart, update the cart
              reference.updateData(cart.toMap());
            }
          }
        },
      );
    },
  );
}
