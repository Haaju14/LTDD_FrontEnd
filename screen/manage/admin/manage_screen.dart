import 'package:flutter/material.dart';
import '../user/profile_menu.dart';
import 'black_list_screen.dart';
import 'manage_categories_screen.dart';
import 'manage_recipes_screen.dart';
import 'manage_user_screen.dart';

class ManageScreen extends StatefulWidget {
  const ManageScreen({super.key});

  @override
  _ManageScreenState createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Số lượng tab, đã thêm tab blacklist
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Trang Quản Lý'),
          actions: [
            // Avatar góc phải
            IconButton(
              icon: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              onPressed: () {
                // Gọi hàm showProfileMenu từ file riêng
                showProfileMenu(context);
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.person), text: 'Người Dùng'),
              Tab(icon: Icon(Icons.post_add), text: 'Kiểm Duyệt'),
              Tab(icon: Icon(Icons.category), text: 'Danh Mục'),
              Tab(icon: Icon(Icons.block), text: 'Danh Sách Đen'), // Thêm tab blacklist
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ManageUsersScreen(),
            ManageRecipesScreen(),
            ManageCategoriesScreen(),
            BlacklistScreen(), 
          ],
        ),
      ),
    );
  }
}
