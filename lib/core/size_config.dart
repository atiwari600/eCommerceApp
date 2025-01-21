import 'package:flutter/widgets.dart';

class SizeConfig{
  static MediaQueryData? _mediaQueryData;
  static double screenWidth=0;
  static double screenHeight=0;
  static double safeAreaHorizontal=0;
  static double safeAreaVertical=0;
  static double safeBlockHorizontal=0;
  static double safeBlockVertical=0;
  static double topPadding=0;
  static String? screenSize;

  void init(BuildContext context){
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData!.size.width;
    screenHeight = _mediaQueryData!.size.height;

    topPadding = _mediaQueryData!.padding.top;

    safeAreaHorizontal = _mediaQueryData!.padding.left + _mediaQueryData!.padding.right;
    safeAreaVertical = _mediaQueryData!.padding.top + _mediaQueryData!.padding.bottom;

    safeBlockHorizontal = (screenWidth - safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - safeAreaVertical) / 100;

    if(screenWidth >= 600){
      screenSize = 'tablet';
    }
    else if(screenWidth >= 400){
      screenSize = 'largeMobile';
    }
    else{
      screenSize = 'smallMobile';
    }

  }

}