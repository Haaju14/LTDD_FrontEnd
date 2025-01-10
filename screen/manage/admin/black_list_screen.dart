import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../fetch_api.dart';

class BlacklistScreen extends StatefulWidget {
  const BlacklistScreen({super.key});

  @override
  _BlacklistScreenState createState() => _BlacklistScreenState();
}

class _BlacklistScreenState extends State<BlacklistScreen> {
  bool isLoading = true;
  List<dynamic> blacklistItems = [];

  // Tạo đối tượng của lớp Fetch
  final FetchApi fetch = FetchApi();

  // Lấy token từ SharedPreferences
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Gọi phương thức fetchBlacklist từ đối tượng Fetch
  Future<void> fetchBlacklist() async {
    try {
      String? token = await getToken(); // Lấy token từ SharedPreferences
      if (token == null) {
        throw Exception('Không tìm thấy token');
      }

      final data =
          await fetch.fetchBlacklist(); // Gọi fetchBlacklist từ đối tượng fetch
      setState(() {
        blacklistItems = data;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi xảy ra khi lấy dữ liệu: $error')),
      );
    }
  }

  // Phương thức xóa công thức khỏi danh sách đen
  Future<void> deleteBlacklistItem(String maBlackList) async {
    try {
      // Lấy token từ SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token'); // Token đã lưu từ lần đăng nhập

      if (token == null) {
        throw Exception('Không tìm thấy token');
      }

      // Gọi phương thức xóa công thức qua API
      await FetchApi.deleteBlacklistItem(maBlackList, token);

      setState(() {
        // Sau khi xóa thành công, loại bỏ công thức khỏi danh sách
        blacklistItems
            .removeWhere((item) => item['MaBlackList'] == maBlackList);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Công thức đã được xóa khỏi danh sách đen')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi xảy ra khi xóa công thức: $error')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBlacklist(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh Sách Đen'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Hiển thị khi đang tải
          : blacklistItems.isEmpty
              ? const Center(
                  child: Text('Không có công thức nào trong danh sách đen'))
              : ListView.builder(
                  itemCount: blacklistItems.length,
                  itemBuilder: (context, index) {
                    final item = blacklistItems[index];
                    return ListTile(
                      title:
                          Text(item['TenCongThuc'] ?? 'Công thức không có tên'),
                      subtitle: Text(item['MoTa'] ?? 'Không có mô tả'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          if (item['MaBlackList'] != null) {
                            deleteBlacklistItem(item['MaBlackList']);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Mã blacklist không hợp lệ!')),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
