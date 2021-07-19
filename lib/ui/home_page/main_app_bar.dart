//import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:olx_clone/model/category.dart';
import 'package:olx_clone/ui/filter_page/filter_products.dart';
import 'package:olx_clone/ui/home_page/main_nested_scroll.dart';
import 'package:olx_clone/ui/product_details_page/product_details_builder.dart';
import 'package:olx_clone/utils/app.dart';
import 'package:olx_clone/utils/app_utils.dart';
import 'package:olx_clone/utils/font.dart';

//import 'package:http/http.dart' as http;
//import 'package:location/location.dart';

class MainAppBar extends StatefulWidget {
  @override
  MainAppBarState createState() {
    return new MainAppBarState();
  }
}

class MainAppBarState extends State<MainAppBar>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    getCategoriesFromServer(onComplete: () {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return new SliverAppBar(
      titleSpacing: 0.0,
      pinned: false,
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).primaryColor,
      title: Row(
        children: <Widget>[
          mainAppbarTitle(),
          Row(
            children: <Widget>[
              buildSearchButton(
                Icons.search,
              ),
              buildCartIcon(context, Theme.of(context).iconTheme.color),
            ],
          ),
        ],
      ),
      bottom: buildTabBar(),
//      forceElevated: true,
    );
  }

  Widget buildDrawerMenu(BuildContext context) {
    return Material(
      type: MaterialType.circle,
      color: Colors.transparent,
      child: new InkWell(
        child: new Padding(
          padding: const EdgeInsets.all(10.0),
          child: new Icon(Icons.menu),
        ),
        onTap: () {
          Scaffold.of(context).openDrawer();
        },
      ),
    );
  }

  List<Widget> buildFilterTab() {
    List<Widget> rowItems = [];
    if (selectedCategory != null) {
      rowItems.add(
        new FractionallySizedBox(
          heightFactor: 0.7,
          child: new Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 8.0),
            child: new Chip(
              deleteButtonTooltipMessage: 'Remove fillter',
              deleteIconColor: Theme.of(context).primaryColorDark,
              label: new Text(
                selectedCategory.title,
                style: new TextStyle(
                  fontSize: mediumTextSize1,
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
              deleteIcon: new Icon(Icons.delete, size: 20.0),
              onDeleted: () {
                if (mainNestedScrollState.mounted)
                  mainNestedScrollState.setState(() {
                    setSelectedCategory(null);
                  });
              },
              padding: const EdgeInsets.all(8.0),
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
      );
    }
    if (startPrice != 0) rowItems.add(buildPriceFilter(true));
    if (endPrice != 0) rowItems.add(buildPriceFilter(false));

    return rowItems;
  }

  Widget buildTabBar() {
    List<Widget> filters = [];
    filters = buildFilterTab();
    return filters.length == 0
        ? new PreferredSize(
            preferredSize: new Size(
              double.infinity,
              MediaQuery.of(context).size.height / 8,
            ),
            child: new SizedBox(
              height: MediaQuery.of(context).size.height / 8.0,
              child: new ListView(
                physics: new BouncingScrollPhysics(),
                itemExtent: MediaQuery.of(context).size.width / 5.5,
                scrollDirection: Axis.horizontal,
                children: buildCategories(),
              ),
            ),
          )
        : new PreferredSize(
            preferredSize: new Size(
                double.infinity, MediaQuery.of(context).size.height / 9),
            child: new SizedBox(
              height: MediaQuery.of(context).size.height / 10,
              child: new ListView(
                physics: new BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                children: filters,
              ),
            ),
          );
  }

  Widget buildPriceFilter(bool isStartPrice) {
    return new FractionallySizedBox(
      heightFactor: 0.7,
      child: new Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 8.0),
        child: new Chip(
          label: new Text(
            isStartPrice
                ? 'From  $INDIAN_CURRENCY $startPrice'
                : 'To  $INDIAN_CURRENCY $endPrice',
            style: new TextStyle(fontSize: mediumTextSize1),
          ),
          deleteIcon: new Icon(Icons.delete, size: 20.0),
          onDeleted: () {
            if (mainNestedScrollState.mounted)
              mainNestedScrollState.setState(() {
                if (isStartPrice) {
                  startPrice = 0;
                  startPriceController.clear();
                } else {
                  endPrice = 0;
                  endPriceController.clear();
                }
              });
          },
          padding: const EdgeInsets.all(8.0),
          backgroundColor: Colors.transparent,
          shape: new RoundedRectangleBorder(
            side: new BorderSide(width: 2.0, color: Colors.grey),
            borderRadius: new BorderRadius.all(new Radius.circular(20.0)),
          ),
        ),
      ),
    );
  }

  List<Widget> buildCategories() {
    List<Widget> _categoryList = [];

    for (Category category in categories) {
      _categoryList.add(buildCategoryTab(category));
    }

    return _categoryList;
  }

  Widget buildCategoryTab(Category category) {
    double radius = MediaQuery.of(context).size.width / 18;
    return new InkWell(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(
            backgroundImage: NetworkImage(category.categoryImageUrl),
            radius: radius,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: new Text(
              category.title,
              textAlign: TextAlign.center,
              style: new TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
      onTap: () {
        if (mainNestedScrollState.mounted)
          mainNestedScrollState.setState(() {
            setSelectedCategory(category);
          });
      },
    );
  }

  Decoration getIndicatorDecoration() {
    return new ShapeDecoration(
        shape: new UnderlineInputBorder(
            borderRadius: new BorderRadius.all(new Radius.circular(0.0))));
  }

  Widget mainAppbarTitle() {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          buildDrawerMenu(context),
          Expanded(
            child: new Text(
              'Easy trade'.toUpperCase(),
              style: toolbarTitleStyle(),
              maxLines: 1,
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSearchButton(IconData icon) {
    return Material(
      type: MaterialType.circle,
      color: Colors.transparent,
      child: new InkWell(
        child: new Padding(
          padding: const EdgeInsets.all(10.0),
          child: new Icon(icon),
        ),
        onTap: () {
          // TODO
        },
      ),
    );
  }

//  MaterialButton buildFilterButton(String iconPath, String text) {
//    return new MaterialButton(
//      padding: const EdgeInsets.all(0.0),
//      onPressed: () async {
//        await Navigator.pushNamed(context, FilterPage.routeName);
//        if (mainNestedScrollState.mounted)
//          mainNestedScrollState.setState(() {});
//      },
//      child: new Row(
//        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//        children: <Widget>[
//          new Image.asset(
//            iconPath,
//            color: Theme.of(context).primaryColorDark,
//            height: 24.0,
//            width: 24.0,
//          ),
//          new Padding(
//            padding: const EdgeInsets.only(left: 8.0),
//            child: new Text(
//              text,
//              style: new TextStyle(
//                color: Theme.of(context).primaryColorDark,
//                fontSize: mediumTextSize2,
//              ),
//            ),
//          ),
//        ],
//      ),
//    );
//  }

//  getLocation() async {
//    var location = new Location();
//    var currentLocation = await location.getLocation();
//    var res = await http.get(Uri.parse(
//        'http://maps.googleapis.com/maps/api/geocode/json?latlng=${currentLocation['latitude']},${currentLocation['longitude']}'));
//
//    print('Location: ${json.decode(res.body)}');
//    if (mounted)
//      setState(() {
//        _myLocation = json.decode(res.body)['results'][0]['formatted_address'];
//      });
//  }
}
