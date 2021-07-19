import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:olx_clone/model/order.dart';
import 'package:olx_clone/model/product.dart';
import 'package:olx_clone/ui/product_details_page/product_details.dart';
import 'package:olx_clone/utils/app.dart';
import 'package:olx_clone/utils/app_utils.dart';
import 'package:olx_clone/utils/colors.dart';
import 'package:olx_clone/utils/font.dart';

class OrderDetails extends StatelessWidget {
  final Product product;
  final Order order;

  OrderDetails(this.product, this.order);

  @override
  Widget build(BuildContext context) {
    Query filterQuery = Firestore.instance
        .collection(PRODUCTS_COLLECTION)
        .where(CATEGORY, isEqualTo: product.category);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        title: Text(
          'Order details',
          style: toolbarTitleStyle(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'Order Summary',
                  style: Theme.of(context).textTheme.title,
                ),
                decoration: buildBorder(),
              ),
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: buildBorder(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Order date',
                            style: subItemsStyle(true, context),
                          ),
                          flex: 2,
                        ),
                        Expanded(
                          child: Text(
                            new DateFormat.yMMMEd().format(
                              new DateTime.fromMillisecondsSinceEpoch(
                                order.timeOrdered,
                              ),
                            ),
                            style: subItemsStyle(false, context),
                          ),
                          flex: 4,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'Order Id',
                              style: subItemsStyle(true, context),
                            ),
                            flex: 2,
                          ),
                          Expanded(
                            child: Text(
                              order.orderId,
                              style: subItemsStyle(false, context),
                            ),
                            flex: 4,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'Item(s)',
                              style: subItemsStyle(true, context),
                            ),
                            flex: 2,
                          ),
                          Expanded(
                            child: Text(
                              '${order.orderedQuantity} ${order.orderedQuantity > 1 ? order.priceUnit + "s" : order.priceUnit} of ${order.productName}',
                              style: subItemsStyle(false, context),
                            ),
                            flex: 4,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'Order total',
                              style: subItemsStyle(true, context),
                            ),
                            flex: 2,
                          ),
                          Expanded(
                            child: Text(
                              '$INDIAN_CURRENCY${order.orderedQuantity * order.price}',
                              style: subItemsStyle(false, context),
                            ),
                            flex: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    'Product details',
                    style: Theme.of(context).textTheme.title,
                  ),
                  decoration: buildBorder(),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: buildBorder(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      order.isDelivered
                          ? 'Delivered'
                          : 'Expected delivery date',
                      style: subItemsStyle(true, context),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Text(
                        order.isDelivered
                            ? new DateFormat.yMMMMEEEEd().format(
                                new DateTime.fromMillisecondsSinceEpoch(
                                  order.timeDelivered,
                                ),
                              )
                            : order.estimatedDeliveryDate.isEmpty
                                ? 'Unknown'
                                : '${DateFormat.yMMMEd().format(DateTime.fromMillisecondsSinceEpoch(int.parse(order.estimatedDeliveryDate)))}'
                                ' before ${order.estimatedDeliveryTime}',
                        style: TextStyle(
                          fontSize: mediumTextSize1,
                          fontWeight: FontWeight.w500,
                          color: order.isDelivered
                              ? Colors.green.shade600
                              : Colors.red.shade600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Row(
                        children: <Widget>[
                          CachedNetworkImage(
                            imageUrl: order.thumbnailUrl,
                            height: 80.0,
                            width: 80.0,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                order.productName,
                                style: subItemsStyle(true, context),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 3.0),
                                child: Text(
                                  '$INDIAN_CURRENCY${order.price}',
                                  style: TextStyle(
                                    fontSize: mediumTextSize1,
                                    color: Colors.black.withOpacity(0.7),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 3.0),
                                child: Text(
                                  'Qty: ${order.orderedQuantity}',
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ]..addAll(buildSimilarProducts(filterQuery, context, product)),
          ),
        ),
      ),
    );
  }

  List<Widget> buildSimilarProducts(
      Query filterQuery, BuildContext context, Product product) {
    return [
      new Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Text(
          'Similar Products',
          style: Theme.of(context).textTheme.title,
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

            return ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: snapshot.data.documents.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, i) {
                if ((snapshot.data.documents[i].data[PRODUCT_ID]) !=
                    product.id) {
                  return buildGridItem(
                    Product.fromDocument(snapshot.data.documents[i]),
                    context,
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

  Widget buildGridItem(Product product, BuildContext context) {
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
              Hero(
                tag: product.id,
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  placeholder: Center(
                    child: SpinKitThreeBounce(
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              Align(
                child: Container(
                  padding: const EdgeInsets.all(6.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Hero(
                        tag: product.id + product.name,
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            '$INDIAN_CURRENCY ${product.price}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: titleTextSize3,
                            ),
                          ),
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
                        secondaryTextColor.withOpacity(0.1),
                        secondaryTextColor.withOpacity(0.4),
                        secondaryTextColor.withOpacity(0.6),
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
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return ProductDetails(product);
              },
            ),
          );
        },
      ),
    );
  }

  ShapeDecoration buildBorder() {
    return ShapeDecoration(
      shape: BeveledRectangleBorder(
        side: BorderSide(color: Colors.grey, width: 0.5),
        borderRadius: BorderRadius.circular(2.0),
      ),
    );
  }

  TextStyle titleStyle(BuildContext context) {
    return TextStyle(
      fontSize: titleTextSize3,
      fontWeight: FontWeight.bold,
    );
  }

  TextStyle subItemsStyle(bool isBold, BuildContext context) {
    return TextStyle(
      fontSize: isBold ? mediumTextSize1 : titleTextSize4,
      fontWeight: isBold ? FontWeight.w500 : FontWeight.w400,
      color: isBold ? Colors.black.withOpacity(0.7) : Colors.grey.shade600,
    );
  }
}
