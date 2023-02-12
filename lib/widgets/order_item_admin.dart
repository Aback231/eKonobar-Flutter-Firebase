import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import '../providers/orders.dart' as ord;

typedef void StringCallback(bool val);
typedef void ListgCallback(List valList);
typedef void ListgCallback1(List valList1);

class OrderItemAdmin extends StatefulWidget {
  final StringCallback callback;
  final ListgCallback callbackList;
  final ListgCallback1 callbackList1;
  final ord.OrderItem order;
  List ordersSelectedId;
  List ordersSelectedIdKey;

  OrderItemAdmin(this.callback, this.callbackList, this.callbackList1,
      this.order, this.ordersSelectedId, this.ordersSelectedIdKey);

  @override
  _OrderItemAdminState createState() => _OrderItemAdminState();
}

class _OrderItemAdminState extends State<OrderItemAdmin> {
  var _expanded = true;
  var card_color = Colors.deepPurple[100];
  var checkBox = false;
  var checkBoxValue = false;

  bool checkBoxSavedValue() {
    if (widget.order.orderTaken == null) {
      if (widget.ordersSelectedId.contains(widget.order.id))
        return true;
      else
        return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height:
          _expanded ? min(widget.order.products.length * 25.0 + 110, 200) : 95,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            side: BorderSide(width: 1.5, color: Colors.deepPurple)),
        color: card_color,
        margin: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            ListTile(
              leading: (widget.order.table) != null
                  ? Container(
                      width: 50.0,
                      height: 50.0,
                      padding: EdgeInsets.all(2.0),
                      /* margin: EdgeInsets.all(5.0), */
                      decoration: BoxDecoration(
                          color: Colors.deepPurple[200],
                          shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          "${int.parse(widget.order.table.replaceAll(RegExp('[^0-9]'), ''))}",
                          style: TextStyle(
                              color: Colors.deepPurple[900],
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  : SizedBox(),
              title: Text(
                "${widget.order.amount} RSD",
                style: TextStyle(
                    color: Colors.deepPurple[900],
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                DateFormat("dd/MM/yyy hh:mm").format(widget.order.dateTime),
                style: TextStyle(
                    color: Colors.deepPurple[800],
                    fontSize: 14,
                    fontStyle: FontStyle.italic),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                /* crossAxisAlignment: CrossAxisAlignment.center, */
                children: <Widget>[
                  Container(
                    /* width: 2,
                      height: 2, */
                    margin: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
                    child: Checkbox(
                      value: checkBoxSavedValue(),
                      onChanged: (bool newValue) {
                        setState(() {
                          checkBoxValue = newValue;
                          if (newValue) {
                            widget.ordersSelectedId.add(widget.order.id);
                            widget.ordersSelectedIdKey
                                .add(widget.order.idKeyTop);
                          } else {
                            widget.ordersSelectedId.remove(widget.order.id);
                            widget.ordersSelectedIdKey
                                .remove(widget.order.idKeyTop);
                          }
                          if (!newValue && widget.ordersSelectedId.length == 0)
                            widget.callback(false);
                          if (newValue && widget.ordersSelectedId.length == 1)
                            widget.callback(true);
                          widget.callbackList(widget.ordersSelectedId);
                          widget.callbackList1(widget.ordersSelectedIdKey);
                        });
                      },
                    ),
                  ),
                  /* Container(
                      /* margin: EdgeInsets.all(10), */
                      /* width: 2,
                      height: 2, */
                      child: IconButton(
                        iconSize: 25,
                        icon: Icon(
                          _expanded ? Icons.expand_less : Icons.expand_more,
                          color: Colors.deepPurple,
                        ),
                        onPressed: () {
                          setState(() {
                            _expanded = !_expanded;
                          });
                        },
                      ),
                    ), */
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: AnimatedContainer(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colors.white,
                    border: Border.all(width: 1.5, color: Colors.deepPurple)),
                duration: Duration(milliseconds: 300),
                height: _expanded
                    ? min(widget.order.products.length * 25.0 + 10, 100)
                    : 0,
                padding: EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 4,
                ),
                child: ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: widget.order.products
                      .map(
                        (prod) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 1),
                              child: Text(
                                prod.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.deepPurple[900],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              "${prod.quantity}x ${prod.price}\$",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.deepPurple[900],
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
