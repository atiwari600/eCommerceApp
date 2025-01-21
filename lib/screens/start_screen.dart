import 'package:e_commerce_app/core/size_config.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/user_service.dart';

class StartScreen extends StatelessWidget {
  final UserService _userService = UserService();

  StartScreen({super.key});

  validateToken(context) async {
    const storage = FlutterSecureStorage();
    String? value = await storage.read(key: 'idToken');
    if (value != null) {
      String? decodedToken = _userService.validateToken(value);
      print(decodedToken);
      if (decodedToken != null) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/e-commerce-logo.png',
                width: SizeConfig.screenWidth - 100,
              ),
              const SizedBox(
                height: 30,
              ),
              Text(context.tr('tagLine'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  )),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(context.tr('subText'),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                child: Text(context.tr('strLogin'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                onPressed: () {
                  validateToken(context);
                },
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                child: Text(context.tr('strSignUp'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
