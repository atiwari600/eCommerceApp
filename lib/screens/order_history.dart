import 'package:e_commerce_app/services/product_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:progress_stepper/progress_stepper.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../components/header.dart';
import '../components/sidebar.dart';
import '../core/size_config.dart';

class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  _OrderHistoryState createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  ProductService productService = ProductService();
  List itemList = [];

  void listOrderItems(context) async {
    Map<dynamic, dynamic> args =
        ModalRoute.of(context)?.settings.arguments as Map<dynamic, dynamic>;
    for (var items in args['data']) {
      int total = 0;
      for (int i = 0; i < items['orderDetails'].length; i++) {
        print(items['orderDetails']);
        int quantity = items['orderDetails'][i]['quantity'];
        var price = items['orderDetails'][i]['price'];
        total = total + (int.parse(price) * quantity);
      }
      items['totalPrice'] = total.toString();
    }
    setState(() {
      itemList = args['data'];
    });
  }

  void _showRatingDialog(itemList) {
    double rating = 0.0;
    TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rate Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RatingBar.builder(
                initialRating: rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (newRating) {
                  rating = newRating;
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Your review',
                  border: OutlineInputBorder(),
                ),
                maxLines: 1,
                maxLength: 20,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Handle submission logic here
                productService.updateReview(itemList, _controller.text);
                print('Rating: $rating');
                print('Feedback: ${_controller.text}');
                Navigator.of(context).pop();
              },
              child: const Text('Submit'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final GlobalKey<ScaffoldState> _scaffoldKey =
        new GlobalKey<ScaffoldState>();
    bool showCartIcon = true;
    listOrderItems(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context.tr('strOrderHistoryProfile'), _scaffoldKey, showCartIcon, context),
      drawer: sidebar(context),
      body: ListView.builder(
        itemCount: itemList.length,
        itemBuilder: (BuildContext context, int index) {
          List item = itemList[index]['orderDetails'];
          String totalPrice = itemList[index]['totalPrice'];
          String orderedDate = timeago
              .format(itemList[index]['orderDate'].toDate(), locale: 'fr');
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Card(
              elevation: 3.0,
              child: Column(
                children: <Widget>[
                  Container(
                    constraints: const BoxConstraints.expand(height: 150.0),
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                        image: DecorationImage(
                            image: Image.asset(item[0]['productImage']).image,
                            fit: BoxFit.fill,
                            colorFilter: const ColorFilter.mode(
                                Color.fromRGBO(90, 90, 90, 0.8),
                                BlendMode.modulate))),
                    child: Stack(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              '${context.tr('strOrdered')} $orderedDate',
                              style: const TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.white,
                                  letterSpacing: 1.0),
                            ),
                          ),
                        ),
                        Center(
                          child: Text(context.tr('strPlaced'),
                            style: const TextStyle(
                              fontSize: 20.0,
                              letterSpacing: 1.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: item.length,
                    itemBuilder: (BuildContext context, int itemIndex) {
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 30.0,
                          backgroundImage: Image.asset(
                            item[itemIndex]['productImage'],
                          ).image,
                        ),
                        title: Text(
                          item[itemIndex]['productName'],
                          style: const TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Row(
                          children: [
                            Text(
                              "\$ ${item[itemIndex]['price']}.00",
                              style: const TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              "  X  ${item[itemIndex]['quantity']}",
                              style: const TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 10),child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Total: \$ $totalPrice.00",
                        style: const TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                          style: const ButtonStyle(
                            backgroundColor:
                            WidgetStatePropertyAll(Colors.blueGrey),
                          ),
                          onPressed: () {
                            _showRatingDialog(item);
                          },
                          child: Text(context.tr('strRateOrder'),
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ))
                    ],
                  ),),
                  const SizedBox(height: 10.0),
                  ProgressStepper(
                    width: SizeConfig.screenWidth,
                    height: 40,
                    padding: 1,
                    currentStep: itemList[index]['track'],
                    stepCount: 3,
                    bluntHead: true,
                    bluntTail: true,
                    color: Colors.grey,
                    progressColor: Colors.lightGreen,
                    labels: <String>[context.tr('strPacked'), context.tr('strInTransit'), context.tr('strResetAll')],
                    defaultTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    selectedTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
