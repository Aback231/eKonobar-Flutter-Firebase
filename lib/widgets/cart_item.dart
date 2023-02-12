import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final double price;
  final int quantity;
  final String title;

  CartItem(
    this.id,
    this.productId,
    this.price,
    this.quantity,
    this.title,
  );

  @override
  Widget build(BuildContext context) {
    // Dismissible gives animation and removes Widget needs key to avoid issues
    return Dismissible(
      key: ValueKey(id),
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
      ),
      // Dsmiss in only one direction
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0),
                
                ),
              
                      ),
            title: Text(
              "Are You sure?",
              style: TextStyle(
                    color:  Colors.deepPurple[800],
                  ),
            ),
            content: Text(
              "Do You want to remove the item from the cart?",
              style: TextStyle(
                    color:  Colors.deepPurple[800],
                    
                  ),
            ),
            actions: <Widget>[
              Container(
                height: 35,
                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.all( Radius.circular(15.0)),
                     border: Border.all(
                    color: Colors.deepPurple[800],
                    style: BorderStyle.solid,
                    width: 1.5,
                ),
                     ),
                
                child: FlatButton(
                
                  child: Text("No",
                  style: TextStyle(
                    color:  Colors.deepPurple[800],
                  ),),
                  onPressed: () {
                    // to close dialog and forward future value true or false
                    Navigator.of(ctx).pop(false);
                  },
                
                ),
              ),
              Container(
                
                height: 35,
                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.all( Radius.circular(15.0)),
                     border: Border.all(
                    color: Colors.deepPurple[800],
                    style: BorderStyle.solid,
                    width: 1.5,
                ),
                     ),
                child: FlatButton(
                  child: Text("Yes",
                  style: TextStyle(
                    color:  Colors.deepPurple[800],
                  ),),
                  onPressed: () {
                    // to close dialog and forward future value true or false
                    Navigator.of(ctx).pop(true);
                  },
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).removeItem(productId);
      },
      child: Card(
        shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.all(
             Radius.circular(10)
             ),
           side: BorderSide(
            width: 1, 
            color: Colors.deepPurple
            )
            ),
        color: Color.fromRGBO(247,243,253,1),
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: Padding(
          padding: EdgeInsets.all(6),
          child: ListTile(
            leading: Container(
              width: 65,
              height: 65,
              child: CircleAvatar(
                child: Padding(
                  padding: EdgeInsets.all(4),
                  child: FittedBox(
                    child: Text("\$$price",
                    style: TextStyle(
                      fontSize: 16,
                    ),                    
                    ),
                  ),
                ),
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(title,
              style: TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),),
            ),
            subtitle: Text("Total: \$${(price * quantity)}",
             style: TextStyle(
              color: Colors.deepPurple,
              fontSize: 16,
            ),),
            trailing: Text("$quantity x",
             style: TextStyle(
              color: Colors.deepPurple,
              
              fontSize: 16,
            ),),
          ),
        ),
      ),
    );
  }
}
