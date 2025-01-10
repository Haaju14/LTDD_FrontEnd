// lib/screens/manage/manage_screen.dart
import 'package:flutter/material.dart';
import '../../auth/log_out.dart';
import 'manage_categories_screen.dart';
import 'manage_recipes_screen.dart';
import 'manage_user_screen.dart'; // Thêm import màn hình đăng nhập

class ManageScreen extends StatefulWidget {
  const ManageScreen({super.key});

  @override
  _ManageScreenState createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Số lượng tab
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Trang Quản Lý'),
          actions: [
            // Avatar góc phải
            IconButton(
              icon: CircleAvatar(
                child: Icon(Icons.person),
              ),
              onPressed: () {
                // Tạo menu khi nhấn avatar
                _showProfileMenu(context);
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.person), text: 'Người Dùng'),
              Tab(icon: Icon(Icons.post_add), text: 'Kiểm Duyệt'),
              Tab(icon: Icon(Icons.category), text: 'Danh Mục'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ManageUsersScreen(),
            ManageRecipesScreen(),
            ManageCategoriesScreen(), 
          ],
        ),
      ),
    );
  }

  // Hàm hiển thị menu profile với các tùy chọn
  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Xem thông tin cá nhân'),
              onTap: () {
                // Chuyển hướng tới màn hình thông tin cá nhân
                Navigator.pushNamed(context, '/user');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Đăng xuất'),
              onTap: () async {
                // Gọi hàm đăng xuất từ class Logout
                await Logout.logOut(context);
              },
            ),
          ],
        );
      },
    );
  }
}
