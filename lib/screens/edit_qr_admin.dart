import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttershare/widgets/app_drawer_admin.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';

import 'package:firebase_database/firebase_database.dart';

class EditQrAdmin extends StatefulWidget {
  static const routeName = "/edit-qr-admin";
  @override
  _EditQrAdminState createState() => _EditQrAdminState();
}

class _EditQrAdminState extends State<EditQrAdmin> {
  final userAccounts = FirebaseDatabase.instance.reference().child("accounts");

  Map<dynamic, dynamic> qrList = new Map();
  Map<dynamic, dynamic> qrListTemp = new Map();

  // need to dispose them manually when state gets cleared = leave screen to prevent mem leaks
  final _qrFocusNode = FocusNode();
  final _tableFocusNode = FocusNode();
  String qrCodeToSave = "none";
  String qrTableToSave = "none";
  String currUserId;
  var bottomSheetController;
  var authData;
  String editModeTable = "none";
  String editModeQr = "none";
  String qrCodeBase = "none";

  ScrollController _hideButtonController;
  int _counter = 0;
  var _isVisible;

  // this global key allows us to look inside Form widget and get our entered data
  final _form = GlobalKey<FormState>();

  var _isInit = true;
  var _isLoading = false;
  bool showFab = true;
  bool isEditGlobal = false;

  // KEYS HAVE NUMBER AND LETTERS (table1), values are a mix of anything (none1)
  Future<Map<dynamic, dynamic>> sortMap(Map<dynamic, dynamic> mapToSort) async {
    print("sortMap: UNSORTED MAP: ${mapToSort}");
    Map<dynamic, dynamic> qrListSorted = mapToSort;
    Map<dynamic, dynamic> qrListSortedFinal = new Map();
    int startLength = qrListSorted.length;
    String keyCurrent;
    String valueCurrent;
    String keyAfter;
    String valueAfter;
    String lowKey = qrListSorted.keys.elementAt(0);
    String lowValue = qrListSorted.values.elementAt(0);
    for (var i = 0; i < startLength - 1; i++) {
      // RESET THE LOWEST KEY TO THE FIRST ELEMENT
      lowKey = qrListSorted.keys.elementAt(0);
      lowValue = qrListSorted.values.elementAt(0);
      for (var j = 1; j < qrListSorted.length; j++) {
        try {
          // SET KEYS AND VALUES
          keyCurrent = qrListSorted.keys.elementAt(0);
          valueCurrent = qrListSorted.values.elementAt(0);
          keyAfter = qrListSorted.keys.elementAt(j);
          valueAfter = qrListSorted.values.elementAt(j);
          int keyCurrentInt =
              int.parse(keyCurrent.replaceAll(RegExp('[^0-9]'), ''));
          int keyAfterInt =
              int.parse(keyAfter.replaceAll(RegExp('[^0-9]'), ''));
          if (keyCurrentInt <= keyAfterInt) {
            // IF KEY AT POS 0 IS LESS THAN THE NEXT ONE, AND IT'S LESS THAN CURRENT LOWEST ONE, SET IT
            if (int.parse(lowKey.replaceAll(RegExp('[^0-9]'), '')) >=
                keyCurrentInt) {
              lowKey = keyCurrent;
              lowValue = valueCurrent;
            }
          } else {
            // IF THE NEXT KEY IS LESS THAN THE KEY AT POS 0, AND IT'S LESS THAN CURRENT LOWEST ONE, SET IT
            if (int.parse(lowKey.replaceAll(RegExp('[^0-9]'), '')) >=
                keyAfterInt) {
              lowKey = keyAfter;
              lowValue = valueAfter;
            }
          }
        } catch (err) {
          throw err;
        }
      }
      // REMOVE KEY FROM ITTERATING MAP AND PUSH IT TO NEWMAP AS THE NEW LOWEST NUMBER
      qrListSorted.remove(lowKey);
      qrListSortedFinal[lowKey] = lowValue;
    }
    // ADD THE REMAINING VALUE AND KEY
    qrListSortedFinal[qrListSorted.keys.elementAt(0)] =
        qrListSorted.values.elementAt(0);
    print("sortMap: SORTED MAP: ${qrListSortedFinal}");
    return qrListSortedFinal;
  }

  @override
  void initState() {
    super.initState();
    // GET QR VALUES
    setState(() {
      _isLoading = true;
    });
    Future.delayed(Duration.zero).then((_) async {
      /* await Provider.of<Auth>(context, listen: false)
          .pullAccountData(currUserId); */
      currUserId = Provider.of<Auth>(context, listen: false).userId;
      print("INITSTATE currUserId $currUserId");
      await userAccounts.once().then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> values = snapshot.value;
        if (snapshot.value != null && snapshot.value.toString().isNotEmpty) {
          values.forEach((key1, values1) async {
            if (values1["userId"] == (currUserId) &&
                values1["userQr"] != null) {
              values1["userQr"].forEach((key2, values2) async {
                // Save QRcodes and keys in a Map
                qrListTemp[key2] = values2;
                // Extract base string QRcode from QRvalues
                qrCodeBase = values2.replaceAll(RegExp('[^a-z]'), '');
              });
            }
          });
        }
      });

      if (qrListTemp != null && qrListTemp.isNotEmpty) {
        qrList = await sortMap(qrListTemp);
      }

      setState(() {
        print("EDIT QR MAP SORTED MAP FINAL AWAIT:  ${qrList}");
        _isLoading = false;
      });
    });
    /* setState(() {
      print("EDIT QR MAP SORTED MAP FINAL AWAIT:  ${qrList}");
      _isLoading = false;
    }); */

    // HANDLE FAB ON OFF ON SCROLL

    _isVisible = true;
    _hideButtonController = new ScrollController();
    _hideButtonController.addListener(() {
      if (_hideButtonController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_isVisible == true) {
          /* only set when the previous state is false
             * Less widget rebuilds 
             */
          print("**** ${_isVisible} up"); //Move IO away from setState
          setState(() {
            _isVisible = false;
          });
        }
      } else {
        if (_hideButtonController.position.userScrollDirection ==
            ScrollDirection.forward) {
          if (_isVisible == false) {
            /* only set when the previous state is false
               * Less widget rebuilds 
               */
            print("**** ${_isVisible} down"); //Move IO away from setState
            setState(() {
              _isVisible = true;
            });
          }
        }
      }
    });
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  // need to dispose FocusNodes manually like this
  @override
  void dispose() {
    _qrFocusNode.dispose();
    _tableFocusNode.dispose();
    super.dispose();
  }

