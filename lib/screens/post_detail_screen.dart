import 'package:flutter/material.dart';
import '../models/post.dart';
import '../utils/responsive.dart';
import 'post_form_screen.dart';

class PostDetailScreen extends StatelessWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

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
  Widget build(BuildContext context) {
    final categoryAsset = _getCategoryAsset(post.categoryTitle ?? '');

    final double imageHeight = Responsive.isMobile(context)
        ? 220
        : Responsive.isTablet(context)
            ? 300
            : 380;

    final Widget imageWidget = post.image != null && post.image!.isNotEmpty
        ? Image.network(
            post.image!,
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return categoryAsset != null
                  ? Image.asset(categoryAsset, fit: BoxFit.cover, width: double.infinity)
                  : Container(color: Colors.grey.shade300, child: const Icon(Icons.article, size: 48));
            },
          )
        : (categoryAsset != null
            ? Image.asset(categoryAsset, fit: BoxFit.cover, width: double.infinity)
            : Container(color: Colors.grey.shade300, child: const Icon(Icons.article, size: 48)));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: imageHeight,
            leading: const BackButton(),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PostFormScreen(post: post)),
                  );
                  if (result == true && context.mounted) {
                    Navigator.pop(context, true);
                  }
                },
              ),
            ],
            // title dihapus biar nggak dobel sama judul di body pas gambar collapse
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  imageWidget,
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black26],
                        stops: [0.6, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: Responsive.isDesktop(context)
                      ? 800
                      : Responsive.isTablet(context)
                          ? 700
                          : double.infinity,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF006199),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            post.categoryTitle ?? "-",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          post.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          post.descriptions,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}