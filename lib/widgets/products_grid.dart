import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../widgets/product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavs;
  final String tabIndex; // 0 = Drinks ; 1 = Food; 2 = Cakes ;
  final bool isAlcoholic;

  ProductsGrid(this.showFavs, this.tabIndex, this.isAlcoholic);

  @override
  Widget build(BuildContext context) {
    // Set Up Provider Listener
    final productsData = Provider.of<Products>(context);
    //final products = productsData.items;
    var products = productsData.items
        .where((productItem) => productItem.category == tabIndex)
        .toList();
    if (isAlcoholic && tabIndex == "Drinks") {
      print("ProductsGrid isAlcoholic: $isAlcoholic");
      products = productsData.items
          .where((productItem) => productItem.category == "Alcoholic drink")
          .toList();
    } else if (!isAlcoholic && tabIndex == "Drinks") {
      print("ProductsGrid isAlcoholic: $isAlcoholic");
      products = productsData.items
          .where((productItem) => productItem.category == "Non-alcoholic drink")
          .toList();
    }
    return GridView.builder(
      padding: const EdgeInsets.all(15),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        childAspectRatio: 3 / 1.7,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        //builder: (c) => products[i],
        value: products[i],
        child: ProductItem(),
      ),
      itemCount: products.length,
    );
  }
}
