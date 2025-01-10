import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../fetch_api.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<int>> favoritesList;

  @override
  void initState() {
    super.initState();
    favoritesList = _getFavorites(); // Lấy danh sách yêu thích
  }

  Future<List<int>> _getFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token'); // Lấy token từ SharedPreferences

    if (token == null || token.isEmpty) {
      print('Token không hợp lệ hoặc chưa có token');
      return []; // Nếu không có token, trả về danh sách trống
    }

    try {
      // Gọi API lấy danh sách yêu thích
      return await FetchApi.fetchFavorites();
    } catch (error) {
      print('Lỗi khi lấy danh sách yêu thích: $error');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách yêu thích'),
      ),
      body: FutureBuilder<List<int>>(
        future: favoritesList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Có lỗi xảy ra: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('Bạn chưa yêu thích công thức nào.'));
          } else {
            List<int> favoriteIds = snapshot.data!;
            // Hiển thị danh sách các công thức yêu thích
            return ListView.builder(
              itemCount: favoriteIds.length,
              itemBuilder: (context, index) {
                int recipeId = favoriteIds[index];
                return ListTile(
                  title: Text('Công thức #$recipeId'),
                  onTap: () {
                    // Mở màn hình chi tiết công thức khi nhấn vào một công thức yêu thích
                    Navigator.pushNamed(context, '/recipe-detail',
                        arguments: recipeId);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
