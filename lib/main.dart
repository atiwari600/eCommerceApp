import 'package:e_commerce_app/screens/auth/login.dart';
import 'package:e_commerce_app/screens/auth/sign_up.dart';
import 'package:e_commerce_app/screens/checkout/add_credit_card.dart';
import 'package:e_commerce_app/screens/checkout/payment_method.dart';
import 'package:e_commerce_app/screens/checkout/place_order.dart';
import 'package:e_commerce_app/screens/checkout/shipping_address.dart';
import 'package:e_commerce_app/screens/home_screen.dart';
import 'package:e_commerce_app/screens/order_history.dart';
import 'package:e_commerce_app/screens/auth/reset_password.dart';
import 'package:e_commerce_app/screens/shopping_cart.dart';
import 'package:e_commerce_app/screens/start_screen.dart';
import 'package:e_commerce_app/screens/user_profile.dart';
import 'package:e_commerce_app/screens/wishlist_screen.dart';
import 'package:e_commerce_app/services/local_notifications_service.dart';
import 'package:e_commerce_app/services/user_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization_multi/easy_localization_multi.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

var kColorScheme = ColorScheme.fromSeed(
  seedColor: Colors.blue,
  brightness: Brightness.light,
);

var kDarkColorScheme =
    ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.dark);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  LocalNotificationsService.initializeNotifications();
  await EasyLocalization.ensureInitialized();
  runApp(EasyLocalization(
    assetLoader: const MultiAssetLoader([RootBundleAssetLoader()]),
    fallbackLocale: const Locale('en', 'US'),
    path: 'assets/translations',
    startLocale: const Locale('en', 'US'),
    supportedLocales: const [
      Locale('en', 'US'),
      Locale('fr', 'FR'),
    ],
    child: const App(),
  ));
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AppState();
  }

  static _AppState of(BuildContext context) =>
      context.findAncestorStateOfType<_AppState>()!;
}

class _AppState extends State<App> {
  ThemeMode _themeMode = ThemeMode.system;
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    loadLanguage();
    loadTheme();
  }

  Future<void> loadLanguage() async {
    String languageCode = await UserService().loadLanguageSettingState();
    _locale = (languageCode == "fr")
        ? const Locale('fr', 'FR')
        : const Locale('en', 'US');
  }

  Future<void> loadTheme() async {
    bool isDarkTheme = await UserService().loadThemeSettingState();
    _themeMode = isDarkTheme ? ThemeMode.dark : ThemeMode.light;
  }

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  void changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterChat',
      theme: ThemeData(colorScheme: kColorScheme),
      darkTheme: ThemeData(colorScheme: kDarkColorScheme),
      themeMode: _themeMode,
      locale: _locale,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      initialRoute: '/',
      routes: {
        "/": (context) => StartScreen(),
        "/login": (context) => const LoginScreen(),
        "/signup": (context) => const SignUpScreen(),
        "/home": (context) => const HomeScreen(),
        "/wishlist": (context) => const WishListScreen(),
        '/profile': (context) => const UserProfile(),
        '/bag': (context) => const ShoppingCartScreen(),
        '/resetPassword': (context) => const ResetPasswordScreen(),
        '/placedOrder': (context) => const OrderHistory(),
        '/checkout/addCreditCard': (context) => const AddCreditCard(),
        '/checkout/address': (context) => const ShippingAddress(),
        '/checkout/paymentMethod': (context) => const PaymentMethod(),
        '/checkout/placeOrder': (context) => const PlaceOrder(),
      },
    );
  }
}
