class Post {
  final int id;
  final String title;
  final String descriptions;
  final int? categoryId;
  final String? categoryTitle;

  Post({
    required this.id,
    required this.title,
    required this.descriptions,
    this.categoryId,
    this.categoryTitle,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      descriptions: json['descriptions'],
      categoryId: json['category_id'],
      categoryTitle: json['category_title'],
    );
  }
}