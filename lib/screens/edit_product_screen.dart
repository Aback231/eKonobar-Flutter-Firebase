import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';
import '../models/category_options.dart';

import '../providers/auth.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = "/edit-product";

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  // need to dispose them manually when state gets cleared = leave screen to prevent mem leaks
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();

  final _imageUrlController = TextEditingController();

  // this global key allows us to look inside Form widget and get our entered data
  final _form = GlobalKey<FormState>();

  List<ListCategory> _dropdownItems = [
    ListCategory("Non-alcoholic drink"),
    ListCategory("Alcoholic drink"),
    ListCategory("Food"),
    ListCategory("Cakes"),
  ];

  List<DropdownMenuItem<ListCategory>> _dropdownMenuItems;
  ListCategory _selectedItem;

  var _editedProduct = Product(
    id: null,
    title: "",
    price: 0,
    description: "",
    imageUrl: "",
    restaurantOwnerId: "",
    category: "",
  );

  var _initValues = {
    "title": "",
    "description": "",
    "price": "",
    "imageUrl": "",
    "restaurantOwnerId": "",
    "category": "",
  };

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _imageUrlFocusNode.addListener(_updateImageUrl);
    _dropdownMenuItems = buildDropDownMenuItems(_dropdownItems);
    _selectedItem = _dropdownMenuItems[0].value;
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

  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          "title": _editedProduct.title,
          "description": _editedProduct.description,
          "price": _editedProduct.price.toString(),
          "imageUrl": "",
          "restaurantOwnerId": "",
          "category": _editedProduct.category,
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  // need to dispose FocusNodes manually like this
  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  // Saving our form for every TextField
  Future<void> _saveForm() async {
    // trigger all validators
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    } else {
      try {
        // ** Pop page only after Future is returned, and new prodact is saved to Firebase
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("An error occurred!"),
            //content: Text(error.toString()),
            content: Text("Something went wrong"),
            actions: <Widget>[
              FlatButton(
                child: Text("OK"),
                onPressed: () {
                  // POP the dialog
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        );
      }
      /* finally {
        setState(() {
          _isLoading = false;
        });
        // POP the Page
        Navigator.of(context).pop();
      } */
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  // Find string position inside dropdown menu and set update position
  setDropdownValue(String compare) {
    //print("_editedProduct.category : ${_editedProduct.category}");
    int br = 0;
    _dropdownItems.forEach((element) {
      if (compare == element.value) {
        //print("listIndex & br: ${element.value}  $br");
        _selectedItem = _dropdownMenuItems[br].value;
      }
      br += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authData = Provider.of<Auth>(context, listen: false);
    setDropdownValue(
        _editedProduct.category); // set dropdown to product beeing edited
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Edit Product"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      // ** Progress Just set _isLoading in SetState and choose one widget or the other. Te other shows up after you reset _isLoading
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.all(15),
              child: Form(
                key: _form,
                child: ListView(
                  children: <Widget>[
                    // Dropdown List to pick item
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(
                            top: 14,
                            right: 15,
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Text(
                              "Pick item category",
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                          ),
                        ),
                        DropdownButton<ListCategory>(
                            value: _selectedItem,
                            items: _dropdownMenuItems,
                            onChanged: (value) {
                              setState(() {
                                _selectedItem = value;
                                _editedProduct = Product(
                                  title: _editedProduct.title,
                                  price: _editedProduct.price,
                                  description: _editedProduct.description,
                                  imageUrl: _editedProduct.imageUrl,
                                  id: _editedProduct.id,
                                  isFavorite: _editedProduct.isFavorite,
                                  restaurantOwnerId: authData.ownerEmail,
                                  category: _selectedItem.value.toString(),
                                );
                              });
                            }),
                      ],
                    ),

                    /* DropdownButton<ListCategory>(
                      hint: Text("Pick item category"),
                      value: _selectedItem,
                      items: _dropdownMenuItems,
                      onChanged: (value) {
                        setState(() {
                          _selectedItem = value;
                          _editedProduct = Product(
                            title: _editedProduct.title,
                            price: _editedProduct.price,
                            description: _editedProduct.description,
                            imageUrl: _editedProduct.imageUrl,
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite,
                            restaurantOwnerId: authData.ownerEmail,
                            category: _selectedItem.value.toString(),
                          );
                       });
                    }), */
                    SizedBox(height: 15),
                    TextFormField(
                      initialValue: _initValues["title"],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.green,
                          ),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        labelText: "Title",
                      ),
                      // on submit to go to next form input if any, FocusNode has also to be defined, new one for each field, and FocusScope
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
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
                        _editedProduct = Product(
                          title: value,
                          price: _editedProduct.price,
                          description: _editedProduct.description,
                          imageUrl: _editedProduct.imageUrl,
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                          restaurantOwnerId: authData.ownerEmail,
                          //category: _editedProduct.category,
                          category: _selectedItem.value.toString(),
                        );
                      },
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      initialValue: _initValues["price"],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.green,
                          ),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        labelText: "Price",
                      ),
                      // on submit to go to next form input if any, FocusNode has also to be defined, new one for each field, and FocusScope
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please enter a price";
                        }
                        if (double.tryParse(value) == null) {
                          return "Please enter a valid number";
                        }
                        if (double.parse(value) <= 0) {
                          return "Please enter a number greater than 0";
                        }
                        return null;
                      },
                      // Saving our entered value
                      onSaved: (value) {
                        _editedProduct = Product(
                          title: _editedProduct.title,
                          price: double.parse(value),
                          description: _editedProduct.description,
                          imageUrl: _editedProduct.imageUrl,
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                          restaurantOwnerId: authData.ownerEmail,
                          //category: _editedProduct.category,
                          category: _selectedItem.value.toString(),
                        );
                      },
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      initialValue: _initValues["description"],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.green,
                          ),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        labelText: "Description",
                      ),
                      // Multi Line input
                      maxLines: 3,
                      // Multi Line input
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please enter description";
                        }
                        return null;
                      },
                      // Saving our entered value
                      onSaved: (value) {
                        _editedProduct = Product(
                          title: _editedProduct.title,
                          price: _editedProduct.price,
                          description: value,
                          imageUrl: _editedProduct.imageUrl,
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                          restaurantOwnerId: authData.ownerEmail,
                          //category: _editedProduct.category,
                          category: _selectedItem.value.toString(),
                        );
                      },
                    ),
                    SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(
                            top: 8,
                            right: 10,
                          ),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              color: Colors.deepPurple[100],
                              border: Border.all(
                                  width: 2, color: Colors.deepPurple)),
                          child: _imageUrlController.text.isEmpty
                              ? Center(
                                  child: Text(
                                    "Enter a URL",
                                    style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.deepPurple),
                                  ),
                                )
                              : FittedBox(
                                  child: Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            //initialValue: _initValues["imageUrl"], // doesn't work if you have a controller. Must use one or the other
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.green,
                                ),
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              labelText: "Image URL",
                            ),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            // Iplementing controller because we want image preview,
                            // so we need the image URL before all the data is submited
                            controller: _imageUrlController,
                            // to update image whenever we lose focus
                            focusNode: _imageUrlFocusNode,
                            // on enter submit all data
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Please enter image URL";
                              }
                              /* if(!value.endsWith(".png") || !value.endsWith(".jpg") || !value.endsWith(".jpeg")){
                        return "Please enter valid image URL";
                      } */
                              return null;
                            },
                            // Saving our entered value
                            onSaved: (value) {
                              _editedProduct = Product(
                                title: _editedProduct.title,
                                price: _editedProduct.price,
                                description: _editedProduct.description,
                                imageUrl: value,
                                id: _editedProduct.id,
                                isFavorite: _editedProduct.isFavorite,
                                restaurantOwnerId: authData.ownerEmail,
                                //category: _editedProduct.category,
                                category: _selectedItem.value.toString(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(),
                    Container(
                      height: 220,
                      decoration: new BoxDecoration(
                        image: new DecorationImage(
                          image: new AssetImage('assets/images/pozadina.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
