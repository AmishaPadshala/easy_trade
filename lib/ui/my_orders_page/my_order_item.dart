import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:olx_clone/model/order.dart';
import 'package:olx_clone/model/product.dart';
import 'package:olx_clone/ui/my_orders_page/order_details.dart';
import 'package:olx_clone/ui/product_details_page/product_details.dart';
import 'package:olx_clone/ui/purchase_page/order_confirmation_bottom_sheet.dart';
import 'package:olx_clone/utils/app_utils.dart';
import 'package:olx_clone/utils/colors.dart';
import 'package:olx_clone/utils/font.dart';

class MyOrderItem extends StatelessWidget {
  final Order order;
  Product product;
  final BuildContext context;

  MyOrderItem({
    @required this.order,
    @required this.context,
  }) {
    Firestore.instance
        .collection(PRODUCTS_COLLECTION)
        .document(order.productId)
        .get()
        .then((DocumentSnapshot snapshot) {
      product = Product.fromDocument(snapshot);
      product.selectedQty = order.orderedQuantity;
    });
  }

  @override
  Widget build(BuildContext context) {
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
      child: Card(
        margin: const EdgeInsets.all(0.0),
        child: Padding(
          padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            order.productName,
                            style: TextStyle(
                              fontSize: titleTextSize3,
                              color: secondaryTextColor,
                              fontWeight: FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: mediumTextSize1,
                                  color: secondaryTextColor.withOpacity(0.8),
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: '$INDIAN_CURRENCY',
                                    style: TextStyle(
                                      color:
                                          secondaryTextColor.withOpacity(0.8),
                                      fontWeight: FontWeight.w300,
                                      fontSize: mediumTextSize2,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        '${order.orderedQuantity * order.price}',
                                    style: TextStyle(
                                      color:
                                          secondaryTextColor.withOpacity(0.8),
                                      fontWeight: FontWeight.w500,
                                      fontSize: titleTextSize1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          buildDeliveryStatus(),
                        ],
                      ),
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        CachedNetworkImage(
                          imageUrl: order.thumbnailUrl,
                          height: 80.0,
                          width: 80.0,
                        ),
                        order.isDelivered ? buildDeliveredStamp() : Container(),
                      ],
                    ),
                  ],
                ),
              ),
              buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDeliveryStatus() {
    return order.isDelivered
        ? Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              'Delivered on ${DateFormat.yMMMEd().format(new DateTime.fromMillisecondsSinceEpoch(order.timeDelivered))}',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 15.0,
              ),
              overflow: TextOverflow.clip,
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: order.estimatedDeliveryDate.isEmpty
                ? Text(
                    'Estimated delivery time not known',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 15.0,
                    ),
                    overflow: TextOverflow.clip,
                  )
                : Text(
                    'Expected delivery date ${DateFormat.yMMMEd().format(DateTime.fromMillisecondsSinceEpoch(int.parse(order.estimatedDeliveryDate)))}'
                        ' before ${order.estimatedDeliveryTime}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 15.0,
                    ),
                    overflow: TextOverflow.clip,
                  ),
          );
  }

  RotationTransition buildDeliveredStamp() {
    return RotationTransition(
      turns: new AlwaysStoppedAnimation(-45 / 360),
      child: Container(
        padding: const EdgeInsets.all(2.0),
        decoration: ShapeDecoration(
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(1.0),
            ),
            side: BorderSide(color: Colors.green, width: 1.0),
          ),
        ),
        child: Text(
          'Delivered',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
        ),
      ),
    );
  }

  Padding buildActions() {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _buildActionButton(
              'View',
              Icons.event_note,
              _viewOrderDetails,
              order,
            ),
          ),
          Expanded(
            child: _buildActionButton(
              'Buy again',
              Icons.shopping_cart,
              _buyProductAgain,
              order,
            ),
          ),
        ],
      ),
    );
  }

  _viewOrderDetails(Order order) {
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          return new OrderDetails(product, order);
        },
      ),
    );
  }

  _buyProductAgain(Order order) {
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          return new OrderConfirmation(product, () {});
        },
      ),
    );
  }

  FlatButton _buildActionButton(
      String title, IconData icon, Function callback, Order order) {
    return FlatButton.icon(
      onPressed: () => callback(order),
      icon: Icon(
        icon,
        size: 17.0,
        color: Colors.black.withOpacity(0.6),
      ),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.black.withOpacity(0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      color: Colors.transparent,
    );
  }
}
