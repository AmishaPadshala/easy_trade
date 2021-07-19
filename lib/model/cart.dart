import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:olx_clone/utils/app_utils.dart';

class Cart {
  List<dynamic> productsInCart = [];
  int cartItemsCount;

  Cart({@required this.productsInCart, @required this.cartItemsCount});

  Cart.fromDocument(DocumentSnapshot document)
      : productsInCart = document[PRODUCTS_IN_CART],
        cartItemsCount = document[CART_ITEMS_COUNT];

  Cart.fromMap(Map map)
      : productsInCart = map[PRODUCTS_IN_CART],
        cartItemsCount = map[CART_ITEMS_COUNT];

  Map<String, dynamic> toMap() {
    return {
      PRODUCTS_IN_CART: productsInCart,
      CART_ITEMS_COUNT: cartItemsCount,
    };
  }
}
