import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart'; // Import đúng thư viện
import 'package:shared_preferences/shared_preferences.dart';
import '../../../fetch_api.dart';
import '../../auth/sign_in_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<dynamic> foodList = []; // Danh sách món ăn
  late List<int> favoriteIds = []; // Danh sách các MaCongThuc đã yêu thích

  @override
  void initState() {
    super.initState();
    _fetchRecipes(); // Lấy công thức từ API
    _fetchFavorites(); // Lấy danh sách công thức yêu thích của người dùng
  }

  // Gọi API để lấy danh sách công thức món ăn
  Future<void> _fetchRecipes() async {
    List<dynamic> recipes = await FetchApi.fetchRecipes();
    setState(() {
      foodList = recipes; // Lưu danh sách món ăn
    });
  }

  // Lấy danh sách công thức yêu thích của người dùng
  Future<void> _fetchFavorites() async {
    List<int> favorites = await FetchApi.fetchFavorites();
    setState(() {
      favoriteIds = favorites; // Cập nhật danh sách yêu thích
    });
  }

  // Thêm món ăn vào yêu thích
  Future<void> _addToFavorites(int MaCongThuc) async {
    bool success = await FetchApi.addToFavorites(MaCongThuc);
    if (success) {
      setState(() {
        favoriteIds.add(MaCongThuc); // Thêm vào danh sách yêu thích
      });
      print('Đã thêm vào yêu thích');
    }
  }

  // Bỏ món ăn khỏi yêu thích
  Future<void> _removeFromFavorites(int MaCongThuc) async {
    bool success = await FetchApi.removeFromFavorites(MaCongThuc);
    if (success) {
      setState(() {
        favoriteIds.remove(MaCongThuc); // Xóa khỏi danh sách yêu thích
      });
      print('Đã bỏ yêu thích');
    }
  }

  // Hiển thị menu thông tin cá nhân và đăng xuất
  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Xem thông tin cá nhân'),
              onTap: () {
                // Chuyển hướng tới màn hình thông tin cá nhân
                Navigator.pushNamed(context, '/user-profile');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Đăng xuất'),
              onTap: () async {
                // Xóa token và chuyển hướng về trang đăng nhập
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove('token');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignInScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trang Chủ'),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              // Tạo menu khi nhấn avatar
              _showProfileMenu(context);
            },
          ),
        ],
      ),
      body: Center(
        child: foodList.isEmpty
            ? CircularProgressIndicator() // Hiển thị loading khi chưa có dữ liệu
            : Swiper(
                itemCount: foodList.length,
                itemBuilder: (BuildContext context, int index) {
                  bool isFavorite = favoriteIds.contains(foodList[index]['MaCongThuc']);
                  return Card(
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    color: Colors.orange[100],
                    child: Stack(
                      children: [
                        // Nội dung Card
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                foodList[index]['TenCongThuc'], // Tên công thức món ăn
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              Text(
                                '${foodList[index]['MoTa']}', // Mô tả món ăn
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        // Nút yêu thích
                        Positioned(
                          top: 10,
                          right: 10,
                          child: IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey,
                            ),
                            onPressed: () {
                              if (isFavorite) {
                                _removeFromFavorites(foodList[index]['MaCongThuc']);
                              } else {
                                _addToFavorites(foodList[index]['MaCongThuc']);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loop: false,
                autoplay: false,
                itemHeight: 250,
                itemWidth: double.infinity,
                viewportFraction: 0.85,
                scale: 0.9,
                onIndexChanged: (index) {
                  print('Đang quẹt đến món ăn: ${foodList[index]['TenCongThuc']}');
                },
              ),
      ),
    );
  }
}
