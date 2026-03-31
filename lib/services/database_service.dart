import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';
import '../models/athkar_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Returns a live stream of all categories ordered by the [order] field.
  Stream<List<CategoryModel>> getCategories() {
    return _db
        .collection('main_categories')
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CategoryModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Returns a live stream of athkar belonging to [categoryId].
  Stream<List<AthkarModel>> getAthkar(String categoryId) {
    return _db
        .collection('athkar_content')
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AthkarModel.fromMap(doc.id, doc.data()))
            .toList());
  }
}
