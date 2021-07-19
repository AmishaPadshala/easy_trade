import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:olx_clone/model/category.dart';
import 'package:olx_clone/ui/filter_page/filter_products.dart';
import 'package:olx_clone/utils/font.dart';

class FilterCategoryGrid extends StatefulWidget {
  FilterCategoryGrid();

  @override
  FilterCategoryGridState createState() {
    return new FilterCategoryGridState();
  }
}

class FilterCategoryGridState extends State<FilterCategoryGrid> {
  @override
  Widget build(BuildContext context) {
    return filterCategory == null
        ? new Padding(
            padding: const EdgeInsets.all(8.0),
            child: new GridView.count(
              crossAxisCount: 5,
              shrinkWrap: true,
              childAspectRatio: (1 / 1.0),
              physics: new NeverScrollableScrollPhysics(),
              children: buildCategories(),
            ),
          )
        : new InkWell(
            onTap: () {
              if (mounted)
                setState(() {
                  filterCategory = null;
                });
            },
            child: new Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 8.0, 8.0, 8.0),
              child: new Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new CircleAvatar(
                    backgroundImage: new CachedNetworkImageProvider(
                        filterCategory.categoryImageUrl),
                    radius: MediaQuery.of(context).size.width / 18,
                  ),
                  new Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: new Text(
                      filterCategory.title,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        fontSize: mediumTextSize1,
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
  }

  List<Widget> buildCategories() {
    List<Widget> _categoryList = [];

    for (int i = 0; i < categories.length; i++) {
      _categoryList.add(buildCategory(categories[i], i));
    }

    return _categoryList;
  }

  Widget buildCategory(Category category, int categoryPos) {
    return new InkWell(
      onTap: () {
        if (mounted)
          setState(() {
            filterCategory = categories[categoryPos];
          });
      },
      child: new Column(
        children: <Widget>[
          new CircleAvatar(
            backgroundImage:
                new CachedNetworkImageProvider(category.categoryImageUrl),
            radius: MediaQuery.of(context).size.width / 18,
          ),
          new Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: new Text(
              category.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:
                  TextStyle(color: Colors.grey[700], fontSize: mediumTextSize2),
            ),
          )
        ],
      ),
    );
  }
}
