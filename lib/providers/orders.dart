import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import './cart.dart';

import 'package:firebase_database/firebase_database.dart';

final adminOrders = FirebaseDatabase.instance.reference().child("orders");

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;
  final String table;
  final String idKeyTop;
  final String orderTaken;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
    this.table,
    this.idKeyTop,
    this.orderTaken,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    try {
      final url =
          "https://shop-app-212c0.firebaseio.com/orders/$userId.json?auth=$authToken";
      final response = await http.get(url);
      final List<OrderItem> loadedOrders = [];
      final ecxtractedData = json.decode(response.body) as Map<String, dynamic>;
      if (ecxtractedData == null) return;
      ecxtractedData.forEach((orderId, orderData) {
        loadedOrders.add(
          OrderItem(
            id: orderId,
            amount: orderData["amount"],
            dateTime: DateTime.parse(orderData["dateTime"]),
            orderTaken: orderData["orderTaken"],
            products: (orderData["products"] as List<dynamic>)
                .map(
                  (item) => CartItem(
                    id: item["id"],
                    price: item["price"],
                    quantity: item["quantity"],
                    title: item["title"],
                  ),
                )
                .toList(),
          ),
        );
      });
      _orders = loadedOrders;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> fetchAndSetOrdersAdmin() async {
    try {
      /* final List<OrderItem> loadedOrders = [];
    await adminOrders.once().then((DataSnapshot snapshot) async {
      Map<dynamic, dynamic> values = snapshot.value;
      print("***** ODERS ADMIN userIdFilter *****");
      print(userId);
      if (snapshot.value != null) {
        values.forEach((key1, valuesFirst) {
          valuesFirst.forEach((key2, valuesSecond) {
            if (valuesSecond["storeId"].toString().contains(userId)) {
              print("storeId");
              print(valuesSecond["storeId"]);
              print("storeQr");
              print(valuesSecond["storeQr"]);
              print("key");
              print(key2);

              loadedOrders.add(
                OrderItem(
                  id: key2,
                  amount: valuesSecond["amount"],
                  dateTime: DateTime.parse(valuesSecond["dateTime"]),
                  products: (valuesSecond["products"] as List<dynamic>)
                      .map(
                        (item) => CartItem(
                          id: item["id"],
                          price: item["price"],
                          quantity: item["quantity"],
                          title: item["title"],
                        ),
                      )
                      .toList(),
                ),
              );
            }
          });
        });
      } else {
        print("*****ODERS ADMIN SNAPSHOT NULL*****");
      }
    }); */

      final url =
          "https://shop-app-212c0.firebaseio.com/orders.json?auth=$authToken";
      final response = await http.get(url);
      final List<OrderItem> loadedOrders = [];
      final ecxtractedData = json.decode(response.body) as Map<String, dynamic>;
      if (ecxtractedData == null) return;
      ecxtractedData.forEach((orderId, orderData) {
        orderData.forEach((key2, valuesSecond) {
          if (valuesSecond["storeId"].toString().contains(userId)) {
            print("storeId");
            print(valuesSecond["storeId"]);
            print("storeQr");
            print(valuesSecond["storeQr"]);
            print("key");
            print(key2);

            loadedOrders.add(
              OrderItem(
                idKeyTop: orderId,
                id: key2,
                amount: valuesSecond["amount"],
                dateTime: DateTime.parse(valuesSecond["dateTime"]),
                table: valuesSecond["qrScannedTable"],
                orderTaken: valuesSecond["orderTaken"],
                products: (valuesSecond["products"] as List<dynamic>)
                    .map(
                      (item) => CartItem(
                        id: item["id"],
                        price: item["price"],
                        quantity: item["quantity"],
                        title: item["title"],
                      ),
                    )
                    .toList(),
              ),
            );
          }
        });
      });

      _orders = loadedOrders;
      notifyListeners();

      /* final url =
        "https://shop-app-212c0.firebaseio.com/orders/$userIdFilter.json?auth=$authToken";
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final ecxtractedData = json.decode(response.body) as Map<String, dynamic>;
    if (ecxtractedData == null) return;
    ecxtractedData.forEach((orderId, orderData) {
      loadedOrders.add(
        OrderItem(
          id: orderId,
          amount: orderData["amount"],
          dateTime: DateTime.parse(orderData["dateTime"]),
          products: (orderData["products"] as List<dynamic>)
              .map(
                (item) => CartItem(
                  id: item["id"],
                  price: item["price"],
                  quantity: item["quantity"],
                  title: item["title"],
                ),
              )
              .toList(),
        ),
      );
    });
    _orders = loadedOrders;
    notifyListeners(); */
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total,
      String storeId, String storeQr, String storeTable) async {
    try {
      final url =
          "https://shop-app-212c0.firebaseio.com/orders/$userId.json?auth=$authToken";
      final timestamp = DateTime.now();
      final response = await http.post(url,
          body: json.encode({
            "storeId": storeId,
            "storeQr": storeQr,
            "amount": total,
            "dateTime": timestamp.toIso8601String(),
            "qrScannedTable": storeTable,
            "products": cartProducts
                .map(
                  (cp) => {
                    "id": cp.id,
                    "title": cp.title,
                    "quantity": cp.quantity,
                    "price": cp.price,
                  },
                )
                .toList(),
          }));
      _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)["name"],
          amount: total,
          dateTime: timestamp,
          products: cartProducts,
        ),
      );
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> updateOrderTaken(
      String id, String adminAccountIdKey, String currentAdminUser) async {
    adminOrders
        .child(adminAccountIdKey)
        .child(id)
        .update({"orderTaken": currentAdminUser});
  }

  /* Future<void> updateOrderTaken(String id, String adminAccountId) async {
    // ** To target specific product on Firebase by ID You must change the url like this and use patch request
    final url =
        "https://shop-app-212c0.firebaseio.com/orders/$userId.json?auth=$authToken";
    await http.patch(url, body: json.encode({"orderTaken": adminAccountId}));
    notifyListeners();
  } */
}
