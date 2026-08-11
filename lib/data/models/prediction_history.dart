import 'package:cloud_firestore/cloud_firestore.dart';

class PredictionHistory {
  final String id;
  final String userId;
  final String label;
  final double confidence;
  final String? imageUrl;
  final DateTime timestamp;
  final Map<String, dynamic>? probabilities;

  PredictionHistory({
    required this.id,
    required this.userId,
    required this.label,
    required this.confidence,
    this.imageUrl,
    required this.timestamp,
    this.probabilities,
  });

  factory PredictionHistory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PredictionHistory(
      id: doc.id,
      userId: data['userId'] ?? '',
      label: data['label'] ?? '',
      confidence: (data['confidence'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      probabilities: data['probabilities'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'label': label,
      'confidence': confidence,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'probabilities': probabilities,
    };
  }
}
