import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import '../../auth/log_out.dart';

Future<void> showProfileMenu(BuildContext context) async {
  
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? role = prefs.getString('role'); 

  
  if (role == null) {
    role = 'User'; 
  }

  // Hiển thị Modal Bottom Sheet
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mục xem thông tin cá nhân
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Xem thông tin cá nhân'),
            onTap: () {
              Navigator.pushNamed(context, '/user');
            },
          ),
          // Nếu là Admin, hiển thị mục quản lý
          if (role == 'Admin') 
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Quản lý'),
              onTap: () {
                Navigator.pushNamed(context, '/manage');
              },
            ),
          // Mục Trang chủ cho cả Admin và User
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Trang chủ'),
            onTap: () {
              Navigator.pushNamed(context, '/home'); 
            },
          ),
          // Mục Đăng xuất
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Đăng xuất'),
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
