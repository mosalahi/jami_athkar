class CategoryModel {
  final String id;
  final String title;
  final String iconUrl;
  final int order;

  const CategoryModel({
    required this.id,
    required this.title,
    required this.iconUrl,
    required this.order,
  });

  factory CategoryModel.fromMap(String id, Map<String, dynamic> map) {
    return CategoryModel(
      id: id,
      title: map['title'] as String? ?? '',
      iconUrl: map['iconUrl'] as String? ?? '',
      order: (map['order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'iconUrl': iconUrl,
      'order': order,
    };
  }
}
