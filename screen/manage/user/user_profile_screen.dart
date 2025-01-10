import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Thư viện SharedPreferences
import '../../../fetch_api.dart';
import 'dart:async';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  String userRole = ""; // Biến lưu role của người dùng
  bool isLoading = false;

  Future<void> fetchUserProfile() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Lấy token từ SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception("Không tìm thấy token");
      }

      // Gọi API để lấy thông tin người dùng
      final userData = await FetchApi.fetchUserProfile(token);
      final userInfo = userData['nguoiDung'];

      setState(() {
        nameController.text = userInfo['TenNguoiDung'] ?? '';
        emailController.text = userInfo['Email'] ?? '';
        userRole = userInfo['role'] ?? ''; // Lưu role của người dùng
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi tải thông tin cá nhân: $error")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateUserProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Lấy token từ SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception("Không tìm thấy token");
      }

      // Gọi API để cập nhật thông tin
      await FetchApi.updateUserProfile(
        token: token,
        name: nameController.text,
        email: emailController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cập nhật thông tin thành công")),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi cập nhật thông tin: $error")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thông Tin Cá Nhân"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration:
                              InputDecoration(labelText: "Tên người dùng"),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Tên không được để trống";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(labelText: "Email"),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                !value.contains('@')) {
                              return "Email không hợp lệ";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: updateUserProfile,
                          child: Text("Cập Nhật"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
