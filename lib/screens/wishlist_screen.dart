import 'package:e_commerce_app/screens/product_detail.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../components/header.dart';
import '../components/sidebar.dart';
import '../services/product_service.dart';
import '../services/user_service.dart';

class WishListScreen extends StatefulWidget {
  const WishListScreen({super.key});

  @override
  State<WishListScreen> createState() {
    return _WishListScreenState();
  }
}

class _WishListScreenState extends State<WishListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ProductService _productService = ProductService();
  final GlobalKey<State> _keyLoader = GlobalKey<State>();
  final UserService _userService = UserService();
  bool showCartIcon = true;
  List userList = [];

  setWishlistItems(){
    Map<String, dynamic> args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    setState(() {
      userList = args['userList'];
    });
  }

  delete(int index) {
    String productId = userList[index]['productId'];
    _userService.deleteUserWishlistItems(productId);
    setState(() {
      userList.removeAt(index);
      UserService.showSnackBarMessage(context, context.tr('strWishlistRemove'));
    });
  }

  void showParticularItem(String productId) async {
    Map<String, String> itemDetails =
    await _productService.particularItem(productId);
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (ctx) => ProductDetail(
            itemDetails: itemDetails,
            editProduct: false,
          )),
    );
  }

  emptyWishlist() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(context.tr('strWishlistTitle'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 25.0,
            ),
          ),
          const SizedBox(height: 10.0),
          Text(context.tr('strWishlistText'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 25.0,
            ),
          ),
          const SizedBox(height: 10.0),
          const Icon(Icons.shopping_bag_outlined, size: 150,),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () async {
              Navigator.pushReplacementNamed(context, '/home');
            },
            child: Text(context.tr('strHome'),
              style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    setWishlistItems();
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context.tr('strWishlistProfile'), _scaffoldKey, showCartIcon, context),
      drawer: sidebar(context),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: userList.isNotEmpty
            ? ListView.separated(
                itemCount: userList.length,
                itemBuilder: (BuildContext context, int index) {
                  var item = userList[index];
                  return GestureDetector(onTap:(){
                    showParticularItem(item['productId']);
                  },child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 4,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            item['image'],
                            fit: BoxFit.cover,
                            height: 120.0,
                            width: 140.0,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                            const EdgeInsets.only(top: 10.0, left: 10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(item['productName'],
                                    style: const TextStyle(
                                        fontSize: 19.0,
                                        letterSpacing: 1.0,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 5.0),
                                Text(
                                  "\$ ${item['price']}.00",
                                  style: const TextStyle(fontSize: 17.0),
                                )
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 40, color: Colors.redAccent,),
                          onPressed: () {
                            delete(index);
                          },
                        )
                      ],
                    ),
                  ),);
                },
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(height: 10.0),
              )
            : emptyWishlist(),
      ),
    );
  }
}
