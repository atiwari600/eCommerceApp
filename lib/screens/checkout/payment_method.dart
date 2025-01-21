import 'package:flutter/material.dart';

import '../../components/checkout/checkout_app_bar.dart';
import '../../services/checkout_service.dart';

class PaymentMethod extends StatefulWidget {
  const PaymentMethod({super.key});

  @override
  State<PaymentMethod> createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
  final CheckoutService _checkoutService = CheckoutService();
  List<String> cardNumberList = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? selectedPaymentCard;
  bool visibleInput = false;

  checkoutPaymentMethod() {
    if (selectedPaymentCard != null) {
      Map<String, dynamic> args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      args['selectedCard'] = selectedPaymentCard;
      Navigator.pushNamed(context, '/checkout/placeOrder', arguments: args);
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Select any card"),
        ),
      );
    }
  }

  listPaymentMethod() async {
    var data = await _checkoutService.listCreditCardDetails();
    setState(() {
      cardNumberList = data;
    });
  }

  showSavedCreditCard() {
    return Column(
      children: <Widget>[
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cardNumberList.length,
          itemBuilder: (BuildContext context, int index) {
            var item = cardNumberList[index];
            return CheckboxListTile(
              secondary: const Icon(Icons.credit_card),
              title: Text('Visa Ending with $item'),
              onChanged: (value) {
                setState(() {
                  selectedPaymentCard = item;
                });
              },
              value: selectedPaymentCard == item,
            );
          },
        )
      ],
    );
  }

  setVisibileInput() {
    setState(() {
      visibleInput = !visibleInput;
    });
  }

  animatePaymentContainers() {
    return AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: cardNumberList.isNotEmpty
            ? showSavedCreditCard()
            : const Text('No card found'));
  }

  @override
  void initState() {
    super.initState();
    listPaymentMethod();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CheckoutAppBar('Cancel', 'Next', checkoutPaymentMethod),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Payment Method',
              style: TextStyle(
                  fontFamily: 'NovaSquare',
                  fontSize: 18.0,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.bold),
            ),
            // const Padding(
            //   padding: EdgeInsets.only(top: 20.0, bottom: 30.0),
            //   child: Center(
            //     child: Icon(
            //       Icons.credit_card,
            //       size: 200.0,
            //     )
            //   ),
            // ),
            cardNumberList.isNotEmpty
                ? showSavedCreditCard()
                : const Text('No card found'),
            // animatePaymentContainers(),
            const SizedBox(height: 20.0),
            GestureDetector(
              onTap: () {
                Map<String, dynamic> args = ModalRoute.of(context)
                    ?.settings
                    .arguments as Map<String, dynamic>;
                Navigator.pushNamed(context, '/checkout/addCreditCard',
                    arguments: args);
              },
              child: const ListTile(
                leading: Icon(Icons.add),
                title: Text('Add new Card'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
