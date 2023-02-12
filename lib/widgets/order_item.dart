import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import '../providers/orders.dart' as ord;

typedef void StringCallback(bool val);

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;

  OrderItem(this.order);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;
  var card_color = Colors.deepPurple[100];
  var ordersSelected = [];

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
              leading: (widget.order.orderTaken != null)
                  ? Container(
                      width: 50.0,
                      height: 50.0,
                      padding: EdgeInsets.all(2.0),
                      /* margin: EdgeInsets.all(5.0), */
                      decoration: BoxDecoration(
                          color: Colors.green[300], shape: BoxShape.circle),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 24.0,
                        semanticLabel:
                            'Text to announce in accessibility modes',
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
              trailing: IconButton(
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
