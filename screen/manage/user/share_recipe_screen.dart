import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../fetch_api.dart';

class ShareRecipeScreen extends StatefulWidget {
  const ShareRecipeScreen({super.key});

  @override
  _ShareRecipeScreenState createState() => _ShareRecipeScreenState();
}

class _ShareRecipeScreenState extends State<ShareRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  String _recipeName = '';
  String _description = '';
  String _ingredients = '';
  String _instructions = '';
  String _imageUrl = '';
  int _categoryId = 1; // Ví dụ: bạn có thể thay đổi danh mục nếu cần

  Future<void> _shareRecipe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token'); // Lấy token từ SharedPreferences

    if (token == null) {
      // Xử lý nếu token không có (người dùng chưa đăng nhập)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn cần đăng nhập để chia sẻ công thức')),
      );
      return;
    }

    try {
      final result = await FetchApi.addRecipe(
        _recipeName,
        _imageUrl,
        _description,
        45, // Thời gian nấu (bạn có thể lấy từ form nếu có)
        _ingredients,
        _instructions,
        _categoryId,
        token,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(result['message'] ?? 'Chia sẻ công thức thành công')),
      );
      Navigator.pop(context); // Quay lại màn hình trước
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xảy ra lỗi khi chia sẻ công thức')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chia sẻ công thức món ăn"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Tên công thức'),
                onChanged: (value) => setState(() {
                  _recipeName = value;
                }),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Mô tả'),
                onChanged: (value) => setState(() {
                  _description = value;
                }),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nguyên liệu'),
                onChanged: (value) => setState(() {
                  _ingredients = value;
                }),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Cách làm'),
                onChanged: (value) => setState(() {
                  _instructions = value;
                }),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'URL hình ảnh'),
                onChanged: (value) => setState(() {
                  _imageUrl = value;
                }),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _shareRecipe,
                child: const Text('Chia sẻ công thức'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
