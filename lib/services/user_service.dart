import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:e_commerce_app/models/wishlist_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;
  late FlutterSecureStorage _storage;
  int statusCode = 0;
  String? msg;

  final CollectionReference _wishlistReference =
      FirebaseFirestore.instance.collection('wishlist');

  final CollectionReference _userReference =
      FirebaseFirestore.instance.collection('users');

  UserService() {
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
    _storage = const FlutterSecureStorage();
  }

  Future<bool> checkInternetConnectivity() async {
    return true;

    final Connectivity connectivity = Connectivity();
    List<ConnectivityResult> result = await connectivity.checkConnectivity();
    String connection = getConnectionValue(result);
    if (connection == 'None') {
      return false;
    } else {
      return true;
    }
  }

  String getConnectionValue(var connectivityResult) {
    String status = '';
    switch (connectivityResult) {
      case ConnectivityResult.mobile:
        status = 'Mobile';
        break;
      case ConnectivityResult.wifi:
        status = 'Wi-Fi';
        break;
      case ConnectivityResult.none:
        status = 'None';
        break;
      default:
        status = 'None';
        break;
    }
    return status;
  }

  static void showSnackBarMessage(BuildContext context, String? errorMessage) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage ?? 'Unexpected error has occured.'),
      ),
    );
  }

  String? userEmail() {
    var user = _auth.currentUser;
    return user?.email;
  }

  void logOut(context) async {
    await _storage.deleteAll();
    Navigator.of(context).pushReplacementNamed('/');
  }

  Future<void> signup(userValues) async {
    String email = userValues['email'];
    String password = userValues['password'];

    await _auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((dynamic user) {
      String uid = user.user.uid;
      _firestore
          .collection('users')
          .add({'fullName': userValues['fullName'], 'userId': uid});

      statusCode = 200;
    }).catchError((error) {
      handleAuthErrors(error);
    });
  }

  Future<void> login(userValues) async {
    String email = userValues['email'];
    String password = userValues['password'];

    await _auth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((dynamic user) async {
      final User? currentUser = _auth.currentUser;

      String? idToken = await currentUser?.getIdToken();
      String? refreshToken = currentUser?.refreshToken;

      storeJWTToken(idToken, refreshToken);

      statusCode = 200;
    }).catchError((error) {
      handleAuthErrors(error);
    });
  }

  Future<String?> getUserId() async {
    var token = await _storage.read(key: 'idToken');
    var uid = validateToken(token!);
    return uid;
  }

  String? validateToken(String token) {
    bool isExpired = JwtDecoder.isExpired(token);
    if (isExpired) {
      return null;
    } else {
      Map<String, dynamic> payload = JwtDecoder.decode(token);
      return payload['user_id'];
    }
  }

  Future<String?> pickAndUploadImage(BuildContext context) async {
    User? _user = _auth.currentUser;

    if (_user == null) {
      print('No user signed in');
      showSnackBarMessage(context, "User session expired. Please re-login");
      logOut(context);
      return null;
    }

    // Pick image from camera
    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 150,
    );
    print(image);
    if (image == null) return null;

    File file = File(image.path);

    try {
      String fileName = '${_user.uid}_${DateTime.now().millisecondsSinceEpoch}';
      Reference storageRef =
          FirebaseStorage.instance.ref().child('profile_images/$fileName');
      UploadTask uploadTask = storageRef.putFile(file);

      // Get download URL
      String downloadURL = await (await uploadTask).ref.getDownloadURL();

      // Update user profile with image URL
      await _user.updateProfile(photoURL: downloadURL);
      await _user.reload();
      _user = _auth.currentUser;
      return _user?.photoURL;
      showSnackBarMessage(
          context, 'Upload successful and user profile updated!');
      print('Upload successful and user profile updated!');
    } catch (e) {
      showSnackBarMessage(context, 'Error uploading image: $e');
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<List> userWishlistData() async {
    String? uid = await getUserId();
    QuerySnapshot userRef =
        await _userReference.where('userId', isEqualTo: uid).get();

    final userData = userRef.docs[0].data() as Map<String, dynamic>;
    List userWishList = [];

    if (userData.containsKey('wishlist')) {
      for (String item in userData['wishlist']) {
        Map<String, String> tempWishList = {};
        DocumentSnapshot productRef =
            await _firestore.collection('products').doc(item).get();
        final data = productRef.data() as Map<String, dynamic>;
        tempWishList['productId'] = data['productId'];
        tempWishList['productName'] = data['name'];
        tempWishList['price'] = data['price'];
        tempWishList['image'] = data['imageId'];
        tempWishList['productId'] = productRef.id;
        userWishList.add(tempWishList);
      }
    }
    return userWishList;
  }

  Future<Map<String, String>> userWishlist() async {
    String? uid = await getUserId();

    DocumentSnapshot wishlistRef = await _wishlistReference.doc(uid).get();
    return WishlistModel.fromFirestore(wishlistRef).toFirestore();
  }

  Future<void> deleteUserWishlistItems(String productId) async {
    String? uid = await getUserId();
    QuerySnapshot userRef =
        await _userReference.where('userId', isEqualTo: uid).get();
    String documentId = userRef.docs[0].id;
    final wishlist = userRef.docs[0].data() as Map<String, dynamic>;
    wishlist['wishlist'].remove(productId);

    await _userReference
        .doc(documentId)
        .update({'wishlist': wishlist['wishlist']});
  }

  Future<String?> addItemToWishlist(String productId) async {
    String msg = "Error occurred wishlist operation";
    String? uid = await getUserId();
    List<dynamic> wishlist = [];
    QuerySnapshot userRef =
        await _userReference.where('userId', isEqualTo: uid).get();
    final wishlistRef = userRef.docs[0].data() as Map<String, dynamic>;
    String documentId = userRef.docs[0].id;
    if (wishlistRef.containsKey('wishlist')) {
      wishlist = wishlistRef['wishlist'];
      if (!wishlist.contains(productId)) {
        wishlist.add(productId);
      } else {
        msg = 'Product existed in Wishlist';
        return msg;
      }
    } else {
      wishlist.add(productId);
    }
    await _userReference
        .doc(documentId)
        .update({'wishlist': wishlist}).then((value) {
      msg = 'Product added to wishlist';
    });
    return msg;
  }

  void storeJWTToken(String? idToken, String? refreshToken) async {
    await _storage.write(key: 'idToken', value: idToken);
    await _storage.write(key: 'refreshToken', value: refreshToken);
  }

  void handleAuthErrors(error) {
    String errorCode = error.code;
    msg = error.code;
    switch (errorCode) {
      case "ERROR_EMAIL_ALREADY_IN_USE":
        {
          statusCode = 400;
          msg = "Email ID already existed";
        }
        break;
      case "ERROR_WRONG_PASSWORD":
        {
          statusCode = 400;
          msg = "Password is wrong";
        }
      case "invalid-credential":
        {
          statusCode = 400;
          msg = "The supplied auth credential is incorrect";
        }
    }
  }

  Future<Map> getUserProfile(BuildContext context) async {
    Map profileDetails = {};
    User? _user = _auth.currentUser;
    if(_user == null){
      showSnackBarMessage(context, "User session expired. Please re-login");
      logOut(context);
    }
    String? uid = await getUserId();
    QuerySnapshot profileData = await _firestore
        .collection('users')
        .where('userId', isEqualTo: uid)
        .get();
    final userRef = profileData.docs[0].data() as Map<String, dynamic>;
    profileDetails['fullName'] = userRef['fullName'];
    profileDetails['photoURL'] = _user?.photoURL;
    return profileDetails;
  }

  Future<bool> loadNotiSettingState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('noti_state') ?? false;
  }

  Future<void> saveNotiSettingState(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('noti_state', value);
  }

  Future<bool> loadThemeSettingState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('theme_state') ?? false;
  }

  Future<void> saveThemeSettingState(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('theme_state', value);
  }

  Future<String> loadLanguageSettingState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('pref_language') ?? "en";
  }

  Future<void> saveLanguageSettingState(String? value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('pref_language', value ?? "en");
  }


}
