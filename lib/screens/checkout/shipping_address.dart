import 'dart:collection';
import 'package:flutter/material.dart';

import '../../components/checkout/checkout_app_bar.dart';
import '../../components/checkout/shipping_address_input.dart';
import '../../services/checkout_service.dart';

class ShippingAddress extends StatefulWidget {
  const ShippingAddress({super.key});

  @override
  State<ShippingAddress> createState() => _ShippingAddressState();
}

class _ShippingAddressState extends State<ShippingAddress> {
  final _formKey = GlobalKey<FormState>();
  bool autoValidate = false;
  bool visibleInput = false;
  int selectedAddress = 0;
  final CheckoutService _checkoutService = CheckoutService();
  HashMap addressValues = HashMap();
  List shippingAddress = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  checkoutAddress() {
    Map<String, dynamic> args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    args['shippingAddress'] = shippingAddress[selectedAddress];
    args['shippingMethod'] = "UPS Ground";
    Navigator.of(context).pushNamed('/checkout/paymentMethod', arguments: args);
  }

  validateInput() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await _checkoutService.newShippingAddress(addressValues);
      String msg = 'Address is saved';
      // showInSnackBar(msg, Colors.black);
      setState(() {
        visibleInput = !visibleInput;
        shippingAddress.add(addressValues);
      });
    } else {
      setState(() {
        autoValidate = true;
      });
    }
  }

  listShippingAddress() async {
    List data = await _checkoutService.listShippingAddress();
    setState(() {
      shippingAddress = data;
    });
  }

  saveNewAddress() {
    return Container(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: Column(
          children: <Widget>[
            const Text(
              'No address saved',
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  visibleInput = true;
                });
              },
              child: const Text(
                'Add new',
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  showSavedAddress() {
    return Container(
      child: Column(
        children: <Widget>[
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: shippingAddress.length,
            itemBuilder: (BuildContext context, int index) {
              var item = shippingAddress[index];
              return Card(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Icon(Icons.home),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            item['name'] ?? "Unknown",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 5.0),
                          Text(
                            item['address'],
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            "${item['area']}, ${item['city']}",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            "${item['state']} ${item['pinCode']}",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text("Phone number : ${item['mobileNumber']}")
                        ],
                      ),
                      Radio(
                        value: index,
                        groupValue: selectedAddress,
                        onChanged: (value) {
                          setState(() {
                            selectedAddress = index;
                          });
                        },
                      )
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10.0),
          ElevatedButton(
            onPressed: () {
              setState(() {
                visibleInput = true;
              });
            },
            child: const Text(
              'Add new',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    listShippingAddress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CheckoutAppBar('Back', 'Next', checkoutAddress),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Shipping Address',
                  style: TextStyle(
                      fontFamily: 'NovaSquare',
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10.0),
                !visibleInput
                    ? (shippingAddress.isEmpty)
                        ? saveNewAddress()
                        : showSavedAddress()
                    : ShippingAddressInput(addressValues, validateInput)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
