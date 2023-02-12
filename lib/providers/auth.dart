import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';

final userAccounts = FirebaseDatabase.instance.reference().child("accounts");

bool isAuthV = false;
String signUpMethod = "none";
// Expiry duration for QR Scan 3min default
final expiryDuration = 3;

// Email Sign In
final FirebaseAuth auth = FirebaseAuth.instance;
UserCredential userCredential;
EmailAuthCredential credential;
bool emailStateChange = false;

// Google Sign In
GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: <String>[
    'profile',
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);
/* final GoogleSignIn googleSignIn = GoogleSignIn(); */

Map<String, String> userQrMapValues = {"table1": "none1", "table2": "none2"};
var listUserQrMapValues = new List<Map<String, dynamic>>();

class Auth with ChangeNotifier {
  String _token;
  String _userId;
  String _userEmail;
  String _userType;
  String _qrScanned;
  String _qrScannedId;
  String _timeStampQrScanned;
  String _qrScannedTable;
  bool _isQrScanned;
  bool _isAdmin;

  bool get isAuth {
    return auth.currentUser != null;
  }

  String get token {
    if (_token != null) {
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

  String get userType {
    return _userType;
  }

  bool get isAdmin {
    return _isAdmin;
  }

  bool get isQrScanned {
    return _isQrScanned;
  }

  String get qrScanned {
    return _qrScanned;
  }

  String get qrScannedTable {
    return _qrScannedTable;
  }

  String get qrScannedId {
    return _qrScannedId;
  }

  bool get isExpiredTimeStampQrScanned {
    if (_timeStampQrScanned.isNotEmpty && _timeStampQrScanned != "none") {
      DateTime timeStamp = DateTime.parse(_timeStampQrScanned);
      if (timeStamp
          .add(Duration(minutes: expiryDuration))
          .isAfter(DateTime.now())) {
        return true;
      }
    }
    return false;
  }

  authenticateInit() async {
    try {
      if (qrScanned == null || qrScanned.isEmpty) {
        _qrScanned = "none";
        _qrScannedId = "none";
      }
      print("authenticateInit qrScanned: $qrScanned");

      // Detects user signed in or out
      googleSignIn.onCurrentUserChanged.listen((account) {
        handleSignIn(account);
      }, onError: (err) {
        print("Google 1 Error signing in: $err");
      });
      // Reauthenticate user when app is opened
      googleSignIn.signInSilently().then((account) {
        handleSignIn(account);
      }).catchError((err) {
        print("Google 2 Error signing in: $err");
      });

      // Email Detect user signed in or out
      auth.authStateChanges().listen((User user) async {
        if (user != null) {
          user.getIdToken().then((token) => {
                //handle token
                _token = token,
                _userId = user.uid,
                _userEmail = user.email,
              });
        }
        print("AUTH PROVIDER: EMAIL authStateChanges");
        await handleEmailSignIn(user);
      }, onError: (err) {
        print("Email Error signing in: $err");
      });

      // Email Reauthenticate user when app is opened
      emailReauthenticate();
    } catch (error) {
      throw error;
    }
  }

  // Handle user Authentication state
  handleSignIn(GoogleSignInAccount account) async {
    if (account != null) {
      print("Google User signed in: ${account.email}");
      print("Google User signed in: ${account}");
      print("handleSignIn");
      //_token = account.accessToken;
      //_userId = account.id;
      //_userEmail = account.email;
      /* print("GOOGLE_SIGN_IN : idToken : ${account.id}");
      print("GOOGLE_SIGN_IN : email : ${account.email}");
      print("GOOGLE_SIGN_IN : token NON UPDATED : ${_token}"); */
      await addUserType(_userEmail, _userId, userQrMapValues, "user");
      isAuthV = true;
    }
    //notifyListeners();
  }

  // Handle user Email Authentication state
  handleEmailSignIn(User user) async {
    if (user != null) {
      print("Email User signed in: ${user.email}");
      print("Email User signed in: ${user.uid}");
      print("Email User signed in: ${user}");
      print("handleEmailSignIn");
      await addUserType(user.email, user.uid, userQrMapValues, "user");
      isAuthV = true;
      //notifyListeners();
    }
  }

  // Email Reauthenticate User if already been signed In
  emailReauthenticate() async {
    try {
      if (credential != null) {
        print("REAUTHENTICATION WAS DONE");
        await auth.currentUser.reauthenticateWithCredential(credential);
      }
    } catch (error) {
      throw error;
    }
  }

  emailSignup(String email, String password) async {
    try {
      // Create a credential for Eail Rauthentication
      credential =
          EmailAuthProvider.credential(email: email, password: password);
      userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await addUserType(userCredential.user.email, userCredential.user.uid,
          userQrMapValues, "user");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        // User exists => try to login
        print('The account already exists for that email.');
        emailSignIn(email, password);
      }
    } catch (e) {
      print(e);
    }
  }

  emailSignIn(String email, String password) async {
    try {
      userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
    notifyListeners();
  }

  Future<void> login() async {
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final User user = (await auth.signInWithCredential(credential)).user;

    await user.getIdToken().then((token) => {
          _userId = user.uid,
          _userEmail = user.email,
          _token = token,
        });
    print("GOOGLE_SIGN_IN : token : ${token}");
    print("GOOGLE_SIGN_IN : user.uid : ${user.uid}");
    print("GOOGLE_SIGN_IN : user.email : ${user.email}");
  }

  // Google Sign Out
  logout() {
    try {
      auth.signOut();
      googleSignIn.signOut();
      print("SET STATE logout to false");
      isAuthV = false;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> pullAccountData(String userId) async {
    try {
      await userAccounts.once().then((DataSnapshot snapshot) {
        if (userId != null) {
          print("AFTER QR: AUTH PROVIDER: addUserType userId : " + userId);
          Map<dynamic, dynamic> values = snapshot.value;
          if (snapshot.value != null && values.containsKey(userId)) {
            // Pulling existing user data from "accounts"
            print(
                "AFTER QR: AUTH PROVIDER: ACCOUNT FOR USER EXISTS, PULLING DATA");
            values.forEach((key, values) {
              if (values["userId"].toString().contains(userId)) {
                _userType = values["accType"];
                if (values["accType"].contains("admin"))
                  _isAdmin = true;
                else
                  _isAdmin = false;
                _timeStampQrScanned = values["timeStampQrScanned"];
                _qrScanned = values["qrScanned"];
                _qrScannedId = values["qrScannedId"];
                _qrScannedTable = values["qrScannedTable"];
                print("AFTER QR: AUTH: SCANNED TABLE: ${qrScannedTable}");
                if (!values["qr"].toString().contains("none"))
                  _isQrScanned = true;
                else
                  _isQrScanned = false;
                print("AFTER QR: AUTH PROVIDER: qrScanned: $qrScanned");
                print("AFTER QR: AUTH PROVIDER: qrScannedID: $qrScannedId");
              }
            });
          }
        }
      });
    } catch (error) {
      throw error;
    }
  }

  // Create User Type, QR table entry for new Users
  Future<void> addUserType(String userEmail, String userId,
      Map<String, String> userQr, String accType) async {
    try {
      listUserQrMapValues.add(userQrMapValues);
      await userAccounts.once().then((DataSnapshot snapshot) {
        if (userId != null) {
          print("AUTH PROVIDER: addUserType userId : " + userId);
          Map<dynamic, dynamic> values = snapshot.value;
          if (snapshot.value == null) {
            // if snapshot.value is NULL, no table "accounts" has been createdm so we create the default one
            print("AUTH PROVIDER: SNAPSHOT NULL");
            _userType = accType;
            if (accType.contains("admin"))
              _isAdmin = true;
            else
              _isAdmin = false;
            userAccounts.child(userId).set({
              "userEmail": userEmail,
              "userId": userId,
              "userQr": userQrMapValues,
              "accType": accType,
              "qrScanned": "none",
              "qrScannedId": "none",
              "qrScannedTable": "none",
              "timeStampQrScanned": "none"
            });
          }
          if (snapshot.value != null && !values.containsKey(userId)) {
            // Adding new user to "accounts"
            print("AUTH PROVIDER: CREATING NEW ACCOUNT FOR USER");
            _userType = accType;
            if (accType.contains("admin"))
              _isAdmin = true;
            else
              _isAdmin = false;
            userAccounts.child(userId).set({
              "userEmail": userEmail,
              "userId": userId,
              "userQr": userQrMapValues,
              "accType": accType,
              "qrScanned": "none",
              "qrScannedId": "none",
              "qrScannedTable": "none",
              "timeStampQrScanned": "none"
            });
          } else if (snapshot.value != null && values.containsKey(userId)) {
            // Pulling existing user data from "accounts"
            print("AUTH PROVIDER: ACCOUNT FOR USER EXISTS, PULLING DATA");
            values.forEach((key, values) {
              if (values["userId"].toString().contains(userId)) {
                _userType = values["accType"];
                if (values["accType"].contains("admin"))
                  _isAdmin = true;
                else
                  _isAdmin = false;
                _timeStampQrScanned = values["timeStampQrScanned"];
                _qrScanned = values["qrScanned"];
                _qrScannedId = values["qrScannedId"];
                _qrScannedTable = values["qrScannedTable"];
                print("AUTH: SCANNED TABLE: ${qrScannedTable}");
                if (!values["qr"].toString().contains("none"))
                  _isQrScanned = true;
                else
                  _isQrScanned = false;
                print("AUTH PROVIDER: qrScanned: $qrScanned");
                print("AUTH PROVIDER: qrScannedID: $qrScannedId");
              }
            });
          }
          notifyListeners();
        } else {
          print("AUTH PROVIDER: USERID IS NULL IN addUserType");
        }
      });
    } catch (error) {
      throw error;
    }
  }
}
