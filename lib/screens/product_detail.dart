import 'package:e_commerce_app/components/rating_star_widget.dart';
import 'package:e_commerce_app/services/shopping_cart_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../components/header.dart';
import '../components/loader.dart';
import '../components/sidebar.dart';
import '../services/user_service.dart';
import '../core/size_config.dart';

class ProductDetail extends StatefulWidget {
  final Map<String, String> itemDetails;
  final bool editProduct;

  const ProductDetail({
    super.key,
    required this.itemDetails,
    required this.editProduct,
  });

  @override
  State<ProductDetail> createState() {
    return _ProductDetailState();
  }
}

class _ProductDetailState extends State<ProductDetail> {
  final GlobalKey<ScaffoldState> _productScaffoldKey =
      GlobalKey<ScaffoldState>();

  final UserService _userService = UserService();
  final ShoppingCartService _cartService = ShoppingCartService();
  final GlobalKey<State> _keyLoader = GlobalKey<State>();

  Map customDimension = {};
  List<Map<Color, bool>> productColors = [];
  List<Map<String, bool>> productSizes = [];
  int productQuantity = 0;

  @override
  void initState() {
    productQuantity = int.parse(widget.itemDetails['orderedQuantity']!);
    super.initState();
  }

  void _addRemoveWishlist() async {
    Loader.showLoadingScreen(context, _keyLoader);
    String? res =
        await _userService.addItemToWishlist(widget.itemDetails['productId']!);
    Loader.hideLoadingScreen(_keyLoader);
    if (res != null) {
      UserService.showSnackBarMessage(context, res);
    }
  }

  void _addUpdateCart() async {
    if (productQuantity == 0) {
      UserService.showSnackBarMessage(context, context.tr('strAddProduct'));
      return;
    }
    Loader.showLoadingScreen(context, _keyLoader);
    String msg = await _cartService.add(
        widget.itemDetails['productId']!, "-", "-", productQuantity);
    Loader.hideLoadingScreen(_keyLoader);
    UserService.showSnackBarMessage(context, msg);
  }

  void setProductQuantity(String type) {
    setState(() {
      if (type == 'inc') {
        if (productQuantity < int.parse(widget.itemDetails['maxQuantity']!)) {
          productQuantity = productQuantity + 1;
        }
      } else {
        if (productQuantity > 0) {
          productQuantity = productQuantity - 1;
        }
      }
    });
  }

  @override
  Widget build(BuildContext buildContext) {
    SizeConfig().init(buildContext);
    return Scaffold(
      key: _productScaffoldKey,
      appBar: header(
          context.tr('strProductDetails'), _productScaffoldKey, true, context),
      drawer: sidebar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              widget.itemDetails['imageId']!,
              fit: BoxFit.fill,
              height: 250,
              width: SizeConfig.screenWidth,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          widget.itemDetails['name']!,
                          style: const TextStyle(
                              fontSize: 22,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0),
                        ),
                      ),
                      Text(
                        "\$${widget.itemDetails['price']!}.00",
                        style: const TextStyle(
                            fontSize: 18,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.itemDetails['subCategory']!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      RatingStarWidget(
                          rating: int.parse(widget.itemDetails['rating']!)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr('strDescription'),
                    style: const TextStyle(
                      fontSize: 22,
                    ),
                  ),
                  Text(
                    widget.itemDetails['description']!,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  widget.itemDetails['review'] == null ||
                          widget.itemDetails['review']!.isEmpty
                      ? const SizedBox()
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('strReview'),
                              style: const TextStyle(
                                fontSize: 22,
                              ),
                            ),
                            Text(
                              widget.itemDetails['review']!,
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        context.tr('strQuantity'),
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {
                          setProductQuantity('inc');
                        },
                        elevation: 8,
                        color: Colors.blueGrey,
                        shape: const CircleBorder(),
                        child: const Icon(
                          Icons.add,
                          size: 20,
                        ),
                      ),
                      Text(
                        '$productQuantity',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {
                          setProductQuantity('dec');
                        },
                        elevation: 8,
                        color: Colors.blueGrey,
                        shape: const CircleBorder(),
                        child: const Icon(
                          Icons.remove,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: ElevatedButton(
                        onPressed: () {
                          _addUpdateCart();
                        },
                        child: Text(
                          context.tr('strAddCart'),
                          style: const TextStyle(fontSize: 20),
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                      )),
                      const SizedBox(width: 5,),
                      Expanded(child: ElevatedButton(

                        onPressed: () {
                          _addRemoveWishlist();
                        },
                        child: Text(
                          context.tr('strAddWish'),
                          style: const TextStyle(fontSize: 20),
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
