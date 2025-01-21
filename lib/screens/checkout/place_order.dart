import 'package:e_commerce_app/components/loader.dart';
import 'package:flutter/material.dart';

import '../../components/checkout/checkout_app_bar.dart';
import '../../services/checkout_service.dart';
import '../../services/local_notifications_service.dart';
import '../../services/user_service.dart';

class PlaceOrder extends StatefulWidget {
  const PlaceOrder({super.key});

  @override
  State<PlaceOrder> createState() => _PlaceOrderState();
}

class _PlaceOrderState extends State<PlaceOrder> {
  void thirdFunction(){}
  Map<String,dynamic> orderDetails = {};
  final CheckoutService _checkoutService = CheckoutService();
  final UserService _userService = UserService();
  final GlobalKey<State> keyLoader = GlobalKey<State>();

  setOrderData(){
    Map<String,dynamic> args = ModalRoute.of(context)?.settings.arguments as Map<String,dynamic>;
    setState(() {
      orderDetails = args;
    });
  }

  placeNewOrder() async{
    Loader.showLoadingScreen(context, keyLoader);
    await _checkoutService.placeNewOrder(orderDetails);
    Loader.hideLoadingScreen(keyLoader);
    bool notiState = await _userService.loadNotiSettingState();
    if(notiState) {
      LocalNotificationsService.showPlacedOrderNotification();
    }
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    setOrderData();
    return Scaffold(
      appBar: CheckoutAppBar('Shopping Bag','',this.thirdFunction),
      body: Container(
        decoration: const BoxDecoration(
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 10.0),
          child: Column(
            children: <Widget>[
              const Text(
                'Check out',
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0
                ),
              ),
              const SizedBox(height: 30.0),
              Card(
                shape: const ContinuousRectangleBorder(
                  borderRadius: BorderRadius.zero
                ),
                borderOnForeground: true,
                elevation: 0,
                child: ListTile(
                  title: const Text('Payment'),
                  trailing: Text('Visa ${orderDetails['selectedCard']}'),

                ),
              ),
              Card(
                shape: const ContinuousRectangleBorder(
                    borderRadius: BorderRadius.zero
                ),
                borderOnForeground: true,
                elevation: 0,
                child: ListTile(
                  title: const Text('Shipping'),
                  trailing: Text(orderDetails['shippingMethod']),
                ),
              ),
              Card(
                shape: const ContinuousRectangleBorder(
                    borderRadius: BorderRadius.zero
                ),
                borderOnForeground: true,
                elevation: 0,
                child: ListTile(
                  title: const Text('Total'),
                  trailing: Text('\$ ${orderDetails['price']}.00'),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child:  TextButton(
                    onPressed: () {
                      placeNewOrder();
                    },
                    child: const Text(
                        'Place order',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0
                        )
                    ),
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
