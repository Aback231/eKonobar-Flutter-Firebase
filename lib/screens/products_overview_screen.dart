import 'package:flutter/material.dart';
import 'package:fluttershare/models/category_options.dart';
import 'package:fluttershare/providers/auth.dart';
import 'package:fluttershare/screens/qr_screen.dart';
import 'package:provider/provider.dart';

import '../widgets/products_grid.dart';
import '../widgets/badge.dart';
import '../providers/cart.dart';
import '../providers/products.dart';
import '../screens/cart_screen.dart';
import '../widgets/app_drawer.dart';

enum FIlterOptions {
  Favorites,
  All,
}

class ProductsOverviewScreen extends StatefulWidget {
  static const routeName = "/ProductsOverviewScreen";

  /* final String qrScanned;

  ProductsOverviewScreen(this.qrScanned); */

  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen>
    with SingleTickerProviderStateMixin {
  TabController _controller;
  int _selectedIndex = 0;
  bool isAlcoholicSelected = false;

  List<Widget> list = [
    Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            'Drinks',
          ),
          Icon(Icons.emoji_food_beverage),
        ],
      ),
      // text: 'Drinks',
    ),
    Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text('Food'),
          Icon(Icons.lunch_dining),
        ],
      ),
      // text: 'Drinks',
    ),
    Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text('Cakes'),
          Icon(Icons.cake),
        ],
      ),
      // text: 'Drinks',
    ),
  ];

  List<ListCategory> _dropdownItems = [
    ListCategory("Non-alcoholic drink"),
    ListCategory("Alcoholic drink"),
  ];
  List<DropdownMenuItem<ListCategory>> _dropdownMenuItems;
  ListCategory _selectedItem;

  var _showOnlyFavorites = false;
  var _isLoading = false;
  var _isInit = true;

  @override
  void initState() {
    super.initState();
    // Dropdown Items Drink Type
    _dropdownMenuItems = buildDropDownMenuItems(_dropdownItems);
    _selectedItem = _dropdownMenuItems[0].value;
    // Create TabController for getting the index of current tab
    _controller = TabController(length: list.length, vsync: this);

    _controller.addListener(() {
      setState(() {
        _selectedIndex = _controller.index;
      });
      print("Selected Index: " + _controller.index.toString());
    });
  }

  // need to dispose TabController cause mem leaks
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Map ar = ModalRoute.of(context).settings.arguments as Map;
      var qr = ar["qrScanned"];
      var qrID = ar["idQrScanned"];
      print("PRODUCTS OVERVIEW: didChangeDependencies: QR: ${qr}");
      print("PRODUCTS OVERVIEW: didChangeDependencies: ID: ${qrID}");
      await Provider.of<Products>(context).fetchAndSetProducts(false, ar);
      setState(() {
        _isLoading = false;
      });
    }
    _isInit = false;
  }

  List<DropdownMenuItem<ListCategory>> buildDropDownMenuItems(List listItems) {
    List<DropdownMenuItem<ListCategory>> items = List();
    for (ListCategory listItem in listItems) {
      items.add(
        DropdownMenuItem(
          child: Text(listItem.value),
          value: listItem,
        ),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    double tabPadding = MediaQuery.of(context).size.height / 15;
    final Map args = ModalRoute.of(context).settings.arguments as Map;
    print("ProductsOverviewScreen_qrScanned: " + args["qrScanned"]);
    print("ProductsOverviewScreen_qrScanned: " + args["idQrScanned"]);
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: Size(MediaQuery.of(context).size.width, 40),
          child: Center(
            child: new Column(
              children: [
                TabBar(
                  labelColor: Colors.white,
                  indicatorColor: Colors.white,
                  unselectedLabelColor: Colors.white,
                  onTap: (index) {
                    // Should not used it as it only called when tab options are clicked,
                    // not when user swapped
                  },
                  controller: _controller,
                  tabs: list,
                ),
              ],
            ),
          ),
        ),
        title: Text("Menu"),
        actions: <Widget>[
          Consumer<Cart>(
            builder: (_, cartData, child) => Badge(
              child: child,
              value: cartData.itemCount.toString(),
            ),
            child: IconButton(
              icon: Icon(
                Icons.shopping_cart,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
          // Menu Top Right in AppBar
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : //ProductsGrid(_showOnlyFavorites),
          TabBarView(
              controller: _controller,
              children: [
                // TAB 0  Drinks
                Stack(
                  children: [
                    Container(
                      // width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              //                   <--- left side
                              color: Colors.deepPurple,
                              width: 1.0),
                        ),
                        color: Colors.deepPurple[300],
                      ),
                      child: Center(
                        heightFactor: 1.0,
                        child: new Theme(
                          data: Theme.of(context).copyWith(
                            canvasColor: Colors.deepPurple[300],
                            //Theme.of(context).primaryColor,
                          ),
                          child: new DropdownButton<ListCategory>(
                              elevation: 16,
                              isExpanded: false,
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white,
                              ),
                              iconSize: 42,
                              underline: Divider(),
                              style: new TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              value: _selectedItem,
                              items: _dropdownMenuItems,
                              onChanged: (value) {
                                setState(() {
                                  _selectedItem = value;
                                  print(
                                      "Dropdown_value:  ${_selectedItem.value}");
                                  if (_selectedItem.value ==
                                      "Alcoholic drink") {
                                    isAlcoholicSelected = true;
                                    print(
                                        "Dropdown_value:  $isAlcoholicSelected");
                                  } else {
                                    isAlcoholicSelected = false;
                                    print(
                                        "Dropdown_value:  $isAlcoholicSelected");
                                  }
                                });
                              }),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: tabPadding),
                      child: ProductsGrid(
                          _showOnlyFavorites, "Drinks", isAlcoholicSelected),
                    ),
                  ],
                ),
                // TAB 1  Food
                ProductsGrid(_showOnlyFavorites, "Food", false),
                // TAB 3  Cakes
                ProductsGrid(_showOnlyFavorites, "Cakes", false),
              ],
            ),
    );
  }
}
