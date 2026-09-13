class Post {
  final int id;
  final String title;
  final String descriptions;
  final String? image; // ini udah berupa URL lengkap dari backend
  final int? categoryId;
  final String? categoryTitle;
 
  Post({
    required this.id,
    required this.title,
    required this.descriptions,
    this.image,
    this.categoryId,
    this.categoryTitle,
  });
 
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      title: json['title'],
      descriptions: json['descriptions'],
      image: json['image'],
      categoryId: json['category_id'] == null
          ? null
          : (json['category_id'] is String ? int.parse(json['category_id']) : json['category_id']),
      categoryTitle: json['category_title'],
    );
  }
}
 