import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/category.dart';
import '../services/api_services.dart';
import '../utils/responsive.dart';
import 'post_form_screen.dart';
import 'post_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Post> _posts = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  String? _error;
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

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final posts = await ApiService.getPosts();
      final categories = await ApiService.getCategories();
      if (!mounted) return;
      setState(() {
        _posts = posts;
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deletePost(int id) async {
    final backup = List<Post>.from(_posts);
    setState(() {
      _posts.removeWhere((p) => p.id == id);
    });

    try {
      await ApiService.deletePost(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post berhasil dihapus')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _posts = backup;
        });
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
            onPressed: _loadData,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PostFormScreen()),
          );
          if (result == true) _loadData();
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
    if (_categories.isEmpty) return const SizedBox(height: 48);

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: Responsive.pagePadding(context).copyWith(top: 0, bottom: 0),
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
          ..._categories.map((c) {
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
  }

  Widget _buildPostList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.black));
    }
    if (_error != null) {
      return Center(child: Text('Terjadi error: $_error'));
    }

    var posts = _posts;
    if (_selectedCategoryId != null) {
      posts = posts.where((p) => p.categoryId == _selectedCategoryId).toList();
    }

    if (posts.isEmpty) {
      return const Center(child: Text('Belum ada post', style: TextStyle(color: Colors.grey)));
    }

    final isWide = !Responsive.isMobile(context);

    if (isWide) {
      return GridView.builder(
        padding: Responsive.pagePadding(context),
        itemCount: posts.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: Responsive.gridColumns(context),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.95,
        ),
        itemBuilder: (context, index) => _buildPostCard(context, posts[index]),
      );
    }

    // Mobile -> list vertikal, satu card per baris, scroll ke bawah
    return ListView.builder(
      padding: Responsive.pagePadding(context),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildPostCard(context, posts[index]),
        );
      },
    );
  }

  Widget _buildPostCard(BuildContext context, Post post) {
    final categoryAsset = _getCategoryAsset(post.categoryTitle ?? '');

    final imageBox = ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
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
      ),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
          );
          if (result == true) _loadData();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imageBox,
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    post.descriptions,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      post.categoryTitle ?? "-",
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white24, indent: 12, endIndent: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PostFormScreen(post: post)),
                    );
                    if (result == true) _loadData();
                  },
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _deletePost(post.id),
                ),
                const SizedBox(width: 8),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}