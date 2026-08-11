import 'package:flutter/material.dart';
import '../../data/models/board_model.dart';

class BoardSelector extends StatelessWidget {
  final List<BoardModel> boards;
  final String? selectedBoardId;
  final ValueChanged<String> onBoardChanged;
  final VoidCallback? onAddBoard;
  final double? width;

  const BoardSelector({
    super.key,
    required this.boards,
    this.selectedBoardId,
    required this.onBoardChanged,
    this.onAddBoard,
    this.width,
  });

  String get selectedBoardName {
    if (selectedBoardId == null || boards.isEmpty) return 'ไม่มีอุปกรณ์';
    try {
      return boards.firstWhere((d) => d.boardId == selectedBoardId).boardName;
    } catch (e) {
      return 'ไม่มีอุปกรณ์';
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectorWidth = width ?? MediaQuery.of(context).size.width - 32;
    final popupWidth = onAddBoard != null ? selectorWidth - 70 : selectorWidth;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: PopupMenuButton<String>(
              offset: const Offset(0, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              constraints: BoxConstraints(
                minWidth: popupWidth,
                maxWidth: popupWidth,
              ),
              enabled: boards.isNotEmpty,
              onSelected: onBoardChanged,
              itemBuilder: (context) => boards.isEmpty
                  ? [
                      const PopupMenuItem(
                        enabled: false,
                        child: Text(
                          'ไม่มีอุปกรณ์',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    ]
                  : boards
                      .map(
                        (board) => PopupMenuItem(
                          value: board.boardId,
                          child: Row(
                            children: [
                              Icon(
                                Icons.sensors,
                                color: selectedBoardId == board.boardId
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      board.boardName,
                                      style: TextStyle(
                                        fontWeight: selectedBoardId == board.boardId
                                            ? FontWeight.bold
                                            : FontWeight.w600,
                                        color: selectedBoardId == board.boardId
                                            ? Theme.of(context).primaryColor
                                            : null,
                                      ),
                                    ),
                                    Text(
                                      board.boardId,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      boards.isEmpty ? Icons.sensors_off : Icons.sensors,
                      color: boards.isEmpty ? Colors.grey : Colors.green,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedBoardName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: boards.isEmpty ? Colors.grey : null,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: boards.isEmpty ? Colors.grey : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (onAddBoard != null) ...[
            const SizedBox(width: 12),
            Material(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(16),
              elevation: 2,
              child: InkWell(
                onTap: onAddBoard,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
