import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../fetch_api.dart';

class RecipeDetailScreen extends StatefulWidget {
  final int recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late Map<String, dynamic> recipeDetails;

  @override
  void initState() {
    super.initState();
    recipeDetails = {}; // Initialize as an empty map
    _fetchRecipeDetails();
  }

  // Lấy chi tiết công thức từ API
  Future<void> _fetchRecipeDetails() async {
    try {
      // Lấy token từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      // Kiểm tra nếu không có token
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Token không hợp lệ, vui lòng đăng nhập.')),
        );
        return;
      }

      // Gọi API với cả recipeId và token
      final details = await FetchApi.fetchRecipeDetails(widget.recipeId, token);

      // Log the response to debug
      print('Recipe Details: $details'); // Add this line for debugging

      // Check if response contains valid data
      if (details.containsKey('congThuc')) {
        setState(() {
          recipeDetails = details['congThuc']; // Lấy thông tin công thức
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không tìm thấy công thức.')),
        );
      }
    } catch (e) {
      if (e.toString().contains('Token không hợp lệ')) {
        // Chuyển hướng về màn hình đăng nhập nếu token không hợp lệ
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('token'); // Xóa token
        Navigator.pushReplacementNamed(context, '/sign-in');
      } else {
        print("Lỗi khi lấy chi tiết công thức: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Có lỗi xảy ra khi tải công thức.')),
        );
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
                    recipeDetails['TenCongThuc'] ?? 'Không có tên công thức',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  recipeDetails['HinhAnh'] != null
                      ? Image.network(recipeDetails['HinhAnh'])
                      : Placeholder(
                          fallbackHeight: 200, fallbackWidth: double.infinity),
                  SizedBox(height: 10),
                  Text(
                    'Mô Tả: ${recipeDetails['MoTa'] ?? 'Không có mô tả'}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Nguyên Liệu: ${recipeDetails['NguyenLieu'] ?? 'Không có nguyên liệu'}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Cách Làm: ${recipeDetails['CachLam'] ?? 'Không có cách làm'}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Thời Gian Nấu: ${recipeDetails['ThoiGianNau'] ?? 'Không có thời gian nấu'} phút',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
    );
  }
}
