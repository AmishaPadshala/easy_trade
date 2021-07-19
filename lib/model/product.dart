import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:olx_clone/utils/app_utils.dart';

class Product {
  final id, name, priceUnit, category, imageUrl, description, timeAdded;
  int price;
  String availability;
  int availableQty;
  int selectedQty;
  final List imageUrls;

  Product({
    this.id,
    this.name,
    this.price,
    this.priceUnit,
    this.availability,
    this.availableQty,
    this.category,
    this.imageUrl,
    this.description,
    this.imageUrls,
    this.timeAdded,
  });

  Product.fromDocument(DocumentSnapshot document)
      : id = document[PRODUCT_ID],
        name = document[PRODUCT_NAME],
        price = document[PRODUCT_PRICE],
        priceUnit = document[PRODUCT_PRICE_UNIT],
        availability = document[PRODUCT_AVAILABILITY],
        availableQty = document[PRODUCT_AVAILABLE_QTY],
        selectedQty = 0,
        category = document[CATEGORY],
        imageUrl = document[PRODUCT_THUMBNAIL],
        description = document[PRODUCT_DESCRIPTION] ?? '',
        imageUrls = document[PRODUCT_IMAGE_URLS],
        timeAdded = document[TIME_ADDED];

  Map<String, dynamic> toMap() {
    return {
      PRODUCT_ID: id,
      PRODUCT_NAME: name,
      PRODUCT_PRICE: price,
      PRODUCT_PRICE_UNIT: priceUnit,
      PRODUCT_AVAILABILITY: availability,
      PRODUCT_AVAILABLE_QTY: availableQty,
      CATEGORY: category,
      PRODUCT_THUMBNAIL: imageUrl,
      PRODUCT_DESCRIPTION: description,
      PRODUCT_IMAGE_URLS: imageUrls,
      TIME_ADDED: timeAdded,
    };
  }
}
