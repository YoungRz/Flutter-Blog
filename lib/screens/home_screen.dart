import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/category.dart';
import '../services/api_services.dart';
import 'post_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Post>> _postsFuture;
  late Future<List<Category>> _categoriesFuture;
  int? _selectedCategoryId;

  String? _getCategoryAsset(String categoryTitle) {
    switch (categoryTitle.toLowerCase().trim()) {
      case 'teknologi':
        return 'assets/images/TEK.jpg';
      case 'kuliner':
        return 'assets/images/KUL.jpg';
      case 'gaya hidup':
        return 'assets/images/GAHID.jpg';
      case 'pendidikan':
        return 'assets/images/PEND.jpg';
      case 'olahraga':
        return 'assets/images/OLAHRAG.jpg';
      case 'kesehatan':
        return 'assets/images/KESEH.jpg';
      case 'keuangan':
        return 'assets/images/MONEY.jpg';
      case 'wisata':
        return 'assets/images/WISAT.jpg';
      default:
        return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _postsFuture = ApiService.getPosts();
    _categoriesFuture = ApiService.getCategories();
  }

  void _refresh() {
    setState(() {
      _loadData();
    });
  }

  Future<void> _deletePost(int id) async {
    try {
      await ApiService.deletePost(id);
      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post berhasil dihapus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Blog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PostFormScreen()),
          );
          if (result == true) _refresh();
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          const SizedBox(height: 8),
          Expanded(child: _buildPostList()),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return FutureBuilder<List<Category>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 48);

        final categories = snapshot.data!;
        return SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  avatar: Icon(
                    Icons.apps,
                    size: 16,
                    color: _selectedCategoryId == null ? Colors.white : Colors.black,
                  ),
                  label: const Text('Semua'),
                  selected: _selectedCategoryId == null,
                  onSelected: (_) => setState(() => _selectedCategoryId = null),
                ),
              ),
              ...categories.map((c) {
                final assetPath = _getCategoryAsset(c.categoryTitle);
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    avatar: assetPath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              assetPath,
                              width: 18,
                              height: 18,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.category,
                            size: 16,
                            color: _selectedCategoryId == c.id ? Colors.white : Colors.black,
                          ),
                    label: Text(c.categoryTitle),
                    selected: _selectedCategoryId == c.id,
                    onSelected: (_) => setState(() => _selectedCategoryId = c.id),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPostList() {
    return FutureBuilder<List<Post>>(
      future: _postsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.black));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Terjadi error: ${snapshot.error}'));
        }

        var posts = snapshot.data ?? [];
        if (_selectedCategoryId != null) {
          posts = posts.where((p) => p.categoryId == _selectedCategoryId).toList();
        }

        if (posts.isEmpty) {
          return const Center(child: Text('Belum ada post', style: TextStyle(color: Colors.grey)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            final categoryAsset = _getCategoryAsset(post.categoryTitle ?? '');

            // widget gambar/icon kategori - sekarang dipakai di TRAILING (kanan), bukan leading (kiri)
            final imageBox = ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 50,
                height: 50,
                color: Colors.grey.shade100,
                child: post.image != null && post.image!.isNotEmpty
                    ? Image.network(
                        post.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return categoryAsset != null
                              ? Image.asset(categoryAsset, fit: BoxFit.cover)
                              : const Icon(Icons.article, color: Colors.black54);
                        },
                      )
                    : (categoryAsset != null
                        ? Image.asset(categoryAsset, fit: BoxFit.cover)
                        : const Icon(Icons.article, color: Colors.black54)),
              ),
            );

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(
                    post.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  subtitle: Text(
                    '${post.descriptions}\nKategori: ${post.categoryTitle ?? "-"}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      imageBox,
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.white),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PostFormScreen(post: post),
                            ),
                          );
                          if (result == true) _refresh();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => _deletePost(post.id),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}