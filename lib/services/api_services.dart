import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import '../models/category.dart';

class ApiService {
  static const String baseUrl = "http://localhost:777";

  static Future<List<Category>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'));
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'];
      return data.map((e) => Category.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil kategori');
    }
  }

  static Future<void> createCategory(String categoryTitle) async {
    final response = await http.post(
      Uri.parse('$baseUrl/categories'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'category_title': categoryTitle}),
    );
    if (response.statusCode != 201) {
      throw Exception('Gagal menambahkan kategori');
    }
  }

  static Future<List<Post>> getPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/posts'));
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'];
      return data.map((e) => Post.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data post');
    }
  }

  static Future<Post> getPostById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/posts/$id'));
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return Post.fromJson(body['data']);
    } else {
      throw Exception('Gagal mengambil detail post');
    }
  }

  static Future<void> createPost({
    required String title,
    required String descriptions,
    int? categoryId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'descriptions': descriptions,
        'category_id': categoryId,
      }),
    );

    print('CREATE POST - Status Code: ${response.statusCode}');
    print('CREATE POST - Response Body: ${response.body}');

    if (response.statusCode != 201) {
      throw Exception(_extractErrorMessage(response.body));
    }
  }

  static Future<void> updatePost({
    required int id,
    required String title,
    required String descriptions,
    int? categoryId,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/posts/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'descriptions': descriptions,
        'category_id': categoryId,
      }),
    );

    print('UPDATE POST - Status Code: ${response.statusCode}');
    print('UPDATE POST - Response Body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(_extractErrorMessage(response.body));
    }
  }

  static String _extractErrorMessage(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      final message = decoded['message'];
      final error = decoded['error'];
      if (error != null) return '$message ($error)';
      if (message != null) return message.toString();
      return responseBody;
    } catch (_) {
      return responseBody;
    }
  }

  static Future<void> deletePost(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/posts/$id'));
    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus post');
    }
  }
}