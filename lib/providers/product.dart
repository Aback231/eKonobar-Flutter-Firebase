import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// with ChangeNotifier so we can listen for data changes isFavorite which is not inside products Provider!
class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;
  final String restaurantOwnerId;
  String category;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.imageUrl,
    this.isFavorite = false,
    @required this.price,
    @required this.restaurantOwnerId,
    @required this.category,
  });

  /* Future<void> toggleFavoriteStatus(String token, String userId) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final url = "https://shop-app-212c0.firebaseio.com/userFavorites/$userId/$id.json?auth=$token";
    try {
      final response = await http.put(url,
          body: json.encode(
            isFavorite,
          ));
          if(response.statusCode >= 400) {
            isFavorite = oldStatus;
            notifyListeners();
          }
    } catch (error) {
      isFavorite = oldStatus;
      notifyListeners();
    }
  } */
}
