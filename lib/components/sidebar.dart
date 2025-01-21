import 'package:e_commerce_app/services/checkout_service.dart';
import 'package:e_commerce_app/services/product_service.dart';
import 'package:e_commerce_app/services/shopping_cart_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../services/local_notifications_service.dart';
import '../services/user_service.dart';
import 'loader.dart';

Widget sidebar(BuildContext context) {
  final GlobalKey<State> keyLoader = GlobalKey<State>();
  UserService userService = UserService();
  ProductService productService = ProductService();
  ShoppingCartService cartService = ShoppingCartService();
  CheckoutService checkoutService = CheckoutService();

  void loadNotiSetting(List<dynamic> bagItems) async {
    if (bagItems.isNotEmpty) {
      bool notiState = await userService.loadNotiSettingState();
      if (notiState) {
        LocalNotificationsService.showCartNotification();
      }
    }
  }

  return SafeArea(
    child: Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                leading: const Icon(Icons.home),
                title: Text(
                  context.tr('strHome'),
                  style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0),
                ),
                onTap: () {
                  Navigator.popAndPushNamed(context, '/home');
                },
              ),
              ListTile(
                leading: const Icon(Icons.shopping_cart),
                title: Text(
                  context.tr('strCart'),
                  style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0),
                ),
                onTap: () async {
                  Map<String, dynamic> args = {};
                  Loader.showLoadingScreen(context, keyLoader);
                  List bagItems = await cartService.list();
                  args['bagItems'] = bagItems;
                  args['route'] = '/home';
                  Loader.hideLoadingScreen(keyLoader);
                  Navigator.popAndPushNamed(context, '/bag', arguments: args);
                  loadNotiSetting(bagItems);
                },
              ),
              ListTile(
                leading: const Icon(Icons.local_shipping),
                title: Text(
                  context.tr('strOrderHistory'),
                  style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0),
                ),
                onTap: () async {
                  Loader.showLoadingScreen(context, keyLoader);
                  List orderData = await checkoutService.listPlacedOrder();
                  Loader.hideLoadingScreen(keyLoader);
                  Navigator.popAndPushNamed(context, '/placedOrder',
                      arguments: {'data': orderData});
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite_border),
                title: Text(context.tr('strWishlist'),
                  style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0),
                ),
                onTap: () async {
                  List userList = await userService.userWishlistData();
                  Navigator.popAndPushNamed(context, '/wishlist',
                      arguments: {'userList': userList});
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(context.tr('strProfile'),
                  style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0),
                ),
                onTap: () async {
                  Loader.showLoadingScreen(context, keyLoader);
                  Map userProfile = await userService.getUserProfile(context);
                  Navigator.of(keyLoader.currentContext!, rootNavigator: true)
                      .pop();
                  Navigator.popAndPushNamed(context, '/profile',
                      arguments: userProfile);
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: Text(context.tr('strLogout'),
                  style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0),
                ),
                onTap: () {
                  userService.logOut(context);
                },
              )
            ],
          )
        ],
      ),
    ),
  );
}
