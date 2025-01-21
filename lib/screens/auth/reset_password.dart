import 'package:e_commerce_app/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/size_config.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() {
    return _ResetPasswordScreenState();
  }
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _form = GlobalKey<FormState>();

  var _enteredConfirmPassword = '';
  var _enteredNewPassword = '';

  void _resetPassword() async {
    final isValid = _form.currentState!.validate();

    if (!isValid) {
      return;
    }

    _form.currentState!.save();
    if (_enteredConfirmPassword.trim() != _enteredNewPassword.trim()) {
      _showSnackBarMessage('New password must match with confirm password.');
      return;
    }
    try {
      UserService userService = UserService();
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No user signed in');
        _showSnackBarMessage("User session expired. Please re-login");
        userService.logOut(context);
        return;
      }
      await user.updatePassword(_enteredNewPassword.trim()).then((val) {
        _showSnackBarMessage(
            "Password updated successfully. Please login again!");
        userService.logOut(context);
      }).catchError((err2) {
        _showSnackBarMessage("Something went wrong while updating password.");
      });
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        _showSnackBarMessage("Email already in use");
      } else {
        _showSnackBarMessage(error.message);
      }
    }
  }

  void _showSnackBarMessage(String? errorMessage) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage ?? 'Authentication failed.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Reset Password",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: SizeConfig.safeBlockHorizontal * 5,
            )),
        backgroundColor: Colors.white,
        elevation: 1.0,
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            margin: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _form,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration:
                        const InputDecoration(labelText: 'Old Password'),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.trim().length < 6) {
                            return 'Password must be at least 6 characters long.';
                          }
                          return null;
                        },
                        onSaved: (value) {},
                      ),
                      TextFormField(
                        decoration:
                        const InputDecoration(labelText: 'New Password'),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.trim().length < 6) {
                            return 'Password must be at least 6 characters long.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _enteredNewPassword = value!;
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Confirm Password'),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.trim().length < 6) {
                            return 'Password must be at least 6 characters long.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _enteredConfirmPassword = value!;
                        },
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _resetPassword,
                        child: const Text(
                          'Reset Password',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
