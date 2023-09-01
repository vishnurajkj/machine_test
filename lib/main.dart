import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product List',
      home: ProductListScreen(),
    );
  }
}

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  // Initialize Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void addProduct() async {
    // Get the values from the text fields
    String name = nameController.text;
    double price = double.parse(priceController.text);
    int quantity = int.parse(quantityController.text);

    // Add the product to Firebase
    await _firestore.collection('products').add({
      'name': name,
      'price': price,
      'quantity': quantity,
    });

    // Clear the text fields
    nameController.clear();
    priceController.clear();
    quantityController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product List'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Product Name'),
                TextField(controller: nameController),
                Text('Product Price'),
                TextField(controller: priceController),
                Text('Product Quantity'),
                TextField(controller: quantityController),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: addProduct,
            child: Text('Add'),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                final products = snapshot.data?.docs;
                List<Widget> productWidgets = [];
                for (var product in products!) {
                  final productName = product['name'];
                  final productPrice = product['price'];
                  final productQuantity = product['quantity'];

                  productWidgets.add(
                    ListTile(
                      title: Text('$productName - \$${productPrice.toStringAsFixed(2)}'),
                      subtitle: Text('Quantity: $productQuantity'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          // Delete the product from Firebase
                          _firestore.collection('products').doc(product.id).delete();
                        },
                      ),
                    ),
                  );
                }
                return ListView(
                  children: productWidgets,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

