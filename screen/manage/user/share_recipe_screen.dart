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
  bool _isSubmitting = false; // Để theo dõi trạng thái gửi dữ liệu

  Future<void> _shareRecipe() async {
    if (!_formKey.currentState!.validate()) {
      return; // Không gửi nếu form không hợp lệ
    }

    setState(() {
      _isSubmitting = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token'); // Lấy token từ SharedPreferences

    if (token == null) {
      setState(() {
        _isSubmitting = false;
      });
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
    } finally {
      setState(() {
        _isSubmitting = false;
      });
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên công thức
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Tên công thức',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  onChanged: (value) => setState(() {
                    _recipeName = value;
                  }),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên công thức';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Mô tả
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Mô tả',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  onChanged: (value) => setState(() {
                    _description = value;
                  }),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mô tả';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Nguyên liệu
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nguyên liệu',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  onChanged: (value) => setState(() {
                    _ingredients = value;
                  }),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập nguyên liệu';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Cách làm
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Cách làm',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  onChanged: (value) => setState(() {
                    _instructions = value;
                  }),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập cách làm';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // URL hình ảnh
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'URL hình ảnh',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  onChanged: (value) => setState(() {
                    _imageUrl = value;
                  }),
                ),
                const SizedBox(height: 20),

                // Nút chia sẻ công thức
                _isSubmitting
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _shareRecipe,
                        child: const Text('Chia sẻ công thức'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
