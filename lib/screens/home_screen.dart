import 'package:e_commerce_app/services/user_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../components/header.dart';
import '../components/sidebar.dart';
import '../services/product_service.dart';
import '../components/autocomplete_grid_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService _productService = ProductService();
  final UserService _userService = UserService();
  List<Map<String, String>> featuredItems = [];

  void listFeaturedItems() async {
    List<Map<String, String>> featuredItemList =
        await _productService.featuredItems();
    setState(() {
      featuredItems = featuredItemList;
    });
  }

  @override
  void initState() {
    listFeaturedItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return WillPopScope(
      onWillPop: () async {
        return (await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0)),
                      title: Text(context.tr('strLogoutTitle')),
                      content: Text(context.tr('strLogoutText')),
                      actions: [
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(context.tr('StrNo'),
                              style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,)),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(context.tr('StrYes'),
                              style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red)),
                        )
                      ],
                    ))) ??
            false;
      },
      child: Scaffold(
        key: scaffoldKey,
        appBar: header(null, scaffoldKey, true, context),
        drawer: sidebar(context),
        body: AutocompleteGridView(featuredItems: featuredItems),
      ),
    );
  }
}
