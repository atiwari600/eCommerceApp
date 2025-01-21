import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:e_commerce_app/services/shopping_cart_service.dart';
import 'package:e_commerce_app/services/user_service.dart';

class CheckoutService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService _userService = UserService();
  final ShoppingCartService _shoppingBagService = ShoppingCartService();
  final CollectionReference _shippingAddressReference = FirebaseFirestore.instance.collection('shippingAddress');
  final CollectionReference _creditCardReference = FirebaseFirestore.instance.collection('creditCard');
  final CollectionReference _shoppingBagReference = FirebaseFirestore.instance.collection('bags');
  final CollectionReference _orderReference = FirebaseFirestore.instance.collection('orders');
  final CollectionReference _productReference = FirebaseFirestore.instance.collection('products');

  Map mapAddressValues(Map values){
    Map addressValues = Map();
    addressValues['area'] = values['area'];
    addressValues['city'] = values['city'];
    addressValues['landmark'] = values['landMark'];
    addressValues['state'] = values['state'];
    addressValues['address'] = values['address'];
    addressValues['name'] = values['fullName'];
    addressValues['mobileNumber'] = values['mobileNumber'];
    addressValues['pinCode'] = values['pinCode'];
    return addressValues;
  }

  Future<void>updateAddressData(QuerySnapshot addressData, Map newAddress) async{
    var addressData1 = addressData.docs[0].data() as Map<String, dynamic>;

    String documentId = addressData.docs[0].id;
    List savedAddress = addressData1['address'];
    savedAddress.add(newAddress);
    await _shippingAddressReference.doc(documentId).update({'address': savedAddress});
  }

  Future<void> newShippingAddress(Map address) async{
    String? uid = await  _userService.getUserId();
    QuerySnapshot data = await _shippingAddressReference.where("userId", isEqualTo: uid).get();
    if(data.docs.length == 0){
      await _firestore.collection('shippingAddress').add({
        'userId': uid,
        'address': [mapAddressValues(address)]
      });
    }
    else{
      await updateAddressData(data,address);
    }
  }

  Future<List> listShippingAddress() async{
    String? uid = await _userService.getUserId();
    List addressList = [];

    QuerySnapshot docRef = await _shippingAddressReference.where('userId',isEqualTo: uid).get();
    var docRefData = docRef.docs[0].data() as Map<String, dynamic>;
    if(docRefData.isNotEmpty){
      addressList = docRefData['address'];
    }
    return addressList;

  }

  Future<void> newCreditCardDetails(String cardNumber, String expiryDate, String cardHolderName) async{
    String? uid = await _userService.getUserId();
    QuerySnapshot creditCardData = await _creditCardReference.where("cardNumber", isEqualTo: cardNumber).get();

    if(creditCardData.docs.isEmpty){
      await _creditCardReference.add({
        'cardNumber': cardNumber,
        'expiryDate': expiryDate,
        'cardHolderName': cardHolderName,
        'userId': uid
      });
    }
  }

  Future<List<String>> listCreditCardDetails() async{
    String? uid = await _userService.getUserId();
    List<String> cardNumberList = [];
    QuerySnapshot cardData = await _creditCardReference.where('userId',isEqualTo: uid).get();

    String cardNumber;
    for (var docRef in cardData.docs) {
      var cardRefData = docRef.data() as Map<String, dynamic>;

      cardNumber = cardRefData['cardNumber'].toString().replaceAll(RegExp(r"\s+\b|\b\s"),'');
      cardNumberList.add(cardNumber.substring(cardNumber.length - 4));
    }
    return cardNumberList;
  }

  Future<void> placeNewOrder(Map orderDetails) async{
    String? uid = await _userService.getUserId();
    QuerySnapshot items = await _shoppingBagReference.where('userId',isEqualTo: uid).get();
    var cardRefData = items.docs[0].data() as Map<String, dynamic>;

    await _orderReference.add({
      'userId': uid,
      'items': cardRefData['products'],
      'shippingAddress': orderDetails['shippingAddress'],
      'shippingMethod': orderDetails['shippingMethod'],
      'price': int.parse("${orderDetails['price']}"),
      'paymentCard': orderDetails['selectedCard'],
      'track': 1,
      'placedDate': DateTime.now()
    });
    
    await _shoppingBagService.delete();
  }
  
  Future<List> listPlacedOrder() async {
    List orderList = [];
    String? uid = await _userService.getUserId();
    QuerySnapshot orders = await _orderReference.where('userId', isEqualTo: uid).get();
    for(DocumentSnapshot order in orders.docs) {
      var ordersRefData = order.data() as Map<String, dynamic>;
      Map orderMap = {};
      orderMap['orderDate'] = ordersRefData['placedDate'];
      orderMap['track'] = ordersRefData['track'];
      List orderData = [];
      for (int i = 0; i < ordersRefData['items'].length; i++) {
        Map tempOrderData = {};
        tempOrderData['quantity'] = ordersRefData['items'][i]['quantity'];
        DocumentSnapshot docRef = await _productReference.doc(ordersRefData['items'][i]['id']).get();
        var docRefData = docRef.data() as Map<String, dynamic>;

        tempOrderData['review'] = docRefData['review'];
        tempOrderData['productImage'] = docRefData['imageId'];
        tempOrderData['productName'] = docRefData['name'];
        tempOrderData['price'] = docRefData['price'];
        tempOrderData['id'] = ordersRefData['items'][i]['id'];
        orderData.add(tempOrderData);
      }
      orderMap['orderDetails'] = orderData;
      orderList.add(orderMap);
    }
    return orderList;
  }

}