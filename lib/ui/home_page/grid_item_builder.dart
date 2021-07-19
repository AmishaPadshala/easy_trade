import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:olx_clone/model/cart.dart';
import 'package:olx_clone/model/category.dart';
import 'package:olx_clone/model/product.dart';
import 'package:olx_clone/ui/filter_page/filter_products.dart';
import 'package:olx_clone/ui/product_details_page/product_details.dart';
import 'package:olx_clone/utils/app_utils.dart';
import 'package:olx_clone/utils/font.dart';
import 'package:olx_clone/utils/sign_in_utils/facebook_sign_in.dart';
import 'package:olx_clone/utils/sign_in_utils/google_sign_in.dart';
import 'package:olx_clone/utils/sign_in_utils/phone_sign_in.dart';

List<Product> _products = [];

List<Product> get products => _products;

BuildContext buildContext;

class ProductsGrid extends StatefulWidget {
  ProductsGrid({@required BuildContext context}) {
    buildContext = context;
  }

  @override
  ProductsGridState createState() {
    return new ProductsGridState();
  }
}

class ProductsGridState extends State<ProductsGrid>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    CollectionReference productReference =
        Firestore.instance.collection(PRODUCTS_COLLECTION);
    Query filterQuery;

    if (startPrice != 0) {
      if (filterQuery == null) {
        filterQuery = productReference.where(PRODUCT_PRICE,
            isGreaterThanOrEqualTo: startPrice);
      } else {
        filterQuery = filterQuery.where(PRODUCT_PRICE,
            isGreaterThanOrEqualTo: startPrice);
      }
    }
    if (endPrice != 0) {
      if (filterQuery == null) {
        filterQuery = productReference.where(PRODUCT_PRICE,
            isLessThanOrEqualTo: endPrice);
      } else {
        filterQuery =
            filterQuery.where(PRODUCT_PRICE, isLessThanOrEqualTo: endPrice);
      }
    }

    if (selectedCategory != null) {
      if (filterQuery == null)
        filterQuery =
            productReference.where(CATEGORY, isEqualTo: selectedCategory.title);
      else
        filterQuery =
            filterQuery.where(CATEGORY, isEqualTo: selectedCategory.title);
    }
    return StreamBuilder<QuerySnapshot>(
      stream: filterQuery != null
          ? filterQuery.snapshots()
          : productReference.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData)
          return Center(
            child: SpinKitCircle(
              color: Theme.of(context).primaryColorDark,
            ),
          );

        if (snapshot.data.documents.length == 0)
          return Center(
            child: Text(
              'No data available',
              style: TextStyle(fontSize: titleTextSize2),
            ),
          );
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: GridView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: snapshot.data.documents.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1 / 1.30,
            ),
            itemBuilder: (context, i) {
              return ProductGridItem(
                Product.fromDocument(snapshot.data.documents[i]),
              );
            },
          ),
        );
      },
    );
  }
}

class ProductGridItem extends StatefulWidget {
  final Product product;

  ProductGridItem(this.product);

  @override
  ProductGridItemState createState() => ProductGridItemState();
}

class ProductGridItemState extends State<ProductGridItem> {
  bool isProductInCart = false, isProductInFavourites = false;

  checkIfProductIsInCart() {
    Firestore.instance
        .collection(CARTS_COLLECTION)
        .document(googleAccountId ?? facebookAccessToken ?? phoneUserName)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        Cart cart = Cart.fromMap(snapshot.data);
        if (cart.productsInCart.contains(widget.product.id) && mounted) {
          setState(() {
            isProductInCart = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
//    checkIfProductIsInCart();
    return GestureDetector(
      child: Card(
        elevation: 2.0,
        margin: const EdgeInsets.fromLTRB(8.0, 8.0, 0.0, 0.0),
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Expanded(
                  child: Hero(
                    tag: widget.product.id,
                    child: DecoratedBox(
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5.0),
                            topRight: Radius.circular(5.0),
                          ),
                        ),
                        image: DecorationImage(
                          image: NetworkImage(widget.product.imageUrl),
                        ),
                      ),
                      child: Container(),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Hero(
                        tag: widget.product.id + widget.product.name,
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            '$INDIAN_CURRENCY ${widget.product.price}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: titleTextSize3,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        widget.product.name,
                        style: TextStyle(
                          fontSize: mediumTextSize1,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: BorderDirectional(
                      top: BorderSide(
                        width: 1.5,
                        color: Theme.of(buildContext).dividerColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
//            _buildProductOptions(), // For testing
          ],
        ),
      ),
      onTap: () async {
        Navigator.of(buildContext)
            .push(new MaterialPageRoute(builder: (context) {
          return ProductDetails(widget.product);
        }));
      },
    );
  }
}
