import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../fetch_api.dart';
import '../manage/user/home_screen.dart';
import '../manage/admin/manage_screen.dart';
import 'sign_up_screen.dart';
import 'forgot_password_screen.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Hàm đăng nhập
  Future<void> signIn() async {
    try {
      final data = await FetchApi.signIn(
        emailController.text,
        passwordController.text,
      );

      if (data['content'] != null && data['content']['token'] != null) {
        String token = data['content']['token'];
        var user = data['content']['user'];

        // Lưu token và thông tin người dùng vào SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('userName', user['TenNguoiDung']);
        await prefs.setString('userEmail', user['Email']);
        await prefs.setString('userRole', user['VaiTro']);
        await prefs.setInt('userId', user['MaNguoiDung']);

        print("Token đăng nhập: $token");

        // Điều hướng dựa trên vai trò
        String role = user['VaiTro'];
        if (role == 'Admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ManageScreen()), 
          );
        } else if (role == 'User') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomeScreen()), 
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Vai trò không xác định")),
          );
        }
      } else {
        // Nếu không có token trong response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: Không có token")),
        );
      }
    } catch (e) {
      // Nếu có lỗi xảy ra trong quá trình đăng nhập
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đăng Nhập')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Form đăng nhập
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !value.contains('@')) {
                        return 'Vui lòng nhập email hợp lệ';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: 'Mật khẩu'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        signIn();
                      }
                    },
                    child: Text('Đăng Nhập'),
                  ),
                ],
              ),
            ),
            // Đường link đăng ký và quên mật khẩu
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()),
                    );
                  },
                  child: Text('Đăng ký'),
                ),
                SizedBox(width: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ForgotPasswordScreen()),
                    );
                  },
                  child: Text('Quên mật khẩu'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
