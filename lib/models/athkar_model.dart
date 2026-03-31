class AthkarModel {
  final String id;
  final String categoryId;
  final String text;
  final int count;
  final String virtue;
  final String reference;

  const AthkarModel({
    required this.id,
    required this.categoryId,
    required this.text,
    required this.count,
    required this.virtue,
    required this.reference,
  });

  factory AthkarModel.fromMap(String id, Map<String, dynamic> map) {
    return AthkarModel(
      id: id,
      categoryId: map['categoryId'] as String? ?? '',
      text: map['text'] as String? ?? '',
      count: (map['count'] as num?)?.toInt() ?? 1,
      virtue: map['virtue'] as String? ?? '',
      reference: map['reference'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'text': text,
      'count': count,
      'virtue': virtue,
      'reference': reference,
    };
  }
}
