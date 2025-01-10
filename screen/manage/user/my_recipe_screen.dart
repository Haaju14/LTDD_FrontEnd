import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../fetch_api.dart';

class MyRecipesScreen extends StatefulWidget {
  const MyRecipesScreen({super.key});

  @override
  _MyRecipesScreenState createState() => _MyRecipesScreenState();
}

class _MyRecipesScreenState extends State<MyRecipesScreen> {
  late Future<List<dynamic>> _recipes;

  @override
  void initState() {
    super.initState();
    _recipes = _fetchMyRecipes();
  }

  // Lấy công thức của người dùng từ API
  Future<List<dynamic>> _fetchMyRecipes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Bạn cần đăng nhập để xem công thức');
    }

    try {
      final result = await FetchApi.getUserRecipes(token);
      return result['danhSachCongThuc']; 
    } catch (e) {
      throw Exception('Không thể tải công thức');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Công thức của tôi"),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _recipes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Bạn chưa chia sẻ công thức nào.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var recipe = snapshot.data![index];
                return ListTile(
                  leading: Image.network(recipe['HinhAnh']),
                  title: Text(recipe['TenCongThuc']),
                  subtitle: Text(recipe['MoTa']),
                  onTap: () {
                    Navigator.pushNamed(context, '/recipe-detail',
                        arguments: recipe['MaCongThuc']);
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
