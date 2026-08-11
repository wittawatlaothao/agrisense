import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/selector.dart';
import '../../../data/models/board_model.dart';

class CameraCapturesPage extends StatefulWidget {
  const CameraCapturesPage({super.key});

  @override
  State<CameraCapturesPage> createState() => _CameraCapturesPageState();
}

class _CameraCapturesPageState extends State<CameraCapturesPage> {
  String? _selectedBoardId;

  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  Color _labelColor(String? label) {
    final value = label?.toLowerCase().trim();
    switch (value) {
      case 'healthy':
        return Colors.green;
      case 'fungal':
        return Colors.red;
      case 'bacterial':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _labelBgColor(String? label) {
    return _labelColor(label).withOpacity(0.12);
  }

  String _formatTimestamp(dynamic value) {
    if (value is Timestamp) {
      return DateFormat('dd/MM/yyyy HH:mm').format(value.toDate());
    }
    if (value is String) {
      return value;
    }
    return '-';
  }

  Query _capturesQuery(List<String> userBoardIds) {
    final base = FirebaseFirestore.instance.collection('camera_captures');
    
    if (userBoardIds.isEmpty) {
      // ถ้าไม่มี board ของ user ไม่แสดงข้อมูล
      return base.where('boardId', isEqualTo: '__no_board__');
    }
    
    if (_selectedBoardId == null) {
      // แสดง captures จาก boards ทั้งหมดของ user
      return base.where('boardId', whereIn: userBoardIds);
    }
    return base.where('boardId', isEqualTo: _selectedBoardId);
  }

  Map<String, Map<String, dynamic>> _predictionByPosition(List parts) {
    final result = <String, Map<String, dynamic>>{};
    final positionReg = RegExp(r'part_\d+_\d+');

    for (final part in parts) {
      if (part is! Map<String, dynamic>) continue;
      final predictions = part['predictions'];
      if (predictions is! List) continue;
      for (final item in predictions) {
        if (item is! Map<String, dynamic>) continue;
        final filename = item['filename']?.toString() ?? '';
        final match = positionReg.firstMatch(filename);
        if (match == null) continue;
        final position = match.group(0) ?? '';
        if (position.isEmpty) continue;
        final prediction = item['prediction'];
        final predictionMap = prediction is Map<String, dynamic>
            ? prediction
            : <String, dynamic>{};
        result[position] = {
          'filename': filename,
          'success': item['success'],
          'label': predictionMap['label'],
          'confidence': predictionMap['confidence'],
          'probabilities': predictionMap['probabilities'],
        };
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ภาพถ่ายจากกล้อง'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('boards')
            .where('userId', isEqualTo: _currentUserId)
            .snapshots(),
        builder: (context, boardSnap) {
          if (boardSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final boardDocs = boardSnap.data?.docs ?? [];
          final boardMap = <String, String>{};
          final boards = <BoardModel>[];
          for (final doc in boardDocs) {
            final data = doc.data() as Map<String, dynamic>;
            final boardName = data['boardName']?.toString() ?? doc.id;
            final createdAtRaw = data['createdAt'];
            final createdAt = createdAtRaw is Timestamp
                ? createdAtRaw.toDate()
                : createdAtRaw is String
                    ? DateTime.tryParse(createdAtRaw) ?? DateTime.now()
                    : DateTime.now();
            boardMap[doc.id] = boardName;
            boards.add(
              BoardModel(
                boardId: doc.id,
                boardName: boardName,
                userId: data['userId']?.toString(),
                createdAt: createdAt,
              ),
            );
          }

          // ดึง boardIds ของ user เพื่อใช้กรอง captures
          final userBoardIds = boardDocs.map((doc) => doc.id).toList();

          return StreamBuilder<QuerySnapshot>(
            stream: _capturesQuery(userBoardIds).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
              }

              final docs = (snapshot.data?.docs ?? []).toList();
              docs.sort((a, b) {
                final ad = a.data() as Map<String, dynamic>;
                final bd = b.data() as Map<String, dynamic>;
                final aTime = ad['createdAt'] ?? ad['timestamp'];
                final bTime = bd['createdAt'] ?? bd['timestamp'];
                DateTime aDate;
                DateTime bDate;
                if (aTime is Timestamp) {
                  aDate = aTime.toDate();
                } else if (aTime is String) {
                  aDate = DateTime.tryParse(aTime) ?? DateTime.fromMillisecondsSinceEpoch(0);
                } else {
                  aDate = DateTime.fromMillisecondsSinceEpoch(0);
                }
                if (bTime is Timestamp) {
                  bDate = bTime.toDate();
                } else if (bTime is String) {
                  bDate = DateTime.tryParse(bTime) ?? DateTime.fromMillisecondsSinceEpoch(0);
                } else {
                  bDate = DateTime.fromMillisecondsSinceEpoch(0);
                }
                return bDate.compareTo(aDate);
              });
              if (docs.isEmpty) {
                return const Center(child: Text('ยังไม่มีข้อมูลจาก Raspberry Pi'));
              }

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: BoardSelector(
                      boards: boards,
                      selectedBoardId: _selectedBoardId,
                      onBoardChanged: (value) {
                        setState(() {
                          _selectedBoardId = value;
                        });
                      },
                    ),
                  ),
                  if (_selectedBoardId != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedBoardId = null;
                              });
                            },
                            icon: const Icon(Icons.filter_alt_off, size: 18),
                            label: const Text('แสดงทั้งหมด'),
                          ),
                        ),
                      ),
                    ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final data = docs[index].data() as Map<String, dynamic>;
                          final imageUrl = data['imageUrl'] as String?;
                          final boardId = data['boardId'] as String?;
                          final boardName = boardId != null ? boardMap[boardId] : null;
                          final type = data['type'] as String?;
                          final totalParts = data['total_parts'];
                          final successfulParts = data['successful_parts'];
                          final createdAt = data['createdAt'];
                          final timestamp = data['timestamp'];
                          final analysisResult = data['analysisResult'] as Map<String, dynamic>?;
                          final parts = (analysisResult?['parts'] as List?) ?? const [];
                          final predictionByPosition = _predictionByPosition(parts);
                          final partImageUrls = (data['partImageUrls'] as List?) ?? const [];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 14),
                            elevation: 3,
                            shadowColor: Colors.black.withOpacity(0.08),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ExpansionTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              collapsedShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: imageUrl != null
                                    ? Image.network(
                                        imageUrl,
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(Icons.image_not_supported, size: 36);
                                        },
                                      )
                                    : const Icon(Icons.image, size: 36),
                              ),
                              title: Text(
                                boardName ?? boardId ?? 'Camera Capture',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (type != null) Text('Type: $type'),
                                  Text('เวลา: ${_formatTimestamp(createdAt ?? timestamp)}'),
                                ],
                              ),
                              children: [
                                if (imageUrl != null)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        imageUrl,
                                        height: 200,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const SizedBox(
                                            height: 200,
                                            child: Center(child: Icon(Icons.image_not_supported)),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      if (totalParts != null)
                                        Chip(label: Text('total_parts: $totalParts')),
                                      if (successfulParts != null)
                                        Chip(label: Text('successful_parts: $successfulParts')),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (partImageUrls.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        const crossAxisCount = 2;
                                        const spacing = 10.0;
                                        final cardWidth = (constraints.maxWidth - spacing * (crossAxisCount - 1)) / crossAxisCount;
                                        final cardHeight = cardWidth * 1.4; // อัตราส่วน 1:1.4

                                        return GridView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: crossAxisCount,
                                            crossAxisSpacing: spacing,
                                            mainAxisSpacing: spacing,
                                            childAspectRatio: cardWidth / cardHeight,
                                          ),
                                          itemCount: partImageUrls.length > 6 ? 6 : partImageUrls.length, // แสดงสูงสุด 3 แถว x 2 หลัก = 6
                                          itemBuilder: (context, idx) {
                                            final item = partImageUrls[idx] as Map<String, dynamic>;
                                            final partUrl = item['imageUrl'] as String?;
                                            final position = item['position'] as String?;
                                            final prediction = position != null
                                                ? predictionByPosition[position]
                                                : null;
                                            final label = prediction?['label']?.toString();
                                            final confidence = prediction?['confidence'] is num
                                                ? (prediction?['confidence'] as num).toDouble()
                                                : null;

                                            return Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(14),
                                                border: Border.all(color: Colors.black.withOpacity(0.06)),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.04),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(10),
                                                      child: partUrl != null
                                                          ? Image.network(
                                                              partUrl,
                                                              width: double.infinity,
                                                              fit: BoxFit.cover,
                                                              errorBuilder: (context, error, stackTrace) {
                                                                return const Center(child: Icon(Icons.image_not_supported));
                                                              },
                                                            )
                                                          : const Center(child: Icon(Icons.image_not_supported)),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    position ?? '-',
                                                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                                                  ),
                                                  if (label != null)
                                                    Container(
                                                      margin: const EdgeInsets.only(top: 4),
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: _labelBgColor(label),
                                                        borderRadius: BorderRadius.circular(999),
                                                      ),
                                                      child: Text(
                                                        label,
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.w600,
                                                          color: _labelColor(label),
                                                        ),
                                                      ),
                                                    ),
                                                  if (confidence != null)
                                                    Padding(
                                                      padding: const EdgeInsets.only(top: 4),
                                                      child: Text(
                                                        '${(confidence * 100).toStringAsFixed(1)}%',
                                                        style: const TextStyle(
                                                          fontSize: 11,
                                                          color: Colors.black54,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          );
                        },
                        childCount: docs.length,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
