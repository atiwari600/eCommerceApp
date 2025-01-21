import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistModel {
  final String productId;
  final String name;
  final String price;
  final String imageId;

  WishlistModel(
      {required this.productId,
        required this.name,
        required this.price,
        required this.imageId,
      });

  factory WishlistModel.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return WishlistModel(
        productId: data['productId'],
        name: data['name'],
        price: data['price'],
        imageId: data['imageId'],
    );
  }

  Map<String, String> toFirestore() {
    return {
      "productId": productId,
      "name": name,
      "price": price,
      "imageId": imageId,
    };
  }
}