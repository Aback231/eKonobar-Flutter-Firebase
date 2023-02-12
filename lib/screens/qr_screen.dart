import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/app_drawer.dart';

//import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flushbar/flushbar.dart';

import '../screens/products_overview_screen.dart';

import '../providers/auth.dart';

import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';

import 'package:timeago/timeago.dart' as timeago;

//final userAccounts = FirebaseFirestore.instance.collection('accounts');
final userAccounts = FirebaseDatabase.instance.reference().child("accounts");

/* addStringToSF(String stringKey, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(stringKey, value);
} */

var qrValue = "";

class QrScreen extends StatefulWidget {
  static const routeName = "/qr";

  @override
  _QrScreenState createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  var _isLoading = false;
  String _scanBarcode = 'Unknown';

  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.QR);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      print("barcodeScanRes : ${barcodeScanRes}");
      _scanBarcode = barcodeScanRes;
    });
  }

  void qrScan(BuildContext ctx) async {
    String snackTitle;
    String snackMessage;
    //final authData = Provider.of<Auth>(ctx, listen: false);
    //var qrResult = await BarcodeScanner.scan();
    await scanQR();

    print("barcodeScanRes : qrScan : ${_scanBarcode}");

    //if (qrResult.type.toString() == "Barcode") {
    if (_scanBarcode.toString() != "Unknown" &&
        _scanBarcode.toString() != "-1") {
      qrValue = _scanBarcode;
      // Go to Restaurant by QR
      //Navigator.of(ctx).pushNamed(ProductsOverviewScreen.routeName);

      try {
// ** NEW QR LOGIC FOR QR CODE MAP ** //
        var qrMatch = false;
        userAccounts.once().then((DataSnapshot snapshot) {
          Map<dynamic, dynamic> values = snapshot.value;
          values.forEach((key1, values1) async {
            //if (key1.toString().contains("stU7K2t7i6dSPSG9OBbA8H0iZcM2")) {
            values1["userQr"].forEach((key2, values2) async {
              print("VALUES LENGTH: values1: ${values.length}");
              print("VALUES LENGTH: values2: ${values1.length}");
              print("QRMAP_KEY: ${key2}");
              print("QRMAP_VALUE: ${values2}");
              if (values2 == (qrValue)) {
                // QR CODE EXISTS IN DB
                qrMatch = true;
                snackTitle = "QR Scan success!";
                snackMessage = "QR code " + qrValue;
                print(values1["userId"]);
                print(values2);

                // Update QR scanned and QR scanned ID in DB
                await userAccounts.once().then((DataSnapshot snapshot) async {
                  Map<dynamic, dynamic> valuesNew = snapshot.value;
                  String currUserId =
                      Provider.of<Auth>(context, listen: false).userId;
                  if (valuesNew.containsKey(currUserId)) {
                    final timestamp = DateTime.now();
                    await userAccounts.child(currUserId).update({
                      "qrScanned": qrValue,
                      "qrScannedId": values1["userId"],
                      "qrScannedTable": key2,
                      "timeStampQrScanned": timestamp.toIso8601String()
                    });
                    await Provider.of<Auth>(context, listen: false)
                        .pullAccountData(currUserId);
                    Navigator.pushNamed(
                      ctx,
                      ProductsOverviewScreen.routeName,
                      arguments: {
                        "qrScanned": qrValue.toString(),
                        "idQrScanned": values1["userId"].toString(),
                        "qrScannedTable": key2,
                        "timeStampQrScanned": timestamp.toIso8601String()
                      },
                    );
                    Flushbar(
                      backgroundColor: Colors.deepPurple.shade300,
                      title: snackTitle,
                      message: snackMessage,
                      duration: Duration(seconds: 4),
                    )..show(ctx);
                    return;
                  }
                });
              }
              /* else {
                // QR DOESN'T EXIST IN DB
                snackTitle = "QR Scan error!";
                snackMessage =
                    "QR code " + qrValue + " doesn't exist in database!";
                Flushbar(
                  title: snackTitle,
                  message: snackMessage,
                  duration: Duration(seconds: 4),
                )..show(ctx);
              } */
            });
            //}
// ** NEW QR LOGIC FOR QR CODE MAP ** //

// ** OLD QR LOGIC FOR ONE QR CODE ONLY ** //

            /* if (values1["userQr"].toString().contains(qrValue)) {
            // QR CODE EXISTS IN DB
            snackTitle = "QR Scan success!";
            snackMessage = "QR code " + qrValue;
            print(values1["userId"]);
            print(values1["userQr"]);

            // Update QR scanned and QR scanned ID in DB
            userAccounts.once().then((DataSnapshot snapshot) {
              Map<dynamic, dynamic> valuesNew = snapshot.value;
              String currUserId =
                  Provider.of<Auth>(context, listen: false).userId;
              if (valuesNew.containsKey(currUserId)) {
                userAccounts.child(currUserId).update(
                    {"qrScanned": qrValue, "qrScannedId": values1["userId"]});
              }
            });

            Navigator.pushNamed(
              ctx,
              ProductsOverviewScreen.routeName,
              arguments: {
                "qrScanned": qrValue.toString(),
                "idQrScanned": values1["userId"].toString(),
              },
            );

            Flushbar(
              title: snackTitle,
              message: snackMessage,
              duration: Duration(seconds: 4),
            )..show(ctx);
          } else {
            // QR DOESN'T EXIST IN DB
            snackTitle = "QR Scan error!";
            snackMessage = "QR code " + qrValue + " doesn't exist in database!";
            Flushbar(
              title: snackTitle,
              message: snackMessage,
              duration: Duration(seconds: 4),
            )..show(ctx);
          } */

// ** OLD QR LOGIC FOR ONE QR CODE ONLY ** //
          });
          if (!qrMatch) {
            // QR DOESN'T EXIST IN DB
            snackTitle = "QR Scan error!";
            snackMessage = "QR code " + qrValue + " doesn't exist in database!";
            Flushbar(
              backgroundColor: Colors.deepPurple.shade300,
              title: snackTitle,
              message: snackMessage,
              duration: Duration(seconds: 4),
            )..show(ctx);
          }
        });
      } catch (error) {
        print("QR SCREEN: QR DB HANDLE ERROR: ${error}");
        throw (error);
      }

      /* accData.fetchUsersTable().then((_) {
        Navigator.pushNamed(
      ctx,
      ProductsOverviewScreen.routeName,
      arguments: qrValue,
      );
      }); */
      /* Navigator.pushNamed(
      ctx,
      ProductsOverviewScreen.routeName,
      arguments: qrValue,
    ); */

      /* userAccounts.get().then((QuerySnapshot snapshot) => {
      snapshot.docs.forEach((DocumentSnapshot doc) {
        print("*** USER ACCOUNTS PRINT ***");
        print(doc.data());
        print("*** USER ACCOUNTS PRINT ***");
      })
    }); */

    } else {
      if (_scanBarcode.toString() == "-1") {
        snackTitle = "QR Scan canceled!";
        snackMessage = " ";
        Flushbar(
          backgroundColor: Colors.deepPurple.shade300,
          title: snackTitle,
          message: snackMessage,
          duration: Duration(seconds: 4),
        )..show(ctx);
      }
    }
    /* print(qrResult.type); // The result type (barcode, cancelled, failed)
    print(qrResult.rawContent); // The barcode content
    print(qrResult.format); // The barcode format (as enum)
    print(qrResult
        .formatNote);  */ // If a unknown format was scanned this field contains a note
    print("QR_RESULTS_END");
    // Sow Snack Bar with QR Scan Result
  }

  @override
  void initState() {
    //Future.delayed(Duration.zero).then((_) async {
    setState(() {
      _isLoading = true;
    });
    //await Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
    getUsers();
    setState(() {
      _isLoading = false;
    });
    //});
    super.initState();
  }

  getUsers() async {
    userAccounts.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, values) {
        //print(values["userEmail"]);
        //print(values);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("QR Scan"),
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              alignment: Alignment.center,
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  image: new AssetImage('assets/images/qrcode.png'),
                  fit: BoxFit.fitWidth,
                ),
              ),
              child: Stack(children: <Widget>[
                Positioned(
                  child: RawMaterialButton(
                    onPressed: () {
                      qrScan(context);
                    },
                    child: Container(
                        decoration: new BoxDecoration(
                            image: new DecorationImage(
                      image: new AssetImage("images/assets/qrcode.png"),
                      fit: BoxFit.fill,
                    ))),
                  ),
                ),
              ]),
            ),
    );
  }
}
