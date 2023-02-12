import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/providers/auth.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item_admin.dart';
import '../widgets/app_drawer_admin.dart';

class OrdersScreenAdmin extends StatefulWidget {
  static const routeName = "/orders_admin";

  @override
  _OrdersScreenAdminState createState() => _OrdersScreenAdminState();
}

class _OrdersScreenAdminState extends State<OrdersScreenAdmin> {
  var _isLoading = false;
  bool orderSelectionMode = false;
  List seledtedOrders = [];
  List seledtedOrdersIdKey = [];

  set string(bool value) => setState(() => orderSelectionMode = value);
  set list(List listValue) => setState(() => seledtedOrders = listValue);
  set list1(List listValueKey) =>
      setState(() => seledtedOrdersIdKey = listValueKey);

  @override
  void initState() {
    Future.delayed(Duration.zero).then((_) async {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<Orders>(context, listen: false)
          .fetchAndSetOrdersAdmin();
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Future<void> didChangeDependencies() async {
    if (_isLoading) {
      await Provider.of<Orders>(context, listen: false)
          .fetchAndSetOrdersAdmin();
    }
    setState(() {
      _isLoading = false;
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Guest orders"),
      ),
      floatingActionButton: Visibility(
        visible: orderSelectionMode,
        child: FloatingActionButton.extended(
          label: Text("Submit"),
          icon: Icon(Icons.check),
          onPressed: () async {
            /* print("seledtedOrders" + seledtedOrders.toString());
            print("seledtedOrders userID " + seledtedOrdersIdKey.toString());
            print("seledtedOrders userAdmin " +
                Provider.of<Auth>(context).userId); */
            for (int i = 0; i < seledtedOrdersIdKey.length; i++) {
              Provider.of<Orders>(context).updateOrderTaken(
                seledtedOrders[i],
                seledtedOrdersIdKey[i],
                Provider.of<Auth>(context).userId,
              );
            }
            setState(() {
              seledtedOrders = [];
              seledtedOrdersIdKey = [];
              _isLoading = true;
              orderSelectionMode = false;
            });
            await Provider.of<Orders>(context, listen: false)
                .fetchAndSetOrdersAdmin();
            Flushbar(
              backgroundColor: Colors.deepPurple.shade300,
              title: "Submit success",
              message: "Order taken submit success",
              duration: Duration(seconds: 4),
            )..show(context);
            setState(() {
              _isLoading = false;
            });
          },
        ),
      ),
      drawer: AppDrawerAdmin(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: orderData.orders.length,
              itemBuilder: (ctx, i) => OrderItemAdmin(
                (val) => setState(() => orderSelectionMode = val),
                (listValue) => setState(() => seledtedOrders = listValue),
                (listValue1) =>
                    setState(() => seledtedOrdersIdKey = listValue1),
                orderData.orders[i],
                seledtedOrders,
                seledtedOrdersIdKey,
              ),
            ),
    );
  }

  void updateTimeStamp(seledtedOrder, userType) {}
}
