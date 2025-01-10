import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../fetch_api.dart';

class ManageRecipesScreen extends StatefulWidget {
  @override
  _ManageRecipesScreenState createState() => _ManageRecipesScreenState();
}

class _ManageRecipesScreenState extends State<ManageRecipesScreen> {
  List<dynamic> recipesForApproval = [];
  bool isLoading = true;

  // Lấy danh sách công thức cần kiểm duyệt
  Future<void> fetchRecipes() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Không tìm thấy token');
      }

      final data = await FetchApi.getRecipesForApproval(token);
      setState(() {
        recipesForApproval = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    }
  }

  // Hiển thị hộp thoại chọn trạng thái duyệt công thức
  Future<void> showApprovalDialog(int approvalId) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Chọn trạng thái duyệt"),
          content: Text("Bạn muốn duyệt hay từ chối công thức này?"),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Đóng hộp thoại
                await approveRecipe(approvalId, "Duyet"); // Duyệt công thức
              },
              child: Text("Duyệt"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Đóng hộp thoại
                await approveRecipe(approvalId, "KhongDuyet"); // Từ chối công thức
              },
              child: Text("Không Duyệt"),
            ),
          ],
        );
      },
    );
  }

  // Duyệt công thức với trạng thái
  Future<void> approveRecipe(int approvalId, String status) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Không tìm thấy token');
      }

      // Gọi API để duyệt công thức với trạng thái
      await FetchApi.approveRecipe(approvalId, status, "", token); // Không cần lý do

      // Thông báo duyệt thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Công thức đã được duyệt thành công!')),
      );

      // Cập nhật lại danh sách công thức cần kiểm duyệt
      fetchRecipes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    }
  }

  // Xóa công thức
  Future<void> deleteRecipe(int approvalId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Không tìm thấy token');
      }

      // Gọi API để xóa công thức
      await FetchApi.deleteRecipe(approvalId, token);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Công thức đã bị xóa!')));

      // Cập nhật lại danh sách công thức
      fetchRecipes();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: recipesForApproval.length,
              itemBuilder: (context, index) {
                final recipe = recipesForApproval[index];
                return ListTile(
                  title: Text(recipe['TenCongThuc']),
                  subtitle: Text('Mô tả: ${recipe['MoTa']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: () {
                          // Mở hộp thoại chọn duyệt hoặc không duyệt
                          showApprovalDialog(recipe['MaKiemDuyet']);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // Cảnh báo trước khi xóa
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Xóa công thức'),
                                content: Text(
                                    'Bạn có chắc chắn muốn xóa công thức này không?'),
                                actions: [
                                  TextButton(
                                    child: Text('Hủy'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: Text('Xóa'),
                                    onPressed: () {
                                      deleteRecipe(recipe['MaKiemDuyet']);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
