class Post {
  final int id;
  final String title;
  final String descriptions;
  final int? categoryId;
  final String? category;
  final String? image;

  Post({
    required this.id,
    required this.title,
    required this.descriptions,
    this.categoryId,
    this.category,
    this.image,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      descriptions: json['descriptions'] ?? json['content'] ?? '',
      categoryId: json['category_id'],
      category: json['category_name'],
      image: json['image'] ?? json['image_url'],
    );
  }
}