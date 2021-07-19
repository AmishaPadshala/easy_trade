import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:olx_clone/model/product.dart';
import 'package:olx_clone/model/product_images.dart';
import 'package:olx_clone/ui/home_page/grid_item_builder.dart';
import 'package:olx_clone/ui/home_page/main_drawer.dart';
import 'package:olx_clone/ui/product_details_page/product_details_builder.dart';
import 'package:olx_clone/ui/product_details_page/product_preview.dart';
import 'package:olx_clone/ui/purchase_page/order_confirmation_bottom_sheet.dart';
import 'package:olx_clone/utils/add_or_remove_from_cart.dart';
import 'package:olx_clone/utils/app.dart';
import 'package:olx_clone/utils/app_utils.dart';
import 'package:olx_clone/utils/font.dart';

List<ProductScreenshot> screenshots = [];
List<int> quantities = [];
int selectedQuantity;

class ProductDetails extends StatefulWidget {
  final Product product;

  ProductDetails(this.product);

  @override
  ProductDetailsState createState() => new ProductDetailsState();
}

class ProductDetailsState extends State<ProductDetails> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  @override
  void initState() {
    super.initState();

    generateQuantitiesList();
    loadPreviews();
  }

  generateQuantitiesList() {
    quantities = [];
    int qty = 0;
    if (widget.product.availability == IN_STOCK) {
      quantities = List.generate(widget.product.availableQty, (i) {
        return ++qty;
      });
    }
  }

  loadPreviews() {
    screenshots.clear();
    for (String url in widget.product.imageUrls) {
      screenshots.add(new ProductScreenshot(imagePath: url));
    }
    selectedQuantity =
        widget.product.selectedQty = quantities.length == 0 ? 0 : quantities[0];
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference productReference =
        Firestore.instance.collection(PRODUCTS_COLLECTION);
    Query filterQuery =
        productReference.where(CATEGORY, isEqualTo: widget.product.category);

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 10.0,
        titleSpacing: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          widget.product.name,
          style: toolbarTitleStyle(),
        ),
        actions: <Widget>[buildCartIcon(context, Colors.white)],
      ),
      body: buildBody(filterQuery),
      drawer: MainDrawer(),
    );
  }

  Widget buildBody(Query filterQuery) {
    return ListView(
      padding: const EdgeInsets.all(10.0),
      children: <Widget>[
        buildNameAndRating(widget.product, context),
        buildPreview(context),
        buildPrice(context, widget.product, () {
          if (mounted) setState(() {});
        }),
        buildAvailability(widget.product, context),
        buildPurchaseButtons(() {
          if (mounted) setState(() {});
        }),
        buildDescription(widget.product),
      ]..addAll(buildSimilarProducts(filterQuery)),
    );
  }

  Widget buildPurchaseButtons(Function callback) {
    return Row(
      children: <Widget>[
        Expanded(
          child: OutlineButton(
            highlightElevation: 0.0,
            splashColor: Theme.of(context).accentColor.withOpacity(0.5),
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            color: Theme.of(context).backgroundColor,
            highlightedBorderColor: Theme.of(context).primaryColorDark,
            onPressed: widget.product.availability == IN_STOCK
                ? () {
                    addItemToCart(
                      product: widget.product,
                      context: context,
                      scaffoldKey: _scaffoldKey,
                    );
                  }
                : null,
            child: Text(
              ADD_TO_CART,
              style: TextStyle(
                fontSize: buttonTextSize2,
                color: widget.product.availability == IN_STOCK
                    ? Theme.of(context).primaryColorDark
                    : Theme.of(context).disabledColor,
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: RaisedButton(
              elevation: 0.0,
              highlightElevation: 0.0,
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              disabledColor: Theme.of(context).textSelectionColor,
              onPressed: widget.product.availability == IN_STOCK
                  ? () {
                      showPurchaseConfirmation(callback);
                    }
                  : null,
              child: Text(
                BUY_NOW,
                style: TextStyle(
                  fontSize: buttonTextSize2,
                  color: widget.product.availability == IN_STOCK
                      ? Colors.white
                      : Theme.of(context).disabledColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  showPurchaseConfirmation(Function callback) async {
    _scaffoldKey.currentState
        .showBottomSheet((context) {
          return OrderConfirmation(widget.product, callback);
        })
        .closed
        .then((_) {
          if (mounted)
            setState(() {
              generateQuantitiesList();
            });
        });
  }

  Widget buildOrderSummaryItem(
      {String leading, String trailing, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          '$leading',
          style: TextStyle(
            fontSize: mediumTextSize1,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
          ),
        ),
        Text(
          '$trailing',
          style: TextStyle(
            fontSize: mediumTextSize1,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Container buildPreview(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      height: MediaQuery.of(context).size.height / 1.7,
      child: Hero(
        tag: widget.product.id,
        child: ProductPreview(screenshots),
      ),
    );
  }

  List<Widget> buildSimilarProducts(Query filterQuery) {
    return [
      new Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Text(
          'Similar Products',
          style: TextStyle(
            color: Colors.black,
            fontSize: mediumTextSize1,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      new Container(
        height: MediaQuery.of(context).size.width / 2,
        child: StreamBuilder(
          stream: filterQuery.snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData || snapshot.data.documents.length == 0)
              return Container();

            return new ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: snapshot.data.documents.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, i) {
                if ((snapshot.data.documents[i].data[PRODUCT_ID]) !=
                    widget.product.id) {
                  return buildGridItem(
                    Product.fromDocument(snapshot.data.documents[i]),
                  );
                } else
                  return Container();
              },
            );
          },
        ),
      ),
    ];
  }

  Widget buildGridItem(Product product) {
    return Container(
      width: MediaQuery.of(context).size.width / 2.5,
      child: GestureDetector(
        child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 0.7,
              )),
          elevation: 2.0,
          margin: const EdgeInsets.only(right: 10.0),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              CachedNetworkImage(
                imageUrl: product.imageUrl,
                placeholder: Center(
                  child: SpinKitThreeBounce(
                    color: Theme.of(context).primaryColorDark,
                  ),
                ),
                fit: BoxFit.cover,
              ),
              Align(
                child: Container(
                  padding: const EdgeInsets.all(6.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '$INDIAN_CURRENCY ${product.price}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: titleTextSize3,
                        ),
                      ),
                      Text(
                        product.name,
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8.0),
                      bottomRight: Radius.circular(8.0),
                    ),
                    gradient: LinearGradient(
                      colors: <Color>[
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.5),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                alignment: Alignment.bottomCenter,
              ),
            ],
          ),
        ),
        onTap: () async {
          await Navigator.of(buildContext).push(
            MaterialPageRoute(
              builder: (context) {
                return ProductDetails(product);
              },
            ),
          );
          generateQuantitiesList();
          loadPreviews();
        },
      ),
    );
  }
}
