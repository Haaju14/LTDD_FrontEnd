import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screen/auth/sign_in_screen.dart';
import 'screen/auth/sign_up_screen.dart';
import 'screen/auth/forgot_password_screen.dart';
import 'screen/manage/admin/black_list_screen.dart';
import 'screen/manage/admin/edit_category_screen.dart';
import 'screen/manage/admin/manage_categories_screen.dart';
import 'screen/manage/admin/manage_screen.dart';
import 'screen/manage/user/home_screen.dart';
import 'screen/manage/user/user_profile_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Kiểm tra trạng thái đăng nhập của người dùng
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token'); // Lấy token từ SharedPreferences

  runApp(MyApp(isAuthenticated: token != null && token.isNotEmpty)); // Kiểm tra nếu token không null và không rỗng
}

class MyApp extends StatelessWidget {
  final bool isAuthenticated;

  // Constructor nhận trạng thái đăng nhập
  const MyApp({super.key, required this.isAuthenticated});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Recipe App',
      theme: ThemeData(primarySwatch: Colors.blue),
      
      // Kiểm tra trạng thái đăng nhập của người dùng
      home: isAuthenticated ? const HomeScreen() : SignInScreen(),
      routes: {
        '/sign-up': (context) => SignUpScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/user-profile': (context) => UserProfileScreen(),
        '/home': (context) => const HomeScreen(),
        '/manage': (context) => const ManageScreen(),
        '/user': (context) => UserProfileScreen(),
        '/sign-in': (context) => SignInScreen(),  
        '/edit_category': (context) => ManageCategoriesScreen (),  
        '/blacklist': (context) => BlacklistScreen(),
      },
    );
  }
}
