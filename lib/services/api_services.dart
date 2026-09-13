import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
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
    XFile? imageFile,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/posts'));
    
    request.fields['title'] = title;
    request.fields['descriptions'] = descriptions;
    if (categoryId != null) {
      request.fields['category_id'] = categoryId.toString();
    }

    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: imageFile.name,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Gagal menambahkan post');
    }
  }

  static Future<void> updatePost({
    required int id,
    required String title,
    required String descriptions,
    int? categoryId,
    XFile? imageFile,
  }) async {
    var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/posts/$id'));

    request.fields['title'] = title;
    request.fields['descriptions'] = descriptions;
    if (categoryId != null) {
      request.fields['category_id'] = categoryId.toString();
    }

    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: imageFile.name,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Gagal memperbarui post');
    }
  }

  static Future<void> deletePost(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/posts/$id'));
    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus post');
    }
  }
}