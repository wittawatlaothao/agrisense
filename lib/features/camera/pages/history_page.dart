import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/prediction_history.dart';
import '../../../data/repositories/prediction_history_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _DetailView extends StatelessWidget {
  final PredictionHistory history;
  final Function(String) onDelete;

  const _DetailView({
    required this.history,
    required this.onDelete,
  });

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'เมื่อสักครู่';
        }
        return '${difference.inMinutes} นาทีที่แล้ว';
      }
      return '${difference.inHours} ชั่วโมงที่แล้ว';
    } else if (difference.inDays == 1) {
      return 'เมื่อวาน ${DateFormat('HH:mm').format(dateTime)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} วันที่แล้ว';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text('ต้องการลบรายการนี้หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onDelete(history.id);
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียด'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // รูปภาพ
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 250,
                width: double.infinity,
                color: Colors.white,
                child: history.imageUrl != null
                    ? Image.network(
                        history.imageUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.error_outline, size: 64),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Icon(Icons.image_not_supported, size: 64),
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // Label
            Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.eco, color: Colors.green),
                title: const Text(
                  'ผลการวิเคราะห์',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  history.label,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Confidence
            Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.analytics, color: Colors.blue),
                title: const Text(
                  'ความมั่นใจ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${(history.confidence * 100).toStringAsFixed(2)}%',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: history.confidence,
                      minHeight: 8,
                    ),
                  ],
                ),
              ),
            ),

            // Probabilities
            if (history.probabilities != null && history.probabilities!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.pie_chart, color: Colors.orange),
                          SizedBox(width: 8),
                          Text(
                            'ความน่าจะเป็นของแต่ละประเภท',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...history.probabilities!.entries.map((entry) {
                        final className = entry.key;
                        final probability = (entry.value as num).toDouble();
                        final percentage = probability * 100;
                        final color = probability >= 0.7
                            ? Colors.green
                            : probability >= 0.5
                                ? Colors.orange
                                : Colors.red;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    className,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${percentage.toStringAsFixed(2)}%',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: probability,
                                  minHeight: 6,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(color),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Timestamp
            Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.access_time, color: Colors.grey),
                title: const Text(
                  'เวลา',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(_formatDateTime(history.timestamp)),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _HistoryPageState extends State<HistoryPage> {
  final PredictionHistoryService _historyService = PredictionHistoryService();

  Future<void> _confirmClearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text('ต้องการลบประวัติทั้งหมดหรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ลบทั้งหมด'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _historyService.clearAllHistory();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ลบประวัติทั้งหมดแล้ว'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('เกิดข้อผิดพลาด: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteHistory(String historyId) async {
    try {
      await _historyService.deleteHistory(historyId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ลบรายการแล้ว'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ประวัติการตรวจสอบ'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'ลบทั้งหมด',
            onPressed: _confirmClearAll,
          ),
        ],
      ),
      body: StreamBuilder<List<PredictionHistory>>(
        stream: _historyService.getUserHistory(limit: 30),
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
                  Text(
                    'เกิดข้อผิดพลาด',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: TextStyle(color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final histories = snapshot.data ?? [];

          if (histories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'ยังไม่มีประวัติการตรวจสอบ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'เริ่มต้นถ่ายภาพเพื่อตรวจสอบโรคพืช',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: histories.length,
            itemBuilder: (context, index) {
              final history = histories[index];
              final confidenceColor = history.confidence >= 0.8
                  ? Colors.green
                  : history.confidence >= 0.6
                      ? Colors.orange
                      : Colors.red;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _DetailView(
                          history: history,
                          onDelete: _deleteHistory,
                        ),
                      ),
                    );
                  },
                  leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade200,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: history.imageUrl != null
                          ? Image.network(
                              history.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.agriculture,
                                  size: 32,
                                  color: Colors.grey.shade400,
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    strokeWidth: 2,
                                  ),
                                );
                              },
                            )
                          : Icon(
                              Icons.agriculture,
                              size: 32,
                              color: Colors.grey.shade400,
                            ),
                    ),
                  ),
                  title: Text(
                    history.label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.analytics,
                              size: 14, color: confidenceColor),
                          const SizedBox(width: 4),
                          Text(
                            'ความมั่นใจ: ${(history.confidence * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 13,
                              color: confidenceColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            _formatDateTime(history.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('ยืนยันการลบ'),
                          content: const Text('ต้องการลบรายการนี้หรือไม่?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('ยกเลิก'),
                            ),
                            TextButton(
                              onPressed: () {
                                _deleteHistory(history.id);
                                Navigator.of(ctx).pop();
                              },
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.red),
                              child: const Text('ลบ'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'เมื่อสักครู่';
        }
        return '${difference.inMinutes} นาทีที่แล้ว';
      }
      return '${difference.inHours} ชั่วโมงที่แล้ว';
    } else if (difference.inDays == 1) {
      return 'เมื่อวาน ${DateFormat('HH:mm').format(dateTime)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} วันที่แล้ว';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    }
  }
}
