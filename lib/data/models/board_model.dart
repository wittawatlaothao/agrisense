class BoardModel {
  final String boardId;
  final String boardName;
  final String? userId; // เพิ่ม userId สำหรับ top-level collection
  final DateTime createdAt;

  BoardModel({
    required this.boardId,
    required this.boardName,
    this.userId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'boardId': boardId,
      'boardName': boardName,
      if (userId != null) 'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BoardModel.fromMap(Map<String, dynamic> map) {
    return BoardModel(
      boardId: map['boardId'] ?? '',
      boardName: map['boardName'] ?? '',
      userId: map['userId'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
