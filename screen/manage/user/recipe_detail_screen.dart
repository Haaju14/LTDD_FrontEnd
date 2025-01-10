import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../fetch_api.dart';

class RecipeDetailScreen extends StatefulWidget {
  final int recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late Map<String, dynamic> recipeDetails;
  double rating = 0.0; // Rating của người dùng
  String comment = ''; // Bình luận của người dùng
  bool isSubmitting = false; // Trạng thái gửi đánh giá
  List<dynamic> ratings = []; // Danh sách đánh giá của công thức

  @override
  void initState() {
    super.initState();
    recipeDetails = {}; // Initialize as an empty map
    _fetchRecipeDetails();
    _fetchRatings(); // Fetch ratings when the screen loads
  }

  // Lấy chi tiết công thức từ API
  Future<void> _fetchRecipeDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Token không hợp lệ, vui lòng đăng nhập.')));
        return;
      }

      final details = await FetchApi.fetchRecipeDetails(widget.recipeId, token);

      if (details.containsKey('congThuc')) {
        setState(() {
          recipeDetails = details['congThuc'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không tìm thấy công thức.')),
        );
      }
    } catch (e) {
      print("Lỗi khi lấy chi tiết công thức: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi xảy ra khi tải công thức.')),
      );
    }
  }

  // Lấy đánh giá từ API
  Future<void> _fetchRatings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Token không hợp lệ, vui lòng đăng nhập.')));
        return;
      }

      final response =
          await FetchApi.fetchReviewsForRecipe(widget.recipeId, token);

      if (response.containsKey('danhGia')) {
        setState(() {
          ratings = response['danhGia'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không có đánh giá nào cho công thức này.')),
        );
      }
    } catch (e) {}
  }

  // Gửi đánh giá công thức
  Future<void> _submitRating() async {
    setState(() {
      isSubmitting = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Token không hợp lệ, vui lòng đăng nhập.')));
        return;
      }

      final response = await FetchApi.addRating(
        widget.recipeId,
        rating,
        comment,
        token,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Đánh giá thành công!')),
      );
      setState(() {
        rating = 0.0;
        comment = '';
      });

      // Refresh ratings after submitting a new one
      _fetchRatings();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiết Công Thức'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // Tính năng thêm vào yêu thích (Cần xử lý thêm)
            },
          ),
        ],
      ),
      body: recipeDetails.isEmpty
          ? const Center(
              child:
                  CircularProgressIndicator()) // Hiển thị loading nếu chưa có dữ liệu
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên công thức
                    Text(
                      recipeDetails['TenCongThuc'] ?? 'Không có tên công thức',
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    const SizedBox(height: 10),

                    // Hình ảnh công thức món ăn
                    recipeDetails['HinhAnh'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CachedNetworkImage(
                              imageUrl: recipeDetails['HinhAnh'],
                              height: 250,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.broken_image),
                            ),
                          )
                        : const Placeholder(
                            fallbackHeight: 250,
                            fallbackWidth: double.infinity,
                          ),
                    const SizedBox(height: 10),

                    // Mô tả
                    Text(
                      'Mô Tả: ${recipeDetails['MoTa'] ?? 'Không có mô tả'}',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),

                    // Nguyên liệu
                    Text(
                      'Nguyên Liệu: ${recipeDetails['NguyenLieu'] ?? 'Không có nguyên liệu'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),

                    // Cách làm
                    Text(
                      'Cách Làm: ${recipeDetails['CachLam'] ?? 'Không có cách làm'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),

                    // Thời gian nấu
                    Text(
                      'Thời Gian Nấu: ${recipeDetails['ThoiGianNau'] ?? 'Không có thời gian nấu'} phút',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),

                    // Đánh giá
                    Text('Đánh giá của bạn:', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    Row(
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            setState(() {
                              rating = index + 1.0;
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 10),

                    // Bình luận

                    const SizedBox(height: 20),

                    // Gửi đánh giá
                    ElevatedButton(
                      onPressed: isSubmitting ? null : _submitRating,
                      child: isSubmitting
                          ? CircularProgressIndicator()
                          : Text('Gửi đánh giá'),
                    ),

                    const SizedBox(height: 20),

                    // Hiển thị danh sách đánh giá
                    Text('Đánh giá khác:', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: ratings.length,
                      itemBuilder: (context, index) {
                        // Lấy rating từ API và chắc chắn rằng giá trị này là số
                        double rating =
                            (ratings[index]['rating'] ?? 0.0).toDouble();

                        return ListTile(
                          title: Text(
                            ratings[index]['MaNguoiDung_USER']
                                    ['TenNguoiDung'] ??
                                'Không có tên người dùng',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Hiển thị số sao (5 sao tối đa)
                              Row(
                                children: List.generate(5, (starIndex) {
                                  return Icon(
                                    starIndex < rating
                                        ? Icons.star
                                        : Icons
                                            .star_border, // Sao đầy nếu rating >= starIndex
                                    color: starIndex < rating
                                        ? Colors.amber
                                        : Colors.grey,
                                    size: 20.0,
                                  );
                                }),
                              ),
                              const SizedBox(height: 5),
                              // Nội dung bình luận
                            ],
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
