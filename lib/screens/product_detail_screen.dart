import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = "/product-detail";

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments as String;
    // Our Data Provider listener. listen: false not to update widget all the time, cause it should only update on load!
    final loadedProduct = Provider.of<Products>(
      context,
      listen: false,
    ).findById(productId);
    return Scaffold(
      /* appBar: AppBar(
        title: Text(loadedProduct.title),
      ), */
      body: CustomScrollView(
        // ** slivers are scrollable areas on the screen
        // ** CustomScrollView with sliver provides scrollable appbar and image inside it, it shrinks on scroll
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: loadedProduct.id,
                child: Image.network(
                  loadedProduct.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(
                        height: 10,
                      ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(loadedProduct.title,
                              style: TextStyle(
                              color: Colors.deepPurple[800],
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                    blurRadius: 2.0,
                                    color: Colors.deepPurple[100],
                                    offset: Offset(3.0, 3.0),
                                    ),
                                ], 
                              
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                 SizedBox(
                          width: 30,
                        ),
                Text(
                  "${loadedProduct.price} RSD",
                  style: TextStyle(
                    color: Colors.deepPurple[800],
                    fontSize: 20,
                     shadows: [
                      Shadow(
                          blurRadius: 2.0,
                          color: Colors.deepPurple[100],
                          offset: Offset(3.0, 3.0),
                          ),
                      ], 
                  ),
                  
                ),
                      ],
                    ),
                     SizedBox(height: 5,),
                    Divider(color: Colors.deepPurple,),
                    SizedBox(height: 5,),
                     Container(
                  
                  width: double.infinity,
                  child: Text(
                    loadedProduct.description,
                    style:TextStyle( color: Colors.deepPurple[800],
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                    softWrap: true,
                  ),
                ),
                  ],
                ),
              ),
              
              SizedBox(
                height: 10,
              ),
             
              SizedBox(
                height: 200,
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
