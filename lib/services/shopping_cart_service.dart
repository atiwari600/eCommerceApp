import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/services/user_service.dart';

class ShoppingCartService{
  final UserService userService = UserService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _shoppingBagReference = FirebaseFirestore.instance.collection('bags');
  final CollectionReference _productReference = FirebaseFirestore.instance.collection('products');

  Future<String> add(String productId,String size,String color,int quantity) async{
    String? uid = await userService.getUserId();
    String msg;
    QuerySnapshot userBag = await _shoppingBagReference.where("userId", isEqualTo: uid).get();
    if(userBag.docs.isEmpty){
      await _firestore.collection('bags').add({
        'userId': uid,
        'products':[{
          'id': productId,
          'quantity': quantity
        }]
      });
      msg =  "Product added to shopping bag";
    }
    else{
      msg = await update(productId, size, color, quantity, userBag);
    }
    return msg;
  }


  Future<String> update(String productId, String size, String color, int quantity, QuerySnapshot bagItems) async{
    String? documentId;
    String msg;
    List productItems = bagItems.docs.map((doc){
      documentId = doc.id;
      return doc['products'];
    }).toList()[0];
    List product = productItems.where((test)=> test['id'] == productId).toList();

    if(product.isNotEmpty){
      for (var items in productItems) {
        if(items['id'] == productId){
          items['size'] = size;
          items['color'] = color;
          items['quantity'] = quantity;
        }
      }
      await _shoppingBagReference.doc(documentId).update({'products':productItems});
      msg =  "Product updated in shopping bag";
    }
    else{
      productItems.add({'id':productId,'quantity':quantity});
      await _shoppingBagReference.doc(documentId).update({'products':productItems});
      msg = 'Product added to shopping bag';
    }

    await _productReference.doc(productId).update({'orderedQuantity':quantity.toString()});


    return msg;
  }


  Future<void> remove(String id) async{
    String? uid = await userService.getUserId();

    await _shoppingBagReference.where('userId',isEqualTo: uid).get().then((QuerySnapshot doc){
      doc.docs.forEach((docRef) async{
        List products = docRef['products'];
        if(products.length == 1){
          await _shoppingBagReference.doc(docRef.id).delete();
          await _productReference.doc(id).update({'orderedQuantity':"0"});
        }
        else{
          products.removeWhere((productData) => productData['id'] == id);
          await _shoppingBagReference.doc(docRef.id).update({'products':products});
          await _productReference.doc(id).update({'orderedQuantity':"0"});
        }
      });
    });
  }

  Future<void> delete() async{
    String? uid = await userService.getUserId();
    await _shoppingBagReference.where('userId',isEqualTo: uid).get().then((QuerySnapshot doc){
      doc.docs.forEach((docRef) async{
        List products = docRef['products'];
        products.forEach((productData) async {
        await _productReference.doc(productData['id']).update({'orderedQuantity':"0"});;
        });
      });
    });
    QuerySnapshot bagItems = await _shoppingBagReference.where('userId',isEqualTo: uid).get();
    String shoppingBagItemId = bagItems.docs[0].id;

    deleteTransaction(Transaction tx) async{
      final DocumentSnapshot ds = await tx.get(_shoppingBagReference.doc(shoppingBagItemId));
      tx.delete(ds.reference);
    }

    await _firestore.runTransaction(deleteTransaction);
  }

  Future<List> list() async{
    List cartItemsList = [];
    List cartItemDetails ;
    String? uid = await userService.getUserId();

    QuerySnapshot userCartDocRef = await _shoppingBagReference.where("userId",isEqualTo: uid).get();
    int totalBags = userCartDocRef.docs.length;

    if(totalBags != 0){
      cartItemDetails = userCartDocRef.docs.map((bagDoc){
        final cartRef = bagDoc.data() as Map<String, dynamic>;
        return cartRef['products'];
      }).toList()[0];

      for(int i=0; i < cartItemDetails.length; i++){
        Map bagItems = {};

        DocumentSnapshot productReference = await _productReference.doc(cartItemDetails[i]['id']).get();
        final productRef = productReference.data() as Map<String, dynamic>;
        bagItems['productId'] = productRef['productId'];
        bagItems['name']  = productRef['name'];
        bagItems['imageId']  = productRef['imageId'];
        bagItems['price']  = productRef['price'].toString();
        bagItems['color'] = productRef['color'].cast<String>().toList();
        bagItems['size'] = productRef['size'].cast<String>().toList();
        bagItems['selectedSize'] = cartItemDetails[i]['size'];
        bagItems['selectedColor'] = cartItemDetails[i]['color'];
        bagItems['quantity'] = cartItemDetails[i]['quantity'];
        cartItemsList.add(bagItems);
      }
    }

    return cartItemsList;
  }

}