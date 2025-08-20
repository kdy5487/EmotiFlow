import 'package:emoti_flow/theme/app_colors.dart';
import 'package:flutter/material.dart';

typedef RemoveFilter = void Function(String key);
typedef ClearAllFilters = void Function();

class DiaryFilterTagsBar extends StatelessWidget {
  final Map<String, dynamic> currentFilters;
  final RemoveFilter onRemoveFilter;
  final ClearAllFilters onClearAll;
  final String Function(String key, dynamic value) getFilterLabel;

  const DiaryFilterTagsBar({
    super.key,
    required this.currentFilters,
    required this.onRemoveFilter,
    required this.onClearAll,
    required this.getFilterLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (currentFilters.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_list, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: currentFilters.entries.map((entry) {
                return Chip(
                  label: Text(
                    getFilterLabel(entry.key, entry.value),
                  ),
                  onDeleted: () => onRemoveFilter(entry.key),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  backgroundColor: AppColors.primary.withOpacity(0.06),
                );
              }).toList(),
            ),
          ),
          if (currentFilters.isNotEmpty)
            TextButton.icon(
              onPressed: onClearAll,
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text('모두 지우기'),
            ),
        ],
      ),
    );
  }
}


