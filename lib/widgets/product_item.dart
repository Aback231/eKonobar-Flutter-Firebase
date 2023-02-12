import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';

import '../screens/product_detail_screen.dart';

import '../providers/product.dart';
import '../providers/cart.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authData = Provider.of<Auth>(context, listen: false);
    // You can wrap widgets with Consumer widget which is like provider, but than you can reload only parts od entire widget on data change
    final product =
        Provider.of<Product>(context, listen: false); // == Consumer<Product>
    final cart = Provider.of<Cart>(context, listen: false);
    // When you use Provider.of the wholw build reruns, thus Consumer is better for performance
    // You can use listen: false to get data once and use consumer only where needed. IconButton down for us
    return ClipRRect(
     
      borderRadius: BorderRadius.circular(25),
    
      child: GridTile(
        
        child:Card(
          shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.all(
                        Radius.circular(15)),
                        
            ) ,
        child: Row(
           mainAxisAlignment: MainAxisAlignment.start ,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(
                  ProductDetailScreen.routeName,
                  arguments: product.id,
                );
              },
              // ** Wrap Image with Hero widget. You only set a unique tag, on the screen image was clicked, and that same tag on the detail screen. Iage grows into place on screen switch
              // ** Wrap Image like this on both screens
            child: Container(

             width: MediaQuery.of(context).size.width/2,
              height: MediaQuery.of(context).size.height ,
              child: Hero(
                  tag: product.id,
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                ),
            ),
            // SizedBox(width: 10),
           
            Container(
                
                width: MediaQuery.of(context).size.width/2.5,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    
                     mainAxisAlignment: MainAxisAlignment.center,
                     crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                     
                      Text(
                        product.title,
                        style: TextStyle(
                         fontSize: 18,
                         fontWeight: FontWeight.bold,
                         color: Colors.deepPurple[800]
                      ),
                      textAlign: TextAlign.center,
                      ),
                       SizedBox(height: MediaQuery.of(context).size.height/40),
                      Text('${product.price}  rsd',
                      style: TextStyle(
                         fontSize: 14,
                         fontWeight: FontWeight.bold,
                         color: Colors.deepPurple[800]
                      ),),
                       SizedBox(height: MediaQuery.of(context).size.height/40),
                   IconButton(
                  icon: Icon(Icons.shopping_cart,
                  color:Colors.red,
                  size: 30,
                  ),
                  onPressed: () {
                    cart.addItem(
                      product.id,
                      product.price,
                      product.title,
                    );
                    // to hide previous snackbar if displaying
                    Scaffold.of(context).hideCurrentSnackBar();
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.deepPurple.shade300,
                        content: Text(
                          "Item added to cart",
                        ),
                        // It is auto dismissed by default but you can set your own duration
                        duration: Duration(seconds: 2),
                        action: SnackBarAction(
                          label: "UNDO",
                          textColor: Colors.white,
                          onPressed: () {
                            cart.removeSingleItem(product.id);
                          },
                        ),
                      ),
                    );
                  },
                  color: Theme.of(context).accentColor,
          ),

                    ],
                  ),
                ),
              ),
            
            
          ],
          
        ),
        ),
        
        
      ),
    );
  }
}
