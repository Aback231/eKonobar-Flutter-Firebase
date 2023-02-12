import 'package:flutter/material.dart';
import 'package:fluttershare/screens/sign_up_method_screen.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:provider/provider.dart';
import 'providers/auth.dart';

import 'screens/cart_screen.dart';
import 'screens/edit_product_screen.dart';

import 'screens/products_overview_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/orders_screen_admin.dart';
import 'screens/user_products_screen.dart';
import 'screens/qr_screen.dart';
import 'screens/edit_qr_admin.dart';
import 'providers/products.dart';
import 'providers/cart.dart';
import 'providers/orders.dart';

void main() async {
  // Frebase initialize
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          //builder: (ctx) => Products(),
          value: Auth(),
        ),
        // ** ProxyProvider to set a Provider that depends on data from another Provider, Auth() for us. Which must be defined before Proxy
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (_) => Products('', '', []),
          update: (_, auth, prevProducts) {
            return Products(
              auth.token,
              auth.userId,
              prevProducts == null ? [] : prevProducts.items,
            );
          },
        ),
        ChangeNotifierProvider.value(
          //builder: (ctx) => Products(),
          value: Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (_) => Orders('', '', []),
          update: (_, auth, previousOrders) {
            return Orders(
              auth.token,
              auth.userId,
              previousOrders == null ? [] : previousOrders.orders,
            );
          },
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'eKonobar',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.deepPurple,
            accentColor: Colors.teal,
          ),
          home: SignUpMethod(),
          routes: {
            ProductsOverviewScreen.routeName: (ctx) => ProductsOverviewScreen(),
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            OrdersScreenAdmin.routeName: (ctx) => OrdersScreenAdmin(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
            QrScreen.routeName: (ctx) => QrScreen(),
            SignUpMethod.routeName: (ctx) => SignUpMethod(),
            EditQrAdmin.routeName: (ctx) => EditQrAdmin(),
          },
        ),
      ),
    );
  }
}
