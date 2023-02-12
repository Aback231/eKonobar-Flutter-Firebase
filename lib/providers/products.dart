import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import 'dart:convert';

import './product.dart';
import '../models/http_exception.dart';
import 'package:firebase_database/firebase_database.dart';

final userAccounts = FirebaseDatabase.instance.reference().child("accounts");
final userProducts = FirebaseDatabase.instance.reference().child("products");

// State Management, defining Data Provider
// here we define Provider for data that will change, so not the entire app gets redrawn but only widgets listening to data changes
class Products with ChangeNotifier {
  List<Product> _items = [];

  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  // Define getter to get a copy of all our products [...] means copy. Important so You are able to notifyListeners() on change
  List<Product> get items {
    /* if(_showFavoritesOnly){
      return _items.where((prodItem) => prodItem.isFavorite).toList();
    } */
    return [..._items];
  }

  // Return Product based on ID requested
  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProductsAdmin(
      [bool filterByUser = true, Map qrScannedMap]) async {
    print("filterByUser ID: " + qrScannedMap["idQrScanned"]);
    print("filterByUser QR: " + qrScannedMap["qrScanned"]);

    String creatorId = qrScannedMap["idQrScanned"];
    // ** To filter products by user ID server side add &orderBy='creatorId'&equalTo='$userId' to the URL
    // ** equalTo="$userId" must have "" in order to work therefore url must be url = '';
    // ** ADD RULE IN FIREBASE AFTER WRITE PERMISSION TO ENABLE FILTERING INSIDE products BY creatorId:

    var filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$creatorId"' : '';
    filterString = '';
    var url =
        'https://shop-app-212c0.firebaseio.com/products.json?auth=$authToken&$filterString';
    try {
      final response = await http.get(url);
      //print(json.decode(response.body));
      // ** This is how to get data from FIrebase, because it returns Nested Maps
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) return;
      List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        print("PRODUCTS PROVIDER: PRODUCT CREATOR ID: ${prodData["prodId"]}");
        if (prodData["creatorId"].contains(creatorId)) {
          loadedProducts.add(Product(
            id: prodId,
            title: prodData["title"],
            description: prodData["description"],
            price: prodData["price"],
            isFavorite: false,
            imageUrl: prodData["imageUrl"],
            restaurantOwnerId: prodData["restaurantOwnerId"],
            category: prodData["category"],
          ));
        }
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  // ** Get data from Firebase
  //Future<void> fetchAndSetProducts([bool filterByUser = false, String qrScanned]) async {
  Future<void> fetchAndSetProducts(
      [bool filterByUser = true, Map qrScannedMap]) async {
    print("filterByUser ID: " + qrScannedMap["idQrScanned"]);
    print("filterByUser QR: " + qrScannedMap["qrScanned"]);

    String creatorId = qrScannedMap["idQrScanned"];
    // ** To filter products by user ID server side add &orderBy='creatorId'&equalTo='$userId' to the URL
    // ** equalTo="$userId" must have "" in order to work therefore url must be url = '';
    // ** ADD RULE IN FIREBASE AFTER WRITE PERMISSION TO ENABLE FILTERING INSIDE products BY creatorId:

    /* try {
      userAccounts.once().then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> values = snapshot.value;
        values.forEach((key, values) {
          if (values["userQr"].toString().contains(qrScannedMap["qrScanned"])) {
            print("fetchAndSetProducts " +
                qrScannedMap["qrScanned"] +
                " ID IS  - " +
                "");
            print(values["userId"]);
            print(values["userQr"]);
            //userId = values["userId"];
          }
        });
      });

      final List<Product> loadedProducts = [];
      userProducts.once().then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> values = snapshot.value;
        values.forEach((prodId, prodData) {
          if (prodData["creatorId"].toString().contains(creatorId)) {
            print(prodId);
            print(prodData["title"]);
            print(prodData["price"]);

            loadedProducts.add(Product(
              id: prodId,
              title: prodData["title"],
              description: prodData["description"],
              price: prodData["price"],
              isFavorite: false,
              imageUrl: prodData["imageUrl"],
              restaurantOwnerId: prodData["restaurantOwnerId"],
              category: prodData["category"],
            ));
          }
        });
      });

      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    } */

    var filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$creatorId"' : '';
    filterString = '';
    var url =
        'https://shop-app-212c0.firebaseio.com/products.json?auth=$authToken&$filterString';
    try {
      final response = await http.get(url);
      //print(json.decode(response.body));
      // ** This is how to get data from FIrebase, because it returns Nested Maps
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) return;
      List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        //print("PRODUCTS PROVIDER: PRODUCT CREATOR ID: ${prodData}");
        if (prodData["creatorId"] == creatorId) {
          print("PRODUCTS PROVIDER: PRODUCT CREATOR ID MATCH");
          print("***********************************************");
          print(prodData["title"]);
          print(prodData["restaurantOwnerId"]);
          print(prodId);
          print("***********************************************");
          loadedProducts.add(Product(
            id: prodId,
            title: prodData["title"],
            description: prodData["description"],
            price: prodData["price"],
            isFavorite: false,
            imageUrl: prodData["imageUrl"],
            restaurantOwnerId: prodData["restaurantOwnerId"],
            category: prodData["category"],
          ));
        }
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  // ** By using Future<void> and await http.post( ... we return future, so when this function is called, we can wait for future to finish, to load a spinner for ex.
  // ** Async await is like Fture. All code after final response = await http is invisibly wrapped in than, and executes after future is returned
  Future<void> addProduct(Product product) async {
    // ** Sending request to this URL will create table products. Firebase requires .json !
    final url =
        "https://shop-app-212c0.firebaseio.com/products.json?auth=$authToken";
    // ** You must use HashMap to convert dart object to JSON, this is the way. http. is because of as http
    try {
      final response = await http.post(
        url,
        body: json.encode({
          "title": product.title,
          "description": product.description,
          "imageUrl": product.imageUrl,
          "price": product.price,
          "creatorId": userId,
          "restaurantOwnerId": product.restaurantOwnerId,
          "category": product.category,
        }),
      );
      // ** .then is future after http.post finishes execution
      // ** FIREBASE RESPONSE IS ONLY SERVER SIDE GENERATED ID
      //print(json.decode(response.body));
      print(" FIREBASE RESPONSE TO POST HTTP: " +
          json.decode(response.body).toString());
      final newProduct = Product(
        title: product.title,
        price: product.price,
        description: product.description,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)[
            "name"], // ** Firebase returns ID like {name: -M7TcQ4baE2bL9rL-MN3}
        restaurantOwnerId: product.restaurantOwnerId,
        category: product.category,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      // ** we catch error and throw a new one to catch it in our widget
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      // ** To target specific product on Firebase by ID You must change the url like this and use patch request
      final url =
          "https://shop-app-212c0.firebaseio.com/products/$id.json?auth=$authToken";
      await http.patch(url,
          body: json.encode({
            "title": newProduct.title,
            "description": newProduct.description,
            "imageUrl": newProduct.imageUrl,
            "price": newProduct.price,
            "restaurantOwnerId": newProduct.restaurantOwnerId,
            "category": newProduct.category,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        "https://shop-app-212c0.firebaseio.com/products/$id.json?auth=$authToken";
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    // http.delete doesn't give back error on error codes 400 and 500. You need to handle it manually
    // throw HttpException("Could not delete product."); would than trigger exception and we go to catchError now which exits the function
    if (response.statusCode >= 400) {
      // ReAdd product if error occures
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException("Could not delete product.");
    }
    existingProduct = null;
  }
}
