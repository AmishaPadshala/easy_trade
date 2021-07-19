import 'package:flutter/material.dart';
import 'package:olx_clone/ui/home_page/grid_item_builder.dart';
import 'package:olx_clone/ui/home_page/main_app_bar.dart';

MainNestedScrollViewState mainNestedScrollState = new MainNestedScrollViewState();
class MainNestedScrollView extends StatefulWidget {
  const MainNestedScrollView({Key key,}) : super(key: key);

  @override
  MainNestedScrollViewState createState() {
    if (!mainNestedScrollState.mounted)
      mainNestedScrollState = new MainNestedScrollViewState();
    return mainNestedScrollState;
  }
}

class MainNestedScrollViewState extends State<MainNestedScrollView> {

  @override
  Widget build(BuildContext context) {
    return new NestedScrollView(
      headerSliverBuilder: (context, value) {
        return <Widget>[
          new MainAppBar(),
        ];
      },
      body: new ProductsGrid(context: context),
    );
  }
}
