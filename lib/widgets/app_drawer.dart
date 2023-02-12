import '../screens/qr_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';

import '../screens/orders_screen.dart';
import '../screens/sign_up_method_screen.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Email Sign In
final FirebaseAuth auth = FirebaseAuth.instance;
UserCredential userCredential;
EmailAuthCredential credential;
bool emailStateChange = false;

// Google Sign In
final GoogleSignIn googleSignIn = GoogleSignIn();

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        child:SingleChildScrollView(
           child: Column(
          children: <Widget>[
            AppBar(
              title: Text(Provider.of<Auth>(context, listen: false).ownerEmail),
              // to not add back button
              automaticallyImplyLeading: false,
            ),
            Container(
              height: MediaQuery.of(context).size.height/5 ,
            
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  image: new AssetImage('assets/images/draver.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Divider(),
                ListTile(
                  leading: Icon(
                    Icons.shop,
                    color: Colors.deepPurple[900],
                    size: 30,
                  ),
                  title: Text(
                    "Shop",
                    style: TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    /* Provider.of<Auth>(context, listen: false).isQrScanned
                        ? Navigator.pushReplacementNamed(
                            context,
                            ProductsOverviewScreen.routeName,
                            arguments: {
                              "qrScanned":
                                  Provider.of<Auth>(context, listen: false)
                                      .qrScanned,
                              "idQrScanned":
                                  Provider.of<Auth>(context, listen: false)
                                      .qrScannedId,
                            },
                          )
                        : Navigator.of(context)
                            .pushReplacementNamed(QrScreen.routeName); */
                    //Navigator.of(context).pushReplacementNamed("/");
                    Navigator.of(context).pushNamed(SignUpMethod.routeName);
                  },
                ),
              ],
            ),
            /* Provider.of<Auth>(context, listen: false).isAdmin
                ? SizedBox()
                : */
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Divider(),
                ListTile(
                  leading: Icon(
                    Icons.payment,
                    color: Colors.deepPurple[900],
                    size: 30,
                  ),
                  title: Text(
                    "Orders",
                    style: TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.of(context)
                        .pushReplacementNamed(OrdersScreen.routeName);
                  },
                ),
              ],
            ),
            SizedBox(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Divider(),
                ListTile(
                  leading: Icon(Icons.qr_code_scanner,
                      color: Colors.deepPurple[900], size: 30),
                  title: Text(
                    "QR Scan",
                    style: TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.of(context)
                        .pushReplacementNamed(QrScreen.routeName);
                  },
                ),
              ],
            ),
           
            Column(
               mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Divider(),
                ListTile(
                  leading: Icon(
                    Icons.exit_to_app,
                    color: Colors.deepPurple[900],
                    size: 30,
                  ),
                  title: Text(
                    "Logout",
                    style: TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    // ** "/" to ensure we always end up on Auth Screen after Log Out
                    Navigator.of(context).pushReplacementNamed("/");
                    Provider.of<Auth>(context, listen: false).logout();

                    /* auth.signOut();
                    googleSignIn.signOut();
                    /* setState(() {
                        print("SET STATE logout to false");
                        isAuth = false;
                      }); */
                    if (auth.currentUser == null ||
                        googleSignIn.currentUser == null) {
                      print("LOGOUT SUCCESS");
                      Navigator.of(context)
                          .pushReplacementNamed(SignUpMethod.routeName);
                    } */
                  },
                ),
              ],
            ),
          ],
        ),
        ),
       
      ),
    );
  }
}
