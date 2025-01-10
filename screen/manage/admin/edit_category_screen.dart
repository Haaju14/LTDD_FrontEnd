import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../fetch_api.dart';

class EditCategoryScreen extends StatefulWidget {
  final int categoryId;
  final String initialCategoryName; // Nhận tên danh mục ban đầu

  EditCategoryScreen({super.key, required this.categoryId, required this.initialCategoryName});

  @override
  _EditCategoryScreenState createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  TextEditingController categoryNameController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Gán tên danh mục ban đầu vào controller
    categoryNameController.text = widget.initialCategoryName;
  }

  // Cập nhật tên danh mục
  Future<void> saveCategory() async {
    if (categoryNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập tên danh mục')),
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

      // Gọi API để cập nhật danh mục
      await FetchApi.editCategory(widget.categoryId, categoryNameController.text, token);

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chỉnh sửa danh mục')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: categoryNameController,
              decoration: InputDecoration(labelText: 'Tên danh mục'),
            ),
            SizedBox(height: 20),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: saveCategory,
                    child: Text('Cập nhật'),
                  ),
          ],
        ),
      ),
    );
  }
}
