import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../fetch_api.dart';

class RecipeDetailScreen extends StatefulWidget {
  final int maCongThuc; // ID của công thức

  RecipeDetailScreen({required this.maCongThuc});

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  double rating = 0.0; // Sao đánh giá
  String comment = ''; // Bình luận
  bool isSubmitting = false;

  // Lấy thông tin người dùng từ SharedPreferences
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Gửi đánh giá công thức
  Future<void> _submitRating() async {
    setState(() {
      isSubmitting = true;
    });

    try {
      String? token = await _getToken();
      if (token == null) {
        throw Exception('Không tìm thấy token');
      }

      final response =
          await FetchApi.addRating(widget.maCongThuc, rating, comment, token);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(response['message'] ?? 'Thêm đánh giá thành công!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết công thức'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Công thức chi tiết có thể hiển thị ở đây
            // ví dụ: Text('Tên công thức: ...')

            // Phần đánh giá
            Text('Đánh giá của bạn:', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            // Rating
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      rating = index + 1.0;
                    });
                  },
                );
              }),
            ),
            SizedBox(height: 10),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Bình luận',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  comment = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isSubmitting ? null : _submitRating,
              child: isSubmitting
                  ? CircularProgressIndicator()
                  : Text('Gửi đánh giá'),
            ),
          ],
        ),
      ),
    );
  }
}
