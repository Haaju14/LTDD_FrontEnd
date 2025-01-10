import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FetchApi {
  static const String baseUrl = 'http://192.168.1.15:8080';
// Hàm đăng ký
  static Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'TenNguoiDung': name,
        'Email': email,
        'MatKhau': password,
        'VaiTro': 'User', // Mặc định role là User
      }),
    );

    final Map<String, dynamic> responseData = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return {'success': true, 'message': responseData['message']};
    } else {
      return {'success': false, 'message': responseData['message']};
    }
  }

  // Hàm đăng nhập
  static Future<Map<String, dynamic>> signIn(
      String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'Email': email,
        'MatKhau': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Lỗi đăng nhập: ${response.body}');
    }
  }

// Hàm thay đổi mật khẩu
  static Future<Map<String, dynamic>> changePassword(
      String oldPassword, String newPassword, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/change-password'), // Đổi mật khẩu
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Thêm token vào header nếu cần
      },
      body: jsonEncode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Lỗi thay đổi mật khẩu: ${response.body}');
    }
  }

// API quên mật khẩu
  static Future<void> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'), // Địa chỉ API quên mật khẩu
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'Email': email,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['message']);
      }
    } catch (error) {
      throw Exception('Lỗi khi gửi yêu cầu quên mật khẩu: $error');
    }
  }

// Hàm lấy công thức món ăn
  static Future<List<dynamic>> fetchRecipes() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        print('Token không hợp lệ hoặc chưa có token');
        return []; // Trả về danh sách rỗng nếu không có token
      }

      final response = await http.get(
        Uri.parse('$baseUrl/cong-thuc'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return data['danhSachCongThuc']; // Trả về danh sách công thức
      } else if (response.statusCode == 404) {
        print('Không tìm thấy công thức: ${response.body}');
        return [];
      } else {
        print('Không thể lấy danh sách công thức: ${response.body}');
        return [];
      }
    } catch (error) {
      print('Lỗi khi lấy dữ liệu công thức: $error');
      return [];
    }
  }

// Hàm lấy danh sách yêu thích
  static Future<List<int>> fetchFavorites() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        print('Token không hợp lệ hoặc chưa có token');
        return []; // Trả về danh sách yêu thích rỗng nếu không có token
      }

      final response = await http.get(
        Uri.parse('$baseUrl/yeuthich/getbyuser'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return data['yeuThichList']
            .map<int>((item) => item['MaCongThuc'])
            .toList();
      } else {
        print('Không thể lấy danh sách yêu thích');
        return [];
      }
    } catch (error) {
      print('Lỗi khi lấy danh sách yêu thích: $error');
      return [];
    }
  }

//Hàm thêm yêu thích
  static Future<bool> addToFavorites(int MaCongThuc) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        print('Token không hợp lệ hoặc chưa có token');
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/yeuthich/add'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'MaCongThuc': MaCongThuc}),
      );

      return response.statusCode == 201;
    } catch (error) {
      print('Lỗi khi thêm vào yêu thích: $error');
      return false;
    }
  }

