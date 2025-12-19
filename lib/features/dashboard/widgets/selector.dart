import 'package:flutter/material.dart';

class FarmSelector extends StatelessWidget {
  final List<Map<String, String>> farms;
  final String selectedFarmId;
  final ValueChanged<String> onFarmChanged;
  final VoidCallback? onAddFarm;
  final double? width;

  const FarmSelector({
    super.key,
    required this.farms,
    required this.selectedFarmId,
    required this.onFarmChanged,
    this.onAddFarm,
    this.width,
  });

  String get selectedFarmName =>
      farms.firstWhere((f) => f["id"] == selectedFarmId)["name"]!;

  @override
  Widget build(BuildContext context) {
    final selectorWidth = width ?? MediaQuery.of(context).size.width - 32;

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
                minWidth: selectorWidth - 70,
                maxWidth: selectorWidth - 70,
              ),
              onSelected: onFarmChanged,
              itemBuilder: (context) => farms
            .map(
              (farm) => PopupMenuItem(
                value: farm["id"],
                child: Row(
                  children: [
                    Icon(
                      Icons.agriculture,
                      color: selectedFarmId == farm["id"]
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      farm["name"]!,
                      style: TextStyle(
                        fontWeight: selectedFarmId == farm["id"]
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: selectedFarmId == farm["id"]
                            ? Theme.of(context).primaryColor
                            : null,
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
              const Icon(Icons.agriculture, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  selectedFarmName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
            ],
          ),
        ),
            ),
          ),
          if (onAddFarm != null) ...[
            const SizedBox(width: 12),
            Material(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(16),
              elevation: 2,
              child: InkWell(
                onTap: onAddFarm,
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
