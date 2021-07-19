import 'dart:async';

import 'package:flutter/material.dart';
import 'package:olx_clone/model/category.dart';
import 'package:olx_clone/ui/filter_page/filter_category_builder.dart';
import 'package:olx_clone/utils/app.dart';
import 'package:olx_clone/utils/app_utils.dart';
import 'package:olx_clone/utils/font.dart';

class FilterPage extends StatefulWidget {
  static final String routeName = '/filter_products';

  @override
  _FilterPageState createState() => new _FilterPageState();
}

int startPrice = 0, endPrice = 0;
String filterStartPrice = '', filterEndPrice = '';
TextEditingController startPriceController = new TextEditingController();
TextEditingController endPriceController = new TextEditingController();

Category filterCategory;

class _FilterPageState extends State<FilterPage> {
  final FocusNode toFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (startPrice != 0) startPriceController.text = startPrice.toString();
    if (endPrice != 0) endPriceController.text = endPrice.toString();
    filterCategory = selectedCategory;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => onBackPressed(false),
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColorDark,
        appBar: buildFilterAppBar(context),
        body: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(12.0),
                  children: <Widget>[
                    buildContentTitle(
                      context,
                      true,
                      Icons.local_offer,
                      '',
                      'Choose category',
                    ),
                    FilterCategoryGrid(),
                    buildPriceView(context),
                  ],
                ),
              ),
              buildApplyButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Column buildPriceView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        buildContentTitle(
          context,
          false,
          null,
          'assets/money_pouch.png',
          'Set a price range',
        ),
        Padding(
          padding: EdgeInsets.only(left: 32.0),
          child: Text(
            'Price ($INDIAN_CURRENCY)',
            style: TextStyle(
              fontSize: mediumTextSize1,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 32.0),
          child: Row(
            children: <Widget>[
              Flexible(
                child: TextField(
                  controller: startPriceController,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (text) {
                    FocusScope.of(context).requestFocus(toFocusNode);
                  },
                  decoration: InputDecoration(hintText: 'From'),
                  keyboardType: TextInputType.number,
                ),
              ),
              Container(
                width: 1.0,
                height: 40.0,
                color: Colors.grey[700],
                margin: EdgeInsets.symmetric(horizontal: 5.0),
              ),
              Flexible(
                child: TextField(
                  controller: endPriceController,
                  focusNode: toFocusNode,
                  decoration: InputDecoration(hintText: 'To'),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildApplyButton(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).accentColor,
      child: RaisedButton(
        padding: EdgeInsets.symmetric(vertical: 15.0),
        onPressed: () {
          onApply();
        },
        color: Theme.of(context).accentColor,
        child: Text(
          'APPLY  FILTERS',
          style: TextStyle(
              color: Colors.white,
              fontSize: buttonTextSize2,
              fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget buildContentTitle(BuildContext context, bool isIconAvailable,
      IconData icon, String imagePath, String title) {
    ThemeData appTheme = Theme.of(context);
    return Row(
      children: <Widget>[
        isIconAvailable
            ? Icon(icon, color: Colors.black.withOpacity(0.7))
            : Image.asset(imagePath,
                height: 24.0,
                width: 24.0,
                color: Colors.black.withOpacity(0.7)),
        Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: mediumTextSize1,
            ),
          ),
        )
      ],
    );
  }

  AppBar buildFilterAppBar(BuildContext context) {
    return AppBar(
      titleSpacing: 0.0,
      title: Text(FILTERS_TITLE, style: toolbarTitleStyle()),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          onBackPressed(true);
        },
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            if (mounted)
              setState(() {
                filterCategory = null;
                startPriceController.text = '';
                endPriceController.text = '';
              });
          },
          child: Text(
            CLEAR_FILTERS,
            style: TextStyle(color: Colors.white),
          ),
          highlightColor: Colors.transparent,
        ),
      ],
    );
  }

  showDiscardFilterDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Discard Filter',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content:
                Text('Are you sure you want to discard the unsaved changes?'),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    onDiscard();
                  },
                  child: Text(
                    'DISCARD',
                    style: TextStyle(color: Theme.of(context).primaryColorDark),
                  )),
              FlatButton(
                  onPressed: () {
                    onApply();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'APPLY',
                    style: TextStyle(color: Theme.of(context).primaryColorDark),
                  )),
            ],
          );
        });
  }

  void onDiscard() {
    if (filterCategory != selectedCategory) {
      filterCategory = null;
    }
    if (startPriceController.text != filterStartPrice) {
      startPriceController.clear();
    }
    if (endPriceController.text != filterEndPrice) {
      endPriceController.clear();
    }

    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  void onApply() {
    startPrice = startPriceController.text.isNotEmpty
        ? int.parse(startPriceController.text)
        : 0;
    endPrice = endPriceController.text.isNotEmpty
        ? int.parse(endPriceController.text)
        : 0;
    filterStartPrice =
        startPriceController.text.isNotEmpty ? startPriceController.text : '';
    filterEndPrice =
        endPriceController.text.isNotEmpty ? endPriceController.text : '';
    setSelectedCategory(filterCategory);
    Navigator.of(context).pop();
  }

  Future<bool> onBackPressed(bool isLeadingBackPress) async {
    if (filterCategory != selectedCategory ||
        startPriceController.text != filterStartPrice ||
        endPriceController.text != filterEndPrice) {
      showDiscardFilterDialog(context);
      return false;
    } else {
      if (isLeadingBackPress) Navigator.of(context).pop();
      return true;
    }
  }
}
