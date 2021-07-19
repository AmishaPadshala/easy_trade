import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:olx_clone/main.dart';
import 'package:olx_clone/ui/address_page/edit_address.dart';
import 'package:olx_clone/ui/cart_page/my_cart.dart';
import 'package:olx_clone/ui/filter_page/filter_products.dart';
import 'package:olx_clone/ui/home_page/main_nested_scroll.dart';
import 'package:olx_clone/ui/my_orders_page/my_orders.dart';

class MainNavigationItem {
  final String title;
  final IconData icon;
  final Function callback;
  bool isFilterTab;

  MainNavigationItem({
    this.title,
    this.icon,
    this.callback,
    this.isFilterTab = false,
  });
}

List<dynamic> _navigationItems = [
  MainNavigationItem(
    title: 'Home',
    icon: Icons.home,
    callback: home,
  ),
  MainNavigationItem(
    title: 'Filter Products',
    callback: filterProducts,
    isFilterTab: true,
  ),
  MainNavigationItem(
    title: 'My Orders',
    icon: Icons.shopping_cart,
    callback: myOrders,
  ),
  MainNavigationItem(
    title: 'Cart',
    icon: Icons.add_shopping_cart,
    callback: cart,
  ),
  MainNavigationItem(
    title: 'Favourites',
    icon: Icons.star,
    callback: favourites,
  ),
  MainNavigationItem(
    title: 'Edit Addresses',
    icon: Icons.location_on,
    callback: editAddresses,
  ),
  MainNavigationItem(
    title: 'Settings',
    icon: Icons.settings,
    callback: settings,
  ),
  MainNavigationItem(
    title: 'Exit',
    icon: Icons.exit_to_app,
    callback: exitApplication,
  ),
];

BuildContext buildContext;

List<Widget> getNavigationItems(BuildContext context) {
  buildContext = context;

  List<Widget> items = [];
  for (var item in _navigationItems) {
    if (item is MainNavigationItem) {
      items.add(buildDrawerItem(item));
    } else {
      items.add(item);
    }
  }
  return items;
}

Widget buildDrawerItem(MainNavigationItem item) {
  return Container(
    color: Colors.white,
    child: ListTile(
      title: Text(item.title),
      leading: item.isFilterTab
          ? Image.asset(
              'assets/filter.png',
              height: 20.0,
              width: 20.0,
              color: Colors.black54,
            )
          : Icon(
              item.icon,
              color: Colors.black54,
            ),
      onTap: item.callback,
    ),
  );
}

Widget buildPendingOrders(MainNavigationItem item) {
  return ListTile(
    title: Text(item.title),
    leading: Padding(
      padding: const EdgeInsets.all(5.0),
      child: Image.asset(
        'assets/pending_orders.png',
        height: 20.0,
        width: 20.0,
        color: Theme.of(buildContext).accentColor.withOpacity(0.8),
      ),
    ),
    onTap: item.callback,
  );
}

void home() {
  Navigator.of(buildContext).popUntil(ModalRoute.withName(MainPage.routeName));
}

Future filterProducts() async {
  Navigator.of(buildContext).pop();
  await Navigator.pushNamed(buildContext, FilterPage.routeName);
  if (mainNestedScrollState.mounted) mainNestedScrollState.setState(() {});
}

void favourites() {
  print('favourites');
}

void myOrders() {
  Navigator.of(buildContext).pop();
  Navigator.pushNamed(buildContext, MyOrders.routeName);
}

void cart() {
  Navigator.of(buildContext).pop();
  Navigator.pushNamed(buildContext, MyCart.routeName);
}

void pendingOrders() {
  print('pendingOrders');
}

void editAddresses() {
  Navigator.of(buildContext).pop();
  Navigator.pushNamed(buildContext, EditAddress.routeName);
}

void settings() {
  print('settings');
}

void exitApplication() {
  exit(0);
}
