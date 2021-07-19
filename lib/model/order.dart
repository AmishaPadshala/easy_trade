import 'package:meta/meta.dart';
import 'package:olx_clone/utils/app_utils.dart';

class Order {
  final int timeOrdered;
  String estimatedDeliveryDate, estimatedDeliveryTime;
  int timeDelivered;
  var isDelivered;
  final orderId,
      productId,
      productName,
      thumbnailUrl,
      category,
      orderedQuantity,
      price,
      priceUnit,
      googleAccountId,
      facebookAccessToken,
      customerAddress,
      customerName;

  Order(
      {@required this.orderId,
      @required this.productId,
      @required this.productName,
      @required this.thumbnailUrl,
      @required this.category,
      @required this.orderedQuantity,
      @required this.timeOrdered,
      this.timeDelivered = 0,
      this.estimatedDeliveryDate = '',
      this.estimatedDeliveryTime = '',
      @required this.price,
      @required this.priceUnit,
      @required this.googleAccountId,
      @required this.facebookAccessToken,
      @required this.customerAddress,
      @required this.customerName,
      this.isDelivered = false});

  Map<String, dynamic> toMap() => {
        ORDER_ID: orderId,
        PRODUCT_ID: productId,
        PRODUCT_NAME: productName,
        PRODUCT_THUMBNAIL: thumbnailUrl,
        CATEGORY: category,
        ORDERED_QUANTITY: orderedQuantity,
        TIME_ORDERED: timeOrdered,
        TIME_DELIVERED: timeDelivered,
        ESTIMATED_DELIVERY_DATE: estimatedDeliveryDate,
        ESTIMATED_DELIVERY_TIME: estimatedDeliveryTime,
        PRODUCT_PRICE: price,
        PRODUCT_PRICE_UNIT: priceUnit,
        GOOGLE_ACCOUNT_ID: googleAccountId,
        FACEBOOK_ACCESS_TOKEN: facebookAccessToken,
        CUSTOMER_ADDRESS: customerAddress,
        CUSTOMER_NAME: customerName,
        DELIVERED: isDelivered
      };

  Order.fromMap(Map document)
      : orderId = document[ORDER_ID],
        productId = document[PRODUCT_ID],
        productName = document[PRODUCT_NAME],
        thumbnailUrl = document[PRODUCT_THUMBNAIL],
        category = document[CATEGORY],
        orderedQuantity = document[ORDERED_QUANTITY],
        timeOrdered = document[TIME_ORDERED],
        timeDelivered = document[TIME_DELIVERED],
        estimatedDeliveryDate = document[ESTIMATED_DELIVERY_DATE],
        estimatedDeliveryTime = document[ESTIMATED_DELIVERY_TIME],
        price = document[PRODUCT_PRICE],
        priceUnit = document[PRODUCT_PRICE_UNIT],
        googleAccountId = document[GOOGLE_ACCOUNT_ID],
        facebookAccessToken = document[FACEBOOK_ACCESS_TOKEN],
        customerAddress = document[CUSTOMER_ADDRESS],
        customerName = document[CUSTOMER_NAME],
        isDelivered = document[DELIVERED];
}
