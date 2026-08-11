import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/prediction_history.dart';

class PredictionHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  CollectionReference get _historyCollection =>
      _firestore.collection('prediction_history');

  // บันทึกประวัติการ predict
  Future<void> savePrediction({
    required String label,
    required double confidence,
    String? imageUrl,
    Map<String, dynamic>? probabilities,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw 'ไม่พบข้อมูลผู้ใช้';
      }

      final history = PredictionHistory(
        id: '',
        userId: userId,
        label: label,
        confidence: confidence,
        imageUrl: imageUrl,
        timestamp: DateTime.now(),
        probabilities: probabilities,
      );

      await _historyCollection.add(history.toMap());
    } catch (e) {
      print('Error saving prediction: $e');
      rethrow;
    }
  }

  // ดึงประวัติการ predict ทั้งหมดของผู้ใช้ (30 รายการล่าสุด)
  Stream<List<PredictionHistory>> getUserHistory({int limit = 30}) {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return Stream.value([]);
      }

      // แก้ไข: ไม่ใช้ orderBy เพื่อหลีกเลี่ยง composite index
      // แทนที่จะเรียงใน Firestore เราจะเรียงใน client side
      return _historyCollection
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
        final histories = snapshot.docs
            .map((doc) => PredictionHistory.fromFirestore(doc))
            .toList();
        
        // เรียงตาม timestamp (ล่าสุดก่อน) และจำกัดจำนวน
        histories.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        return histories.length > limit 
            ? histories.sublist(0, limit) 
            : histories;
      });
    } catch (e) {
      print('Error getting user history: $e');
      return Stream.value([]);
    }
  }

  // ลบประวัติ
  Future<void> deleteHistory(String historyId) async {
    try {
      await _historyCollection.doc(historyId).delete();
    } catch (e) {
      print('Error deleting history: $e');
      rethrow;
    }
  }

  // ลบประวัติทั้งหมดของผู้ใช้
  Future<void> clearAllHistory() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw 'ไม่พบข้อมูลผู้ใช้';
      }

      final snapshot = await _historyCollection
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print('Error clearing history: $e');
      rethrow;
    }
  }
}