// Check weather QR exists in DB, every QR must be different!!
  Future<bool> _qrExists(String qrToCheck, bool isBaseCheck) async {
    bool qrMatch = false;
    print("_qrExists_qrToCheck $qrToCheck");
    if (qrToCheck != null && qrToCheck.isNotEmpty) {
      try {
        await userAccounts.once().then((DataSnapshot snapshot) {
          Map<dynamic, dynamic> values = snapshot.value;
          if (snapshot.value != null && snapshot.value.toString().isNotEmpty) {
            values.forEach((key1, values1) async {
              if (values1["userId"] !=
                      Provider.of<Auth>(context, listen: false).userId &&
                  values1["userQr"] != null &&
                  values1["userQr"].toString().isNotEmpty) {
                values1["userQr"].forEach((key2, values2) async {
                  print("QRMAP_KEY: ${key2}");
                  print("QRMAP_VALUE: ${values2}");
                  if (isBaseCheck) {
                    if (values2.replaceAll(RegExp('[^a-z]'), '') ==
                        (qrToCheck.replaceAll(RegExp('[^a-z]'), ''))) {
                      // QR CODE BASE EXISTS IN DB
                      print("QR CODE BASE EXISTS IN DB");
                      qrMatch = true;
                    }
                  } else {
                    if (values2 == (qrToCheck)) {
                      // QR CODE EXISTS IN DB
                      print("QR CODE EXISTS IN DB");
                      qrMatch = true;
                    }
                  }
                });
              }
            });
          }
        });
      } catch (err) {
        throw err;
      }
    }
    return qrMatch;
  }

  Future<Map<dynamic, dynamic>> qrMapBaseFix(String base) async {
    Map<dynamic, dynamic> qrListFixed = new Map();
    qrListFixed = qrList;
    print("Values to fix base : $base");
    qrListFixed.forEach((key1, values1) async {
      try {
        if (values1.replaceAll(RegExp('[^a-z]'), '') != base) {
          print("ISNUMERIC IF");
          qrListFixed[key1] =
              "$base${int.parse(values1.replaceAll(RegExp('[^0-9]'), '')) ?? "0"}";
        } else {
          print("ISNUMERIC ELSE");
          qrListFixed[key1] = values1;
        }
        print("Values to fix qrcode : $values1");
        print("Values to fix key : $key1");
      } catch (err) {
        print("qrMapBaseFix error: $err");
      }
    });
    return qrListFixed;
  }

  // SAVE NEW QR TO DB
  Future<void> _saveNewQr(
      String userId, String newQr, String newQrTable) async {
    //authData = Provider.of<Auth>(context, listen: false);
    setState(() {
      _isLoading = true;
    });
    bool qrExists = false;
    String qrValueToSave;
    print("isEditGlobal : $isEditGlobal");

    // If not in edit mode check for QRcode existance
    if (!isEditGlobal) {
      print("newQrnewQr : $newQr");

      // Form QRcode : base qr + table number
      qrValueToSave =
          "$newQr${int.parse(newQrTable.replaceAll(RegExp('[^0-9]'), '')) ?? "0"}";
      print("newQqrValueToSave : $qrValueToSave");

      // Fix QRcode Map if our base codes differ from the one provided
      qrExists = await _qrExists(qrValueToSave, true);
      if (!qrExists) {
        qrList = await qrMapBaseFix(newQr);
        print("FIXED MAP : $qrList");
        qrCodeBase = newQr;
      }
    }

    print("_qrExists : ${qrExists}");
    if (!qrExists) {
      try {
        if (isEditGlobal) {
          print("REMOVING TABLE FROM DB");
          qrList.remove(newQrTable);
        } else {
          print("ADDING NEW TABLE TO DB");
          qrList[newQrTable] =
              qrValueToSave; // add new qr entry to existing list
        }
        await userAccounts.once().then((DataSnapshot snapshot) {
          if (userId != null) {
            print("EDIT QR ADMIN: userId : ${userId}");
            Map<dynamic, dynamic> values = snapshot.value;
            if (snapshot.value != null && values.containsKey(userId)) {
              userAccounts.child(userId).update({
                "userQr": qrList,
              });
            }
          }
        });
      } catch (err) {
        throw err;
      }
      if (qrList != null && qrList.isNotEmpty) {
        qrList = await sortMap(
            qrList); // sort our new qr Map with newly added QRcode
      }

      Navigator.of(context).pop();
      setState(() {
        _isLoading = false;
      });
      String message;
      if (isEditGlobal)
        message =
            "Table table ${int.parse(newQrTable.replaceAll(RegExp('[^0-9]'), '')) ?? "0"} was succesfully removed!";
      else
        message = "QRcode $newQr saved!";
      Flushbar(
        backgroundColor: Colors.deepPurple.shade300,
        title: "QRcode success",
        message: message,
        duration: Duration(seconds: 4),
      )..show(context);
    } else {
      print("EDIT QR ADMIN: QR already exists");
      Navigator.of(context).pop();
      setState(() {
        _isLoading = false;
      });
      Flushbar(
        backgroundColor: Colors.deepPurple.shade300,
        title: "QRcode error",
        message: "QRcode already exists, try another one!",
        duration: Duration(seconds: 4),
      )..show(context);
    }
  }

  void showFoatingActionButton(bool value) {
    setState(() {
      showFab = value;
    });
  }

  _modalBottomSheet(bool isEdit, BuildContext ctx) {
    isEditGlobal = isEdit;
    print("EDIT MODE: TABLE: ${editModeTable}");
    print("EDIT MODE: QR: ${editModeQr}");
    bottomSheetController = showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        context: context,
        isScrollControlled: true,
        builder: (ctx) => Padding(
              /* padding: const EdgeInsets.symmetric(horizontal: 12.0), */
              padding: MediaQuery.of(context).viewInsets,
              child: Form(
                key: _form,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(padding: EdgeInsets.all(20)),
                      isEdit
                          ? Column(
                              children: <Widget>[
                                Center(
                                  child: Text(
                                    "Confirm table ${int.parse(editModeTable.replaceAll(RegExp('[^0-9]'), '')) ?? "0"} deletition",
                                    style: TextStyle(
                                      height: 1,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                  // Theme.of(context).textTheme.headline6,
                                ),

                                /* Text(
                                  "for table $editModeTable",
                                  style: Theme.of(context).textTheme.subtitle1,
                                ), */
                              ],
                            )
                          : Column(
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Set new QRcode',
                                    // textAlign: TextAlign.left,
                                    style: TextStyle(
                                      height: 1,
                                      fontSize: 25.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple[800],
                                    ),
                                  ),
                                ),
                                Padding(padding: EdgeInsets.all(10)),
                                TextFormField(
                                  /* initialValue: "11", */
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.green,
                                      ),
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    labelText: "Table number",
                                  ),
                                  // on submit to go to next form input if any, FocusNode has also to be defined, new one for each field, and FocusScope
                                  textInputAction: TextInputAction.next,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  keyboardType: TextInputType.number,
                                  focusNode: _tableFocusNode,
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context)
                                        .requestFocus(_qrFocusNode);
                                  },
                                  // Validate our form, need to call _form.currentState.validate() to trigger all validators before saving form
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return "Please provide a value";
                                    }
                                    // return null; means we don't have an error
                                    return null;
                                  },
                                  // Saving our entered value
                                  onSaved: (value) {
                                    qrTableToSave = value;
                                  },
                                ),
                                Padding(padding: EdgeInsets.all(10)),
                                TextFormField(
                                  initialValue: qrCodeBase,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.deepPurple[800],
                                      ),
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    labelText: "QR code",
                                  ),
                                  // on submit to go to next form input if any, FocusNode has also to be defined, new one for each field, and FocusScope
                                  inputFormatters: [
                                    // allow only letters ans space
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r"[a-zA-Z]+|\s")),
                                  ],
                                  textInputAction: TextInputAction.next,
                                  focusNode: _qrFocusNode,
                                  /* onFieldSubmitted: (_) {
                                FocusScope.of(context).requestFocus(_qrFocusNode);
                              }, */
                                  // Validate our form, need to call _form.currentState.validate() to trigger all validators before saving form
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return "Please provide a value";
                                    }
                                    // return null; means we don't have an error
                                    return null;
                                  },
                                  // Saving our entered value
                                  onSaved: (value) {
                                    qrCodeToSave = value;
                                  },
                                ),
                              ],
                            ),
                      Padding(padding: EdgeInsets.all(10)),
                      Center(
                        child: _isLoading
                            ? CircularProgressIndicator()
                            : Container(
                                width: 180,
                                margin: EdgeInsets.all(10),
                                child: FlatButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(
                                          color: Colors.purple[900])),
                                  color: Colors.purple[900],
                                  textColor: Colors.white,
                                  padding: EdgeInsets.all(12.0),
                                  onPressed: () {
                                    final isValid =
                                        _form.currentState.validate();
                                    if (!isValid) {
                                      return;
                                    }
                                    _form.currentState.save();
                                    if (isEdit)
                                      qrTableToSave = editModeTable;
                                    else
                                      qrTableToSave = "table$qrTableToSave";
                                    print(
                                        "TEXT _qrFocusNode SAVED: ${qrTableToSave}");
                                    print(
                                        "TEXT _qrFocusNode SAVED: ${qrCodeToSave}");
                                    if (qrTableToSave != null &&
                                        qrCodeToSave != null) {
                                      // SAVE NEW QR TO DB IF IT DOESN'T ALREADY EXIST
                                      _saveNewQr(authData.userId, qrCodeToSave,
                                          qrTableToSave);
                                    } else {
                                      print(
                                          "EDIT QR ADMIN: QR NOT SAVED: INPUT EMPTY");
                                    }
                                  },
                                  child: Text(
                                    isEdit
                                        ? "Confirm".toUpperCase()
                                        : "Save".toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      Padding(padding: EdgeInsets.all(20)),
                    ],
                  ),
                ),
              ),
            ));
    showFoatingActionButton(false);
    bottomSheetController.whenComplete(() {
      showFoatingActionButton(true);
      isEdit = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    authData = Provider.of<Auth>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Edit QR"),
        actions: <Widget>[
          /* IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ), */
        ],
      ),
      drawer: AppDrawerAdmin(),
      floatingActionButton: new Visibility(
        visible: _isVisible,
        child: FloatingActionButton.extended(
          onPressed: () {
            _modalBottomSheet(false, context);
          },
          label: Text('Add QRcode'),
          icon: Icon(Icons.qr_code_rounded),
          backgroundColor: Colors.deepPurple[400],
        ),
      ),
      // ** Progress Just set _isLoading in SetState and choose one widget or the other. Te other shows up after you reset _isLoading
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              controller: _hideButtonController,
              itemBuilder: (ctx, index) {
                var key = qrList.keys.elementAt(index);
                var key1 = qrList.keys.toList();
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      side: BorderSide(width: 1.5, color: Colors.deepPurple)),
                  //color: Colors.deepPurple[50],
                  color: Color.fromRGBO(247, 243, 253, 1),
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                  elevation: 5,
                  child: ListTile(
                    // EXtract Table number
                    leading: CircleAvatar(
                      radius: 30,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: FittedBox(
                          child: Text(
                              "${int.parse(key1[index].replaceAll(RegExp('[^0-9]'), '')) ?? "0"}"),
                        ),
                      ),
                    ),
                    title: Container(
                      margin: const EdgeInsets.only(
                          left: 1.0, right: 1.0, top: 20.0, bottom: 20.0),
                      child: Row(
                        /* mainAxisAlignment: MainAxisAlignment.spaceEvenly, */
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code,
                            color: Colors.deepPurple[900],
                          ),
                          SizedBox(
                            width: 2.0,
                          ),
                          Flexible(
                            child: Text(
                              "${qrList[key]}",
                              style: new TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    /* subtitle: Text(
                        "THREE",
                      ), */
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      color: Theme.of(context).errorColor,
                      onPressed: () {
                        editModeTable = key1[index];
                        editModeQr = qrList[key];
                        _modalBottomSheet(true, context);
                      },
                    ),
                  ),
                );
              },
              itemCount: qrList.length,
            ),
    );
  }
}
