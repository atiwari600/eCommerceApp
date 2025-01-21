import 'dart:collection';

import 'package:e_commerce_app/services/user_service.dart';
import 'package:flutter/material.dart';

import '../../components/loader.dart';
import '../../core/size_config.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() {
    return _SignUpScreenState();
  }
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _form = GlobalKey<FormState>();
  final _userService = UserService();
  HashMap userValues = HashMap<String, String>();
  final GlobalKey<State> _keyLoader = GlobalKey<State>();

  void _submit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid) {
      return;
    }

    _form.currentState!.save();
    Loader.showLoadingScreen(context, _keyLoader);
    await _userService.signup(userValues);
    Loader.hideLoadingScreen(_keyLoader);
    int statusCode = _userService.statusCode;
    if (statusCode == 400) {
      UserService.showSnackBarMessage(context, _userService.msg);
    } else {
      Navigator.pushReplacementNamed(context, '/');
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
                          const InputDecoration(labelText: 'Full Name'),
                          keyboardType: TextInputType.text,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                !value.contains(' ')) {
                              return 'Please enter a valid fullname.';
                            }

                            return null;
                          },
                          onSaved: (value) {
                            userValues['fullName'] = value!;
                          },
                        ),
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                          ),
                          child: const Text(
                            'Signup',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.popAndPushNamed(context, '/login');
                          },
                          child: const Text('I already have an account'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
