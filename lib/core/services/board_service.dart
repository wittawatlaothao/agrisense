import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/board_model.dart';

class BoardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> addBoard(BoardModel board) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // 1. บันทึกใน subcollection: users/{userId}/boards/{boardId}
      final userBoardRef = _db
          .collection('users')
          .doc(userId)
          .collection('boards')
          .doc(board.boardId);

      // 2. บันทึกใน top-level collection: boards/{boardId}
      final globalBoardRef = _db.collection('boards').doc(board.boardId);

      // เตรียมข้อมูลแยกกัน
      final userBoardData = {
        'boardId': board.boardId,
        'boardName': board.boardName,
        'createdAt': board.createdAt.toIso8601String(),
        // ไม่เก็บ userId ใน subcollection
      };

      final globalBoardData = {
        'boardId': board.boardId,
        'boardName': board.boardName,
        'userId': userId, // เก็บ userId เฉพาะใน top-level collection
        'createdAt': board.createdAt.toIso8601String(),
      };

      // Batch write เพื่อให้ทั้ง 2 ที่สำเร็จพร้อมกัน
      final batch = _db.batch();
      batch.set(userBoardRef, userBoardData);
      batch.set(globalBoardRef, globalBoardData);
      
      await batch.commit();

      // Verify
      final savedDoc = await userBoardRef.get();
      return savedDoc.exists;
    } catch (e) {
      rethrow;
    }
  }

  // Query จาก subcollection (boards ของ user เฉพาะ)
  Future<List<BoardModel>> getUserBoards() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('boards')
          .get();

      return snapshot.docs
          .map((doc) => BoardModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Query จาก top-level collection (board โดยตรง)
  Future<BoardModel?> getBoardById(String boardId) async {
    try {
      final doc = await _db.collection('boards').doc(boardId).get();
      if (!doc.exists) return null;
      return BoardModel.fromMap(doc.data()!);
    } catch (e) {
      return null;
    }
  }

  Future<BoardModel?> getBoard(String boardId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      final doc = await _db
          .collection('users')
          .doc(userId)
          .collection('boards')
          .doc(boardId)
          .get();

      if (!doc.exists) return null;
      return BoardModel.fromMap(doc.data()!);
    } catch (e) {
      return null;
    }
  }
}
