import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../fetch_api.dart';

class EditUserScreen extends StatefulWidget {
  final int userId;

  EditUserScreen({super.key, required this.userId});

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  String? role;
  bool isLoading = false;

  // Lấy thông tin người dùng theo userId
  Future<void> fetchUserDetails() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      try {
        // Gọi API và lưu dữ liệu vào biến user
        final Map<String, dynamic> user =
            await FetchApi.getUserById(widget.userId.toString(), token);

        setState(() {
          nameController.text = user['TenNguoiDung'] ?? '';
          emailController.text = user['Email'] ?? '';

          // Kiểm tra vai trò hợp lệ
          final fetchedRole = user['VaiTro'];
          role = ['admin', 'user'].contains(fetchedRole) ? fetchedRole : null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Lỗi khi tải thông tin người dùng: ${e.toString()}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Không tìm thấy token. Vui lòng đăng nhập lại.')),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  // Cập nhật thông tin người dùng
  Future<void> updateUser() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        role == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) throw Exception('Không tìm thấy token');

      await FetchApi.updateUser(
        widget.userId.toString(),
        {
          'TenNguoiDung': nameController.text,
          'Email': emailController.text,
          'VaiTro': role,
        },
        token,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật thành công!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
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
    fetchUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chỉnh sửa thông tin người dùng')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Tên người dùng'),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16),
                  DropdownButton<String>(
                    value: ['Admin', 'User'].contains(role) ? role : null,
                    hint: Text('Chọn vai trò'),
                    isExpanded: true,
                    items: ['Admin', 'User'].map((role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        role = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: updateUser,
                    child: Text('Cập nhật'),
                  ),
                ],
              ),
            ),
    );
  }
}
