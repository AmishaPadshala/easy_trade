import 'package:flutter/material.dart';
import 'package:olx_clone/model/product.dart';
import 'package:olx_clone/ui/product_details_page/product_details.dart';
import 'package:olx_clone/utils/app_utils.dart';
import 'package:olx_clone/utils/font.dart';

Widget buildOrderSummary(Product product) {
  return new Padding(
    padding: const EdgeInsets.only(top: 10.0),
    child: new Column(
      children: <Widget>[
        buildOrderSummaryItem(
          leading: 'Items',
          trailing: '5',
        ),
        new Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: buildOrderSummaryItem(
            leading: 'Total Price',
            trailing: '$INDIAN_CURRENCY ${product.price *
                selectedQuantity}',
            isBold: true,
          ),
        ),
      ],
    ),
  );
}

Widget buildOrderSummaryItem(
    {String leading, String trailing, bool isBold = false}) {
  return new Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      new Text(
        '$leading',
        style: new TextStyle(
            fontSize: isBold ? mediumTextSize1 : titleTextSize4,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w400),
      ),
      new Text(
        '$trailing',
        style: new TextStyle(
            fontSize: isBold ? mediumTextSize1 : titleTextSize4,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w400),
      ),
    ],
  );
}
