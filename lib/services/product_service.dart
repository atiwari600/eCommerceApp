import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/models/product.dart';
import 'package:e_commerce_app/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductService {
  final CollectionReference _productReference =
      FirebaseFirestore.instance.collection('products');

  Future<List<Map<String, String>>> featuredItems() async {
    List<Map<String, String>> itemList = [];
    QuerySnapshot itemsRef = await _productReference.get();
    for (DocumentSnapshot docRef in itemsRef.docs) {
      itemList.add(Product.fromFirestore(docRef).toFirestore());
    }
    return itemList;
  }

  Future<Map<String, String>> particularItem(String productId) async {
    DocumentSnapshot prodRef = await _productReference.doc(productId).get();
    return Product.fromFirestore(prodRef).toFirestore();
  }

  Future<Product> particularItemData(String productId) async {
    DocumentSnapshot prodRef = await _productReference.doc(productId).get();
    return Product.fromFirestore(prodRef);
  }

  Future<void> updateReview(List itemList, String review) async{
    UserService userService = UserService();
    User? _user = FirebaseAuth.instance.currentUser;
    String username = 'Unknown: ';
    if(_user != null){
      String? uid = await userService.getUserId();
      QuerySnapshot profileData = await FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: uid)
          .get();
      final userRef = profileData.docs[0].data() as Map<String, dynamic>;
      username = "${userRef['fullName']} :";
    }
    for(final item in itemList){
      print("$username$review\n");
      print(item['id']);
      await _productReference.doc(item['id']).update({'review':"${item['review']}\n$username$review"});
    }
  }

}
