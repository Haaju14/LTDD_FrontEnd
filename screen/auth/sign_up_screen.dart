import 'dart:async'; // Đảm bảo bạn đã import thư viện này
import 'package:flutter/material.dart';
import '../../fetch_api.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String countdownMessage = ''; // Biến lưu trữ thông báo đếm ngược

  Future<void> handleSignUp() async {
    final result = await FetchApi.signUp(
      name: nameController.text,
      email: emailController.text,
      password: passwordController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'])),
    );

    if (result['success']) {
      // Hiển thị thông báo đăng ký thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đăng ký thành công! ")),
      );

      // Bắt đầu đếm ngược 3 giây
      int countdown = 3;
      setState(() {
        countdownMessage = "Đang chuẩn bị chuyển sang trang đăng nhập... $countdown";
      });

      // Cập nhật thông báo đếm ngược mỗi giây
      Timer.periodic(Duration(seconds: 1), (timer) {
        if (countdown > 0) {
          setState(() {
            countdown--;
            countdownMessage = "Đang chuẩn bị chuyển sang trang đăng nhập... $countdown";
          });
        } else {
          timer.cancel();
          // Sau khi đếm ngược xong, chuyển hướng tới trang đăng nhập
          Navigator.pushReplacementNamed(context, '/sign-in');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đăng ký')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Tên người dùng'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
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
                    handleSignUp();
                  }
                },
                child: Text('Đăng ký'),
              ),
              // Hiển thị thông báo đếm ngược dưới nút đăng ký
              if (countdownMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(countdownMessage),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
