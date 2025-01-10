// lib/utils/logout.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/sign_in_screen.dart';

class Logout {
  static Future<void> logOut(BuildContext context) async {
    // Xóa token khỏi SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    // Chuyển hướng về màn hình đăng nhập
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }
}
