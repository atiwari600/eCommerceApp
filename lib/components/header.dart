import 'package:e_commerce_app/services/shopping_cart_service.dart';
import 'package:flutter/material.dart';

import '../core/size_config.dart';
import 'loader.dart';

AppBar header(String? headerText, GlobalKey<ScaffoldState> scaffoldKey,
    bool showIcon, BuildContext context) {
  SizeConfig().init(context);
  final GlobalKey<State> keyLoader = GlobalKey<State>();
  ShoppingCartService cartService = ShoppingCartService();
  return AppBar(
    centerTitle: true,
    title: headerText == null? Image.asset(
      'assets/e-commerce-logo.png',
      height: 20,
    ):Text(
      headerText,
      style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: SizeConfig.safeBlockHorizontal * 5,),
    ),
    backgroundColor: Colors.white,
    elevation: 1.0,
    automaticallyImplyLeading: false,
    leading: IconButton(
      icon: Icon(Icons.menu,
          size: SizeConfig.safeBlockHorizontal * 7, color: Colors.black),
      onPressed: () {
        if (scaffoldKey.currentState?.isDrawerOpen == false) {
          scaffoldKey.currentState?.openDrawer();
        } else {
          scaffoldKey.currentState?.openEndDrawer();
        }
      },
    ),
    actions: <Widget>[
      Visibility(
        visible: showIcon,
        child: IconButton(
          icon: Icon(
            Icons.shopping_cart,
            size: SizeConfig.safeBlockHorizontal * 7,
            color: Colors.black,
          ),
          onPressed: () async {
            Map<String, dynamic> args = {};
            Loader.showLoadingScreen(context, keyLoader);
            List bagItems = await cartService.list();
            args['bagItems'] = bagItems;
            args['route'] = '/home';
            Loader.hideLoadingScreen(keyLoader);
            Navigator.popAndPushNamed(context, '/bag', arguments: args);
          },
        ),
      )
    ],
  );
}
