import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _selectedFilter = 'all';
  List<String> _boardIds = [];
  Map<String, String> _boardNames = {};
  bool _loadingBoards = true;
  final Set<String> _expandedCards = {};
  Stream<QuerySnapshot>? _capturesStream;

  String get _userId => _auth.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _loadUserBoards();
  }

  Future<void> _loadUserBoards() async {
    if (_userId.isEmpty) {
      setState(() => _loadingBoards = false);
      return;
    }
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('boards')
          .get();
      setState(() {
        _boardIds = snapshot.docs.map((doc) => doc.id).toList();
        _boardNames = {
          for (final doc in snapshot.docs)
            doc.id: (doc.data() as Map<String, dynamic>)['boardName'] as String? ?? doc.id
        };
        _loadingBoards = false;
        _initStream();
      });
    } catch (e) {
      debugPrint('Error loading boards: $e');
      setState(() => _loadingBoards = false);
    }
  }

  void _initStream() {
    if (_boardIds.isEmpty) {
      _capturesStream = null;
      return;
    }
    _capturesStream = _firestore
        .collection('camera_captures')
        .where('boardId', whereIn: _boardIds)
        .limit(50)
        .snapshots();
  }

  List<Map<String, dynamic>> _extractDiseasedPredictions(
      Map<String, dynamic> data) {
    final analysisResult = data['analysisResult'] as Map<String, dynamic>?;
    if (analysisResult == null) return [];

    final detections = analysisResult['detections'] as List<dynamic>? ?? [];
    List<Map<String, dynamic>> diseased = [];
    for (final detection in detections) {
      if (detection is! Map<String, dynamic>) continue;
      final diseasePrediction = detection['disease_prediction'] as Map<String, dynamic>?;
      if (diseasePrediction == null) continue;

      final label = diseasePrediction['label'] as String? ?? '';
      if (_selectedFilter != 'all' && label.toLowerCase() != _selectedFilter.toLowerCase()) continue;

      final confidence = (diseasePrediction['confidence'] is num)
          ? (diseasePrediction['confidence'] as num).toDouble()
          : 0.0;
      final cropImageUrl = detection['cropImageUrl'] as String? ?? '';
      final position = 'detection_${detection['detection_id'] ?? ''}';
      final probabilities = diseasePrediction['probabilities'] as Map<String, dynamic>? ?? {};

      diseased.add({
        'label': label,
        'confidence': confidence,
        'filename': cropImageUrl,
        'position': position,
        'imageUrl': cropImageUrl,
        'probabilities': probabilities,
      });
    }
    return diseased;
  }

  Color _getDiseaseColor(String label) {
    switch (label.toLowerCase()) {
      case 'fungal':
        return Colors.orange;
      case 'bacterial':
        return Colors.red;
      case 'healthy':
        return Colors.green;
      default:
        return Colors.purple;
    }
  }

  IconData _getDiseaseIcon(String label) {
    switch (label.toLowerCase()) {
      case 'fungal':
        return Icons.coronavirus;
      case 'bacterial':
        return Icons.bug_report;
      default:
        return Icons.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('การแจ้งเตือน'),
        centerTitle: true,
      ),
      body: _loadingBoards
          ? const Center(child: CircularProgressIndicator())
          : _boardIds.isEmpty
              ? _buildEmptyState()
              : _buildContent(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'ยังไม่ได้เชื่อมต่อบอร์ด',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', 'ทั้งหมด'),
                const SizedBox(width: 8),
                _buildFilterChip('fungal', 'เชื้อรา'),
                const SizedBox(width: 8),
                _buildFilterChip('bacterial', 'แบคทีเรีย'),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _capturesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
                    ],
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              final sortedDocs = List<QueryDocumentSnapshot>.from(docs)
                ..sort((a, b) {
                  final aTime = (a.data() as Map<String, dynamic>)['createdAt']
                      as Timestamp?;
                  final bTime = (b.data() as Map<String, dynamic>)['createdAt']
                      as Timestamp?;
                  if (aTime == null && bTime == null) return 0;
                  if (aTime == null) return 1;
                  if (bTime == null) return -1;
                  return bTime.compareTo(aTime);
                });

              final filteredDocs = sortedDocs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return _extractDiseasedPredictions(data).isNotEmpty;
              }).toList();

              if (filteredDocs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 80, color: Colors.green.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'ไม่พบโรค',
                        style: TextStyle(
                            fontSize: 18, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'พืชทุกส่วนมีสุขภาพดี!',
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => setState(() => _loadUserBoards()),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return _buildCaptureCard(doc.id, data);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedFilter = value),
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildCaptureCard(String docId, Map<String, dynamic> data) {
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
    final boardId = data['boardId'] as String? ?? '';
    final boardName = _boardNames[boardId] ?? boardId;
    final diseasedParts = _extractDiseasedPredictions(data);
    final analysisResult = data['analysisResult'] as Map<String, dynamic>?;
    final totalParts = analysisResult?['total_detections'] as int? ?? analysisResult?['total_parts'] as int? ?? 6;
    final isExpanded = _expandedCards.contains(docId);

    // Determine if all plants are healthy
    final allHealthy = diseasedParts.isEmpty ||
      (diseasedParts.every((p) => (p['label'] as String).toLowerCase() == 'healthy'));
    final diseasedCount = diseasedParts.where((p) => (p['label'] as String).toLowerCase() != 'healthy').length;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - tappable to expand/collapse
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedCards.remove(docId);
                } else {
                  _expandedCards.add(docId);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: allHealthy ? Colors.green.shade50 : Colors.red.shade50,
              ),
              child: Row(
                children: [
                  Icon(
                    allHealthy ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                    color: allHealthy ? Colors.green.shade400 : Colors.red.shade400,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          allHealthy ? 'ไม่พบโรค' : 'ตรวจพบโรค',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: allHealthy ? Colors.green.shade700 : Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '📋 $boardName',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: allHealthy ? Colors.green.shade600 : Colors.red.shade600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          createdAt != null ? _formatDateTime(createdAt) : '-',
                          style: TextStyle(
                              fontSize: 12, color: allHealthy ? Colors.green.shade400 : Colors.red.shade400),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: allHealthy ? Colors.green.shade100 : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      allHealthy
                        ? '0/$totalParts'
                        : '$diseasedCount/$totalParts',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: allHealthy ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(Icons.expand_more,
                        color: allHealthy ? Colors.green.shade400 : Colors.red.shade400),
                  ),
                ],
              ),
            ),
          ),

          // Expandable disease list
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: isExpanded
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children:
                          List.generate(diseasedParts.length, (index) {
                        final pred = diseasedParts[index];
                        final label = pred['label'] as String;
                        final confidence = pred['confidence'] as double;
                        final partImageUrl = pred['imageUrl'] as String;
                        final position = pred['position'] as String? ?? '';
                        final probabilities = pred['probabilities']
                                as Map<String, dynamic>? ??
                            {};
                        final color = _getDiseaseColor(label);

                        return Column(
                          children: [
                            // Disease row - tappable to show probabilities popup
                            InkWell(
                              onTap: () => _showProbabilitiesDialog(
                                label: label,
                                confidence: confidence,
                                probabilities: probabilities,
                                imageUrl: partImageUrl,
                                position: position,
                                color: color,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: partImageUrl.isNotEmpty
                                          ? Image.network(
                                              partImageUrl,
                                              width: 56,
                                              height: 56,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (_, __, ___) => Container(
                                                width: 56,
                                                height: 56,
                                                color: Colors.grey.shade200,
                                                child: const Icon(
                                                    Icons
                                                        .image_not_supported,
                                                    size: 24),
                                              ),
                                            )
                                          : Container(
                                              width: 56,
                                              height: 56,
                                              color: Colors.grey.shade200,
                                              child: const Icon(Icons.image,
                                                  size: 24),
                                            ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(_getDiseaseIcon(label),
                                                  size: 16, color: color),
                                              const SizedBox(width: 4),
                                              Text(
                                                label,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: color,
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                '${(confidence * 100).toStringAsFixed(1)}%',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: color,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: LinearProgressIndicator(
                                              value: confidence,
                                              backgroundColor:
                                                  Colors.grey.shade200,
                                              valueColor:
                                                  AlwaysStoppedAnimation<
                                                      Color>(color),
                                              minHeight: 6,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            position,
                                            style: TextStyle(
                                                fontSize: 11,
                                                color:
                                                    Colors.grey.shade500),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            if (index < diseasedParts.length - 1)
                              Divider(
                                  height: 1,
                                  color: Colors.grey.shade200),
                          ],
                        );
                      }),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  void _showProbabilitiesDialog({
    required String label,
    required double confidence,
    required Map<String, dynamic> probabilities,
    required String imageUrl,
    required String position,
    required Color color,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with image
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 72,
                              height: 72,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image_not_supported,
                                  size: 28),
                            ),
                          )
                        : Container(
                            width: 72,
                            height: 72,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image, size: 28),
                          ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(_getDiseaseIcon(label),
                                size: 18, color: color),
                            const SizedBox(width: 6),
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ความมั่นใจ: ${(confidence * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (position.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            position,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),

              // Probabilities
              if (probabilities.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'ความน่าจะเป็น',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...probabilities.entries.map((e) {
                  final prob =
                      (e.value is num) ? (e.value as num).toDouble() : 0.0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(
                            e.key,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: prob,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  _getDiseaseColor(e.key)),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 65,
                          child: Text(
                            '${(prob * 100).toStringAsFixed(2)}%',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ] else
                Text(
                  'ไม่มีข้อมูลความน่าจะเป็น',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              const SizedBox(height: 12),

              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('ปิด'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'เมื่อสักครู่';
    if (diff.inMinutes < 60) return '${diff.inMinutes} นาทีที่แล้ว';
    if (diff.inHours < 24) return '${diff.inHours} ชั่วโมงที่แล้ว';
    if (diff.inDays < 7) return '${diff.inDays} วันที่แล้ว';
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }
}
