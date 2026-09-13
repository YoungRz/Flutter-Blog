class Category {
  final int id;
  final String categoryTitle;

  Category({required this.id, required this.categoryTitle});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      categoryTitle: json['category_title'],
    );
  }
}