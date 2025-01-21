import 'package:e_commerce_app/services/shopping_cart_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../components/header.dart';
import '../components/loader.dart';
import '../components/sidebar.dart';
import '../core/size_config.dart';

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ShoppingCartScreenState();
  }
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  List<dynamic> bagItemList = [];
  String totalPrice = "0";
  final ShoppingCartService _shoppingBagService = ShoppingCartService();
  final GlobalKey<State> _keyLoader = GlobalKey<State>();
  late String route;

  void listBagItems(context) async {
    Map<String, dynamic> args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    setState(() {
      bagItemList = args['bagItems'];
      totalPrice = setTotalPrice(args['bagItems']);
      if (args.containsKey('route')) {
        route = args['route'];
      }
    });
  }

  String setTotalPrice(List items) {
    int totalPrice = 0;
    for (var item in items) {
      print(item);
      print(item['quantity'].runtimeType);
      print(item['price'].runtimeType);
      int quantity = item['quantity'];
      String price = item['price'];
      totalPrice = totalPrice + int.parse(price) * quantity;
    }
    return totalPrice.toString();
  }

  void setProductQuantity(String type, item) async {
    int quantity = item['quantity'];
    if (type == 'inc') {
      if (quantity < 10) {
        quantity++;
        Loader.showLoadingScreen(context, _keyLoader);
        await _shoppingBagService.add(item['productId'], "-", "-", quantity);
        Loader.hideLoadingScreen(_keyLoader);
        setState(() {
          item['quantity'] = quantity;
        });
      }
    } else {
      if (quantity > 1) {
        quantity--;
        Loader.showLoadingScreen(context, _keyLoader);
        await _shoppingBagService.add(item['productId'], "-", "-", quantity);
        Loader.hideLoadingScreen(_keyLoader);
        setState(() {
          item['quantity'] = quantity;
        });
      }
    }
  }

  void removeItem(item, context) async {
    bagItemList.removeWhere((items) => items['productId'] == item['productId']);

    await _shoppingBagService.remove(item['productId']);
    setState(() {
      bagItemList = bagItemList;
    });
    Navigator.of(context, rootNavigator: true).pop();
  }

  void removeItemAlertBox(BuildContext context, Map id) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.0)),
            title: const Text('Remove from cart'),
            content: const Text('This product will be removed from cart'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
                child: const Text('Cancel',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    )),
              ),
              ElevatedButton(
                onPressed: () {
                  removeItem(id, context);
                },
                child: const Text('Remove',
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.red)),
              ),
            ],
          );
        });
  }

  nonExistingBagItems() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 0.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(context.tr('strShop'),
              style: const TextStyle(fontSize: 20.0),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () async {
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: Text(context.tr('strHome'),
                style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }

  expandedListBuilder() {
    return Column(
      children: [
        Expanded(
            child: ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: bagItemList.length,
          itemBuilder: (BuildContext context, int index) {
            var item = bagItemList[index];
            return Card(
                margin: const EdgeInsets.all(4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 4,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            item['imageId'],
                            fit: BoxFit.cover,
                            height: 120.0,
                            width: 140.0,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 6.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'],
                                  overflow: TextOverflow.clip,
                                  style: const TextStyle(
                                      fontSize: 18.0, letterSpacing: 1.0),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  "\$${item['price']}",
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          MaterialButton(
                            onPressed: () {
                              setProductQuantity('inc', item);
                            },
                            elevation: 8,
                            color: Colors.blueGrey,
                            shape: const CircleBorder(),
                            child: const Icon(
                              Icons.add,
                              size: 25,
                            ),
                          ),
                          Text(
                            '${item['quantity']}',
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          MaterialButton(
                            onPressed: () {
                              setProductQuantity('dec', item);
                            },
                            elevation: 8,
                            color: Colors.blueGrey,
                            shape: const CircleBorder(),
                            child: const Icon(
                              Icons.remove,
                              size: 25,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 30,
                              color: Colors.redAccent,
                            ),
                            onPressed: () {
                              removeItemAlertBox(context, item);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ));
          },
          separatorBuilder: (BuildContext context, int index) =>
              const SizedBox(height: 10.0),
        )),
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 3.0, 20.0, 0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(context.tr('strTotal'),
                      style: const TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '\$ $totalPrice.00',
                      style: const TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              ElevatedButton(
                style: const ButtonStyle(
                    backgroundColor:
                        WidgetStatePropertyAll(Colors.lightBlueAccent)),
                onPressed: () {
                  if (bagItemList.isNotEmpty) {
                    Map<String, dynamic> args = <String, dynamic>{};
                    args['price'] = totalPrice.toString();
                    Navigator.of(context)
                        .pushNamed('/checkout/address', arguments: args);
                  }
                },
                child: Text(
                  context.tr('strCheckout'),
                  style: const TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    bool showCartIcon = false;
    listBagItems(context);
    return Scaffold(
      key: scaffoldKey,
      appBar: header(context.tr('strShopCart'), scaffoldKey, showCartIcon, context),
      drawer: sidebar(context),
      body: Container(
          child: bagItemList.isEmpty
              ? nonExistingBagItems()
              : expandedListBuilder()),
    );
  }
}
