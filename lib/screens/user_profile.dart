import 'package:e_commerce_app/services/checkout_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../components/header.dart';
import '../components/loader.dart';
import '../components/sidebar.dart';
import '../main.dart';
import '../services/user_service.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final UserService _userService = UserService();
  final CheckoutService checkoutService = CheckoutService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<State> _keyLoader = GlobalKey<State>();
  bool showCartIcon = true;
  bool _isSwitched = false;
  bool _isDarkMode = false;
  String? name;
  String? image;
  String? _selectedLanguageValue;

  void setProfileDetails(context) async {
    dynamic args = ModalRoute.of(context)?.settings.arguments;
    setState(() {
      name = args['fullName'];
      image ??= args['photoURL'];
    });
  }

  @override
  void initState() {
    super.initState();
    loadNotiSetting();
    loadThemeSetting();
    loadLanguageSetting();
  }

  void loadThemeSetting() async {
    bool isDarkMode = await UserService().loadThemeSettingState();
    setState(() {
      _isDarkMode = isDarkMode;
    });
  }

  void loadNotiSetting() async {
    bool notiState = await _userService.loadNotiSettingState();
    setState(() {
      _isSwitched = notiState;
    });
  }

  void _toggleNoti(bool value) {
    setState(() {
      _isSwitched = value;
    });
    _userService.saveNotiSettingState(value);
  }

  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    App.of(context).changeTheme(value ? ThemeMode.dark : ThemeMode.light);
    _userService.saveThemeSettingState(value);
  }

  void _toggleLanguageChange(String? value) {
    String val = (value == "French") ? "fr" : "en";
    Locale locale = (val == "fr") ? const Locale('fr', 'FR') : const Locale('en', 'US');
    setState(() {
      _selectedLanguageValue = value;
    });
    _userService.saveLanguageSettingState(val);
    context.setLocale(locale);
    App.of(context).changeLocale(locale);
  }

  void loadLanguageSetting() async {
    String langValue = await _userService.loadLanguageSettingState();
    setState(() {
      _selectedLanguageValue = (langValue == "fr" ? "French" : "English");
    });
  }

  @override
  Widget build(BuildContext context) {
    setProfileDetails(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(
          context.tr('strUserProfile'), _scaffoldKey, showCartIcon, context),
      drawer: sidebar(context),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.only(top: 20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: 150.0,
                height: 150.0,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        fit: BoxFit.fill,
                        image: image == null
                            ? const AssetImage('assets/userProfile.jpg')
                            : Image.network(image!).image)),
              ),
              const SizedBox(height: 10.0),
              ElevatedButton(
                  onPressed: () async {
                    var data = await _userService.pickAndUploadImage(context);
                    setState(() {
                      image = data;
                    });
                  },
                  child: Text(context.tr('strUpdateText'))),
              const SizedBox(height: 10.0),
              name == null
                  ? const SizedBox(
                height: 0,
              )
                  : Text(
                name!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 30.0),
              ListTile(
                leading: const Icon(
                  Icons.favorite,
                  size: 25.0,
                ),
                title: Text(
                  context.tr('strWishlistProfile'),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18.0),
                ),
                trailing: const Icon(
                  Icons.keyboard_arrow_right,
                  size: 30.0,
                ),
                onTap: () async {
                  Loader.showLoadingScreen(context, _keyLoader);
                  List userList = await _userService.userWishlistData();
                  Loader.hideLoadingScreen(_keyLoader);
                  Navigator.popAndPushNamed(context, '/wishlist',
                      arguments: {'userList': userList});
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.local_shipping,
                  size: 25.0,
                ),
                title: Text(
                  context.tr('strOrderHistoryProfile'),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18.0),
                ),
                trailing: const Icon(
                  Icons.keyboard_arrow_right,
                  size: 30.0,
                ),
                onTap: () async {
                  Loader.showLoadingScreen(context, _keyLoader);
                  List orderData = await checkoutService.listPlacedOrder();
                  Loader.hideLoadingScreen(_keyLoader);
                  Navigator.popAndPushNamed(context, '/placedOrder',
                      arguments: {'data': orderData});
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.key,
                  size: 25.0,
                ),
                title: Text(
                  context.tr('strResetPassword'),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18.0),
                ),
                trailing: const Icon(
                  Icons.keyboard_arrow_right,
                  size: 30.0,
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/resetPassword');
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.message,
                  size: 25.0,
                ),
                title: Text(
                  context.tr('strNotiSetting'),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18.0),
                ),
                trailing: Switch(
                  value: _isSwitched,
                  onChanged: _toggleNoti,
                  activeColor: Colors.blue,
                  inactiveThumbColor: Colors.grey,
                ),
                onTap: () => _toggleNoti,
              ),
              ListTile(
                leading: const Icon(
                  Icons.dark_mode,
                  size: 25.0,
                ),
                title: Text(
                  context.tr('strDarkSetting'),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18.0),
                ),
                trailing: Switch(
                  value: _isDarkMode,
                  onChanged: _toggleDarkMode,
                  activeColor: Colors.blue,
                  inactiveThumbColor: Colors.grey,
                ),
                onTap: () => _toggleDarkMode,
              ),
              ListTile(
                leading: const Icon(
                  Icons.language,
                  size: 25.0,
                ),
                title: Text(
                  context.tr('strLangSetting'),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18.0),
                ),
                trailing: DropdownButton<String>(
                  value: _selectedLanguageValue,
                  onChanged: _toggleLanguageChange,
                  items: <String>['English', 'French']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18.0),
                      ),
                    );
                  }).toList(),
                ),
                onTap: () => _toggleLanguageChange,
              ),
              const SizedBox(height: 30.0),
              ElevatedButton(
                  child: Text(
                    context.tr('strLogout'),
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  onPressed: () {
                    _userService.logOut(context);
                  }),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}
