import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:olx_clone/utils/app_utils.dart';

class Category {
  final String categoryImageUrl;
  final String title;

  Category(this.categoryImageUrl, this.title);
}

List<Category> _categories = [];

List<Category> get categories => _categories;

getCategoriesFromServer({Function onComplete}) async {
  Firestore.instance
      .collection(CATEGORIES_COLLECTION)
      .snapshots()
      .listen((QuerySnapshot snapshot) {
    _categories.clear();
    for (DocumentSnapshot document in snapshot.documents) {
      _categories.add(
          new Category(document[CATEGORY_IMAGE_URL], document[CATEGORY_NAME]));
    }
    onComplete();
  });
}

Category _selectedCategory;
Category get selectedCategory => _selectedCategory;

setSelectedCategory(Category category) {
  _selectedCategory = category;
}
