import 'dart:collection';
import 'package:e_commerce_app/services/user_service.dart';
import 'package:flutter/material.dart';

import '../../components/loader.dart';
import '../../core/size_config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final GlobalKey<State> _keyLoader = GlobalKey<State>();
  final _userService = UserService();
  HashMap userValues = HashMap<String, String>();

  void _submit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid) {
      return;
    }

    _form.currentState!.save();

    Loader.showLoadingScreen(context, _keyLoader);
    await _userService.login(userValues);
    Loader.hideLoadingScreen(_keyLoader);
    int statusCode = _userService.statusCode;
    if (statusCode == 200) {
      Navigator.popAndPushNamed(context, '/home');
    } else {
      UserService.showSnackBarMessage(context, _userService.msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Center(
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
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              margin: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _form,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Email Address'),
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        textCapitalization: TextCapitalization.none,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty ||
                              !value.contains('@')) {
                            return 'Please enter a valid email address.';
                          }

                          return null;
                        },
                        onSaved: (value) {
                          userValues['email'] = value!;
                        },
                      ),
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.trim().length < 6) {
                            return 'Password must be at least 6 characters long.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          userValues['password'] = value!;
                        },
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _submit,
                        child: const Text("Login",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/signup');
                        },
                        child: const Text('Create an account'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
