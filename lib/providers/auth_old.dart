import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
//import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;
  String _userEmail;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  String get ownerEmail {
    return _userEmail;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/$urlSegment?key=AIzaSyCI7Q_cvNikdmV33Rrp_RwSxKFVCywVzVA';
    try {
      // ** response Firebase gives back is not a real error, so we handle it manually
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      if (json.decode(response.body)["error"] != null) {
        throw HttpException(json.decode(response.body)["error"]["message"]);
      }
      /* print("responseBody" + response.body); */
      _token = json.decode(response.body)['idToken'];
      _userId = json.decode(response.body)['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            json.decode(response.body)['expiresIn'],
          ),
        ),
      );
      _userEmail = json.decode(response.body)['email'];
      if (urlSegment == "signupNewUser")
        addUserType(_userEmail, _userId, "none", "user");
      _autoLogout();
      notifyListeners();
      // ** Saving Token to device with SharedPreferences. We save a Map using JSON encode
      // ** This returns Future which eventially returns SharedPreferences
      /* final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        "token": _token,
        "userId": _userId,
        "expiryDate": _expiryDate.toIso8601String(),
        "userEmail": _userEmail
      });
      prefs.setString("userData", userData); */
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    // Must use return here to return _authenticate's Future and not the one of this Function
    return _authenticate(email, password, 'signupNewUser');
  }

  Future<void> login(String email, String password) async {
    // Must use return here to return _authenticate's Future and not the one of this Function
    return _authenticate(email, password, 'verifyPassword');
  }

  Future<bool> tryAutoLogin() async {
    /* final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("userData")) {
      return false;
    } */
    /* final extractedUserData =
        json.decode(prefs.getString("userData")) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData["expiryDate"]);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData["token"];
    _userId = extractedUserData["userId"];
    _expiryDate = expiryDate;
    _userEmail = extractedUserData["email"];
    notifyListeners();
    _autoLogout();
    return true; */
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    _userEmail = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    /*  final prefs = await SharedPreferences.getInstance();
    // ** To clear just one key
    prefs.remove("userData"); */
    // ** To clear entire SharedPreferences with all of the keys
    //prefs.clear();
  }

  // ** Setting timer for Firebase 1h Expiry for token
  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }

  Future<void> addUserType(
      String userEmail, String userId, String userQr, String accType) async {
    // ** Sending request to this URL will create table products. Firebase requires .json !
    final url =
        "https://shop-app-212c0.firebaseio.com/accounts.json?auth=$_token";
    // ** You must use HashMap to convert dart object to JSON, this is the way. http. is because of as http
    try {
      final response = await http.post(
        url,
        body: json.encode({
          "userEmail": userEmail,
          "userId": userId,
          "userQr": userQr,
          "accType": accType,
        }),
      );
      // ** .then is future after http.post finishes execution
      // ** FIREBASE RESPONSE IS ONLY SERVER SIDE GENERATED ID
      //print(json.decode(response.body));
      print(" FIREBASE RESPONSE TO POST HTTP: " +
          json.decode(response.body).toString());
      //notifyListeners();
    } catch (error) {
      print(error);
      // ** we catch error and throw a new one to catch it in our widget
      throw error;
    }
  }
}
