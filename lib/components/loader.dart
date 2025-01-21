import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loader{
  static Future<void> showLoadingScreen(BuildContext context, GlobalKey key) async{
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return WillPopScope(
              onWillPop: () async => false,
              child: Container(
                key: key,
                child: const SpinKitFoldingCube(
                  color: Colors.blue,
                  size: 50.0,
                ),
              )
          );
        }
    );
  }

  static void hideLoadingScreen(GlobalKey key){
    Navigator.of(key.currentContext!, rootNavigator: true).pop();
  }
}