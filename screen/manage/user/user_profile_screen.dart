import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../fetch_api.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  String userRole = "";
  bool isLoading = false;
  bool showChangePassword = false;

  // Fetch thông tin người dùng
  Future<void> fetchUserProfile() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception("Không tìm thấy token");
      }

      final userData = await FetchApi.fetchUserProfile(token);
      final userInfo = userData['nguoiDung'];

      setState(() {
        nameController.text = userInfo['TenNguoiDung'] ?? '';
        emailController.text = userInfo['Email'] ?? '';
        userRole = userInfo['role'] ?? '';
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

  // Cập nhật thông tin người dùng
  Future<void> updateUserProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception("Không tìm thấy token");
      }

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

  // Đổi mật khẩu
  Future<void> changePassword() async {
    if (newPasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Mật khẩu mới và xác nhận không khớp")),
      );
      return;
    }

    if (oldPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng điền đầy đủ thông tin")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception("Không tìm thấy token");
      }

      await FetchApi.changePassword(
        oldPasswordController.text,
        newPasswordController.text,
        token,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đổi mật khẩu thành công")),
      );

      setState(() {
        showChangePassword = false;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi đổi mật khẩu: $error")),
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
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: "Tên người dùng",
                                prefixIcon: Icon(Icons.person),
                              ),
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
                              decoration: InputDecoration(
                                labelText: "Email",
                                prefixIcon: Icon(Icons.email),
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    !value.contains('@')) {
                                  return "Email không hợp lệ";
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: updateUserProfile,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.blueAccent,
                        textStyle: TextStyle(fontSize: 16),
                      ),
                      child: Text("Cập Nhật Thông Tin"),
                    ),
                    Divider(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showChangePassword = !showChangePassword;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.orange,
                        textStyle: TextStyle(fontSize: 16),
                      ),
                      child: Text(showChangePassword
                          ? "Ẩn Đổi Mật Khẩu"
                          : "Đổi Mật Khẩu"),
                    ),
                    if (showChangePassword)
                      Column(
                        children: [
                          SizedBox(height: 16),
                          TextField(
                            controller: oldPasswordController,
                            decoration: InputDecoration(
                              labelText: "Mật khẩu cũ",
                              prefixIcon: Icon(Icons.lock),
                            ),
                            obscureText: true,
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: newPasswordController,
                            decoration: InputDecoration(
                              labelText: "Mật khẩu mới",
                              prefixIcon: Icon(Icons.lock),
                            ),
                            obscureText: true,
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: confirmPasswordController,
                            decoration: InputDecoration(
                              labelText: "Xác nhận mật khẩu mới",
                              prefixIcon: Icon(Icons.lock),
                            ),
                            obscureText: true,
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: changePassword,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.green,
                              textStyle: TextStyle(fontSize: 16),
                            ),
                            child: Text("Xác Nhận Đổi Mật Khẩu"),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
