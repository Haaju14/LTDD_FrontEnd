import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import '../../../fetch_api.dart';
import 'profile_menu.dart';
import 'recipe_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<dynamic> foodList = [];
  late Set<int> favoriteRecipeIds = {}; // Set để lưu danh sách yêu thích

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
    _fetchFavorites();
  }

  // Lấy danh sách công thức món ăn
  Future<void> _fetchRecipes() async {
    final List<dynamic> recipes = await FetchApi.fetchRecipes();
    setState(() {
      foodList = recipes;
    });
  }

  // Lấy danh sách yêu thích
  Future<void> _fetchFavorites() async {
    final List<int> favorites = await FetchApi.fetchFavorites();
    setState(() {
      favoriteRecipeIds = Set.from(favorites);
    });
  }

  // Thêm vào yêu thích
  Future<void> _addToFavorites(int recipeId) async {
    final success = await FetchApi.addToFavorites(recipeId);
    if (success) {
      setState(() {
        favoriteRecipeIds.add(recipeId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã thêm vào yêu thích")),
      );
    }
  }

  // Bỏ yêu thích
  Future<void> _removeFromFavorites(int recipeId) async {
    final success = await FetchApi.removeFromFavorites(recipeId);
    if (success) {
      setState(() {
        favoriteRecipeIds.remove(recipeId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã bỏ yêu thích")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh sách công thức món ăn"),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => showProfileMenu(
                context), // Gọi hàm showProfileMenu từ file riêng
          ),
        ],
      ),
      body: foodList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Swiper(
              itemCount: foodList.length,
              itemBuilder: (BuildContext context, int index) {
                final recipe = foodList[index];
                return _buildRecipeCard(recipe);
              },
              layout: SwiperLayout.STACK,
              itemWidth: MediaQuery.of(context).size.width * 0.8,
              itemHeight: MediaQuery.of(context).size.height * 0.6,
              onIndexChanged: (index) {
                print("Swiped to index $index");
              },
              onTap: (index) {
                final recipe = foodList[index];
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RecipeDetailScreen(recipeId: recipe['MaCongThuc']),
                  ),
                );
              },
              control: SwiperControl(),
              pagination: SwiperPagination(
                builder: DotSwiperPaginationBuilder(
                  color: Colors.grey,
                  activeColor: Colors.red,
                  size: 8.0,
                  activeSize: 10.0,
                ),
              ),
            ),
    );
  }

  // Xây dựng Card công thức món ăn
  Widget _buildRecipeCard(dynamic recipe) {
    final isFavorite = favoriteRecipeIds.contains(recipe['MaCongThuc']);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 8.0,
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      RecipeDetailScreen(recipeId: recipe['MaCongThuc']),
                ),
              );
            },
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15.0)),
              child: Image.network(
                recipe['HinhAnh'] ?? '',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe['TenCongThuc'] ?? '',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  recipe['MoTa'] ?? '',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.grey,
            ),
            onPressed: () {
              if (isFavorite) {
                _removeFromFavorites(recipe['MaCongThuc']);
              } else {
                _addToFavorites(recipe['MaCongThuc']);
              }
            },
          ),
        ],
      ),
    );
  }
}
