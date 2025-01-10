import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../fetch_api.dart';
import 'edit_category_screen.dart';

class ManageCategoriesScreen extends StatefulWidget {
  @override
  _ManageCategoriesScreenState createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  List<dynamic> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  // Lấy danh sách danh mục
  Future<void> fetchCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      try {
        var categoryList = await FetchApi.getAllCategories(token);
        setState(() {
          categories = categoryList;
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print('Error: $e');
      }
    } else {
      print('Không tìm thấy token.');
    }
  }

  // Xóa danh mục
  Future<void> deleteCategory(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      try {
        await FetchApi.deleteCategory(id, token);
        fetchCategories(); // Lấy lại danh sách sau khi xóa
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                var category = categories[index];
                return ListTile(
                  title: Text(category['TenDanhMuc']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // Truyền id hợp lệ, đảm bảo không null
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditCategoryScreen(
                                categoryId: category['id'] ??
                                    0, // Truyền id hợp lệ (nếu null thì 0)
                                initialCategoryName: category['TenDanhMuc'],
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          deleteCategory(category['id'] ??
                              0); // Truyền id hợp lệ (nếu null thì 0)
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Thêm danh mục mới
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditCategoryScreen(
                categoryId: 0, // Truyền 0 để thêm mới
                initialCategoryName: '',
              ),
            ),
          );
        },
      ),
    );
  }
}
