import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:provider/provider.dart';

import './qr_screen.dart';
import './products_overview_screen.dart';
import './user_products_screen.dart';

import '../providers/auth.dart';

class SignUpMethod extends StatefulWidget {
  static const routeName = '/signUpMethod';

  @override
  _SignUpMethodState createState() => _SignUpMethodState();
}

class _SignUpMethodState extends State<SignUpMethod> {
  var _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    usernameController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Initialize Login state change Firebase listeners
    Future.delayed(Duration.zero).then((_) async {
      /* renderScreen() async {
        final prefs = await SharedPreferences.getInstance();
        if (prefs.containsKey("qr")) {
          print("SHARED IF");
          final extractedUserData =
              json.decode(prefs.getString("qr")) as Map<String, Object>;
          qrShared = extractedUserData["qrScanned"];
          idQrShared = extractedUserData["idScanned"];
          isQrScanned = "ProductsOverviewScreen";
        } else {
          print("SHARED ELSE");
          isQrScanned = "QrScreen";
        }
      }

      await renderScreen(); */

      // ** CHOOSE PAGE BASED ON QR SCANNED OR NOT & USER TYPE ** //

      await Provider.of<Auth>(context, listen: false).authenticateInit();

      renderNextScreen();

      // ** CHOOSE PAGE BASED ON QR SCANNED OR NOT & USER TYPE ** //
    });
  }

  renderNextScreen() {
    print(
        "SIGNUP: renderNextScreen: QR SCANNED VALUE IS : ${Provider.of<Auth>(context, listen: false).qrScanned}");
    print(
        "SIGNUP: renderNextScreen: QR SCANNED ID IS : ${Provider.of<Auth>(context, listen: false).qrScannedId}");
    var authPrint = Provider.of<Auth>(context, listen: false).isAuth;
    var userTypePrint = Provider.of<Auth>(context, listen: false).userType;
    if (Provider.of<Auth>(context, listen: false).isAuth &&
        Provider.of<Auth>(context, listen: false).userType != null) {
      if (Provider.of<Auth>(context, listen: false).userType.contains("user")) {
        String qrScannedValueShared =
            Provider.of<Auth>(context, listen: false).qrScanned;
        String qrScannedIdShared =
            Provider.of<Auth>(context, listen: false).qrScannedId;
        bool isQrExpired = Provider.of<Auth>(context, listen: false)
            .isExpiredTimeStampQrScanned;
        print(
            "SIGNUP: renderNextScreen: QR SCANNED VALUE IS : ${qrScannedValueShared}");
        print(
            "SIGNUP: renderNextScreen: QR SCANNED ID IS : ${qrScannedIdShared}");
        print(
            "SIGNUP: renderNextScreen: QR SCANNED BOOL IS : ${Provider.of<Auth>(context, listen: false).isQrScanned.toString()}");
        if (qrScannedValueShared != "none" && isQrExpired) {
          Navigator.pushReplacementNamed(
            context,
            ProductsOverviewScreen.routeName,
            arguments: {
              "qrScanned": qrScannedValueShared,
              "idQrScanned": qrScannedIdShared,
            },
          );
        } else {
          Navigator.pushReplacementNamed(
            context,
            QrScreen.routeName,
          );
        }
      } else if (Provider.of<Auth>(context, listen: false)
          .userType
          .contains("admin")) {
        Navigator.pushReplacementNamed(
          context,
          UserProductsScreen.routeName,
        );
      }
    } else {
      print("SIGNUP: renderNextScreen: isauth: " + authPrint.toString());
      print("SIGNUP: renderNextScreen: user type: " + userTypePrint.toString());
    }
  }

  _openPopup(context) {
    Alert(
        context: context,
        title: "Login",
        content: Column(
          children: <Widget>[
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                icon: Icon(
                  Icons.account_circle,
                  color: Color.fromRGBO(89, 40, 121, 0.9),
                ),
                labelText: 'Email',
              ),
            ),
            TextField(
              controller: passController,
              obscureText: true,
              decoration: InputDecoration(
                icon: Icon(Icons.lock, color: Color.fromRGBO(89, 40, 121, 0.9)),
                labelText: 'Password',
              ),
            ),
          ],
        ),
        buttons: [
          DialogButton(
            color: Color.fromRGBO(89, 40, 121, 1),
            radius: BorderRadius.circular(10),
            onPressed: () {
              // Email SignUp
              // Work with Username and Password on Login CLick
              print(
                  "Username: ${usernameController.text.trim()} Password: ${passController.text}");
              // Create a credential for Eail Rauthentication
              /* credential = EmailAuthProvider.credential(
                  email: usernameController.text,
                  password: passController.text); */
              // Execute Email SignUp
              Provider.of<Auth>(context, listen: false).emailSignup(
                  usernameController.text.trim(), passController.text);
              Navigator.of(context).pop();
            },
            child: Text(
              "Submit",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  Widget buildAuthScreen() {
    if (Provider.of<Auth>(context, listen: false).userType != null) {
      print(
          "SIGNUP SCREEN: USER ACC TYPE: ${Provider.of<Auth>(context, listen: false).userType}");
      // If QR was not scanned redirrect to QR scanning page, else to spinner until UI gets redirected
      if (Provider.of<Auth>(context, listen: false).qrScanned != "none") {
        if (Provider.of<Auth>(context, listen: false)
            .userType
            .contains("admin")) {
          return UserProductsScreen();
        } else {
          return QrScreen();
          //return ProductsOverviewScreen();
        }
      } else {
        if (Provider.of<Auth>(context, listen: false)
            .userType
            .contains("admin")) {
          return UserProductsScreen();
        } else if (Provider.of<Auth>(context, listen: false)
            .userType
            .contains("user")) {
          return QrScreen();
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      }
    } else {
      // User type is null => wait for it to load
      print("***SIGNUP SCREEN: USER ACC TYPE IS NULL !!!***");
      Provider.of<Auth>(context, listen: false).authenticateInit();
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: false,
      body: Container(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/login.png"),
              fit: BoxFit.cover,
            ),
          ),
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                //  SizedBox(height: 0),
                // SizedBox(height:200),
                Text(
                  'eKonobar',
                  style: TextStyle(
                    fontFamily: "Signatra",
                    fontSize: 90.0,
                    color: Color.fromRGBO(75, 26, 105, 1),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 5 + 10),
                //google login button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FlatButton(
                      minWidth: 270,
                      height: 55,
                      shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Colors.white,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(55.0)),
                      color: Colors.transparent,
                      textColor: Colors.white,
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            child: Container(
                              width: 36,
                              height: 36,
                              child:
                                  Image.asset('assets/images/google-logo.png'),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              "Google Login",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onPressed: () {
                        Provider.of<Auth>(context, listen: false).login();
                      },
                    ),
                  ],
                ),

                SizedBox(
                  height: 20,
                ),
                //eMail log in button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FlatButton(
                      minWidth: 270,
                      height: 55,
                      shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Colors.white,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(55.0)),
                      color: Colors.transparent,
                      textColor: Colors.white,
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            child: Container(
                              width: 35,
                              height: 35,
                              child: Image.asset(
                                'assets/images/email-logo.png',
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Text(
                              "Email Sign Up",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 19.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      onPressed: () {
                        _openPopup(context);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(
        "SIGNUP SCREEN isAuth BOOL VALUE ${Provider.of<Auth>(context, listen: false).isAuth}");
    return Provider.of<Auth>(context, listen: false).isAuth
        ? buildAuthScreen()
        : buildUnAuthScreen();
  }
}
