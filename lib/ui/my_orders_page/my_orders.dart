import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:olx_clone/model/order.dart';
import 'package:olx_clone/ui/my_orders_page/my_order_item.dart';
import 'package:olx_clone/utils/app.dart';
import 'package:olx_clone/utils/app_utils.dart';
import 'package:olx_clone/utils/font.dart';
import 'package:olx_clone/utils/order_filter.dart';
import 'package:olx_clone/utils/ui/my_dropdown.dart';
import 'package:olx_clone/utils/ui/utils.dart';

class MyOrders extends StatefulWidget {
  static final String routeName = '/ui/my_orders_page/my_orders';

  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  @override
  Widget build(BuildContext context) {
    DateTime oneMonthBefore =
        DateTime.now().subtract(Duration(days: selectedOrderFilter));

    Query query = Firestore.instance
        .collection(ORDERS_COLLECTION)
        .where(
          TIME_ORDERED,
          isGreaterThanOrEqualTo: oneMonthBefore.millisecondsSinceEpoch,
        )
        .orderBy(TIME_ORDERED, descending: true);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        title: Text(
          'My Orders',
          style: toolbarTitleStyle(),
        ),
      ),
      body: StreamBuilder(
        stream: query.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData)
            return Center(
              child: SpinKitCircle(
                color: Theme.of(context).primaryColorDark,
              ),
            );

          if (snapshot.data.documents.isEmpty)
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  alignment: Alignment.topRight,
                  padding:
                      const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
                  child: _buildFilterOrder(),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'No orders found',
                      style: TextStyle(fontSize: titleTextSize2),
                    ),
                  ),
                ),
              ],
            );

          List<DocumentSnapshot> orderList = [];
          orderList.addAll(snapshot.data.documents);

          return ListView(
            physics: BouncingScrollPhysics(),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
                child: _buildFilterOrder(),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: orderList.length,
                itemBuilder: (context, i) {
                  Order order = Order.fromMap(orderList[i].data);

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                    child: new MyOrderItem(
                      order: order,
                      context: context,
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterOrder() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(
          'Filter',
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        _buildFilterDropDown(context),
      ],
    );
  }

  Widget _buildFilterDropDown(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5.0),
      child: Container(
        alignment: Alignment.center,
        child: Theme(
          data: ThemeData.light().copyWith(textTheme: kTextTheme),
          child: MyDropdownButtonHideUnderline(
            child: MyDropdownButton<int>(
              items: orderFilterList
                  .map(
                    (filter) => MyDropdownMenuItem(
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(8.0, 8.0, 0.0, 8.0),
                            child: Center(
                              child: Text(
                                'Last ${filter == 30 ? filter : filter ~/ 30}'
                                    ' ${filter == 30 ? 'days' : 'months'}',
                                style: TextStyle(
                                  fontSize: mediumTextSize2,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          value: filter,
                        ),
                  )
                  .toList(),
              onChanged: (value) {
                if (mounted)
                  setState(() {
                    selectedOrderFilter = value;
                  });
              },
              value: selectedOrderFilter,
            ),
          ),
        ),
        decoration: getDropDownShape(context),
      ),
    );
  }
}
