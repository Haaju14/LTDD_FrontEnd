import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../fetch_api.dart';

class RecipeDetailScreen extends StatefulWidget {
  final int recipeId; // ID công thức

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late Map<String, dynamic> recipeDetails;

  @override
  void initState() {
    super.initState();
    _fetchRecipeDetails();
  }

  // Lấy chi tiết công thức từ API
  Future<void> _fetchRecipeDetails() async {
    try {
      final details = await FetchApi.fetchRecipeDetails(widget.recipeId);
      setState(() {
        recipeDetails = details['congThuc']; // Lấy thông tin công thức
      });
    } catch (e) {
      if (e.toString().contains('Token không hợp lệ')) {
        // Chuyển hướng về màn hình đăng nhập nếu token không tồn tại
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('token'); // Xóa token
        Navigator.pushReplacementNamed(context, '/sign-in');
      } else {
        print("Lỗi khi lấy chi tiết công thức: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chi Tiết Công Thức')),
      body: recipeDetails.isEmpty
          ? Center(
              child:
                  CircularProgressIndicator()) // Hiển thị loading nếu chưa có dữ liệu
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipeDetails['TenCongThuc'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Image.network(recipeDetails['HinhAnh']),
                  SizedBox(height: 10),
                  Text(
                    'Mô Tả: ${recipeDetails['MoTa']}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Nguyên Liệu: ${recipeDetails['NguyenLieu']}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Cách Làm: ${recipeDetails['CachLam']}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Thời Gian Nấu: ${recipeDetails['ThoiGianNau']} phút',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
    );
  }
}