// Hàm bỏ yêu thích
  static Future<bool> removeFromFavorites(int MaCongThuc) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        print('Token không hợp lệ hoặc chưa có token');
        return false;
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/yeuthich/delete/$MaCongThuc'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (error) {
      print('Lỗi khi bỏ yêu thích: $error');
      return false;
    }
  }

  // Lấy thông tin người dùng
  static Future<Map<String, dynamic>> fetchUserProfile(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("Không tìm thấy token");
    }

    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final data = json.decode(response.body);
      throw Exception(data['message'] ?? "Lỗi không xác định");
    }
  }

  // Cập nhật thông tin người dùng
  static Future<void> updateUserProfile({
    required String token,
    required String name,
    required String email,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("Không tìm thấy token");
    }

    final response = await http.put(
      Uri.parse('$baseUrl/user/put'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'TenNguoiDung': name,
        'Email': email,
      }),
    );

    if (response.statusCode != 200) {
      final data = json.decode(response.body);
      throw Exception(data['message'] ?? "Lỗi không xác định");
    }
  }

  // Lấy thông tin tất cả người dùng (admin)
  static Future<List<dynamic>> getAllUsers(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/get/all'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['users'];
    } else {
      throw Exception('Lỗi khi lấy danh sách người dùng: ${response.body}');
    }
  }

  // Lấy thông tin người dùng theo ID (admin)
  static Future<Map<String, dynamic>> getUserById(
      String id, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['user'];
    } else {
      throw Exception('Lỗi khi lấy thông tin người dùng: ${response.body}');
    }
  }

  // Chỉnh sửa thông tin người dùng (admin)
  static Future<void> updateUser(
      String id, Map<String, dynamic> body, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/user/put/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Lỗi khi cập nhật người dùng: ${response.body}');
    }
  }

  // Xóa người dùng
  static Future<void> deleteUser(String id, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/user/delete/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Lỗi khi xóa người dùng: ${response.body}');
    }
  }

  // Lấy danh sách công thức cần kiểm duyệt
  static Future<List<dynamic>> getRecipesForApproval(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/kiemduyet/all'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['danhSachCongThucKiemDuyet'];
    } else {
      throw Exception('Lỗi khi lấy danh sách công thức');
    }
  }

  // Duyệt công thức
  static Future<void> approveRecipe(
      int approvalId, String status, String reason, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/congthuc/kiem-duyet'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'MaKiemDuyet': approvalId,
        'TrangThai': status,
        'LyDo': reason,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Lỗi khi duyệt công thức');
    }
  }

  // Xóa công thức theo ID
  static Future<void> deleteRecipe(int approvalId, String token) async {
    final response = await http
        .delete(Uri.parse('$baseUrl/kiemduyet/delete/$approvalId'), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode != 200) {
      throw Exception('Lỗi khi xóa công thức');
    }
  }

  // Lấy danh sách tất cả danh mục
  static Future<List<dynamic>> getAllCategories(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/danhmuc/all'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['danhMucList'];
    } else {
      throw Exception('Lỗi khi lấy danh sách danh mục');
    }
  }

  // Thêm danh mục
  static Future<void> addCategory(String categoryName, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/danhmuc/add'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'TenDanhMuc': categoryName}),
    );

    if (response.statusCode != 201) {
      throw Exception('Lỗi khi thêm danh mục');
    }
  }

  // Sửa danh mục
  static Future<void> editCategory(
      int id, String categoryName, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/danhmuc/put/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'TenDanhMuc': categoryName}),
    );

    if (response.statusCode != 200) {
      throw Exception('Lỗi khi sửa danh mục');
    }
  }

  // Xóa danh mục
  static Future<void> deleteCategory(int id, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/danhmuc/delete/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Lỗi khi xóa danh mục');
    }
  }

  static Future<Map<String, dynamic>> fetchRecipeDetails(int id) async {
    try {
      // Lấy token từ SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token không hợp lệ');
      }

      // Gọi API lấy chi tiết công thức
      final response = await http.get(
        Uri.parse('$baseUrl/cong-thuc/xemchitiet/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Chuyển đổi dữ liệu JSON từ response
        final data = jsonDecode(response.body);
        return data; // Trả về dữ liệu chi tiết công thức
      } else {
        throw Exception('Lỗi khi lấy chi tiết công thức');
      }
    } catch (e) {
      throw Exception('Lỗi khi gọi API: $e');
    }
  }

  // Lấy danh sách công thức trong bảng BLACKLIST
  Future<List<dynamic>> fetchBlacklist() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) {
        throw Exception('Không tìm thấy token');
      }
      final response = await http.get(
        Uri.parse('$baseUrl/blacklist/all'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['danhSachCongThucBlacklist'];
      } else {
        throw Exception('Lỗi khi lấy danh sách blacklist');
      }
    } catch (error) {
      throw Exception('Có lỗi xảy ra: $error');
    }
  }

  // Xóa công thức trong danh sách BLACKLIST
  static Future<void> deleteBlacklistItem(
      String maBlackList, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/blacklist/delete/$maBlackList'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Lỗi khi xóa công thức');
    }
  }

  static getRecipesList(String token) {}
}
