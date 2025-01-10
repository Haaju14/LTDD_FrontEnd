import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../fetch_api.dart';

class EditCategoryScreen extends StatefulWidget {
  final int categoryId; // categoryId không thể null
  final String initialCategoryName;

  // Constructor với việc đảm bảo categoryId không null
  EditCategoryScreen({
    Key? key,
    required this.categoryId,
    required this.initialCategoryName,
  }) : super(key: key);

  @override
  _EditCategoryScreenState createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  TextEditingController _categoryNameController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _categoryNameController.text = widget.initialCategoryName;
  }

  Future<void> saveCategory() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      try {
        if (widget.categoryId == 0) {
          // Nếu categoryId là 0, thêm mới danh mục
          await FetchApi.addCategory(_categoryNameController.text, token);
        } else {
          // Nếu categoryId != 0, sửa danh mục
          await FetchApi.editCategory(
              widget.categoryId, _categoryNameController.text, token);
        }
        Navigator.pop(context); // Quay lại màn hình danh mục
      } catch (e) {
        print('Error: $e');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      print('Không tìm thấy token.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.categoryId == 0 ? 'Thêm danh mục' : 'Chỉnh sửa danh mục'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  TextField(
                    controller: _categoryNameController,
                    decoration: InputDecoration(labelText: 'Tên danh mục'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: saveCategory,
                    child: Text(widget.categoryId == 0 ? 'Thêm' : 'Lưu'),
                  ),
                ],
              ),
      ),
    );
  }
}
