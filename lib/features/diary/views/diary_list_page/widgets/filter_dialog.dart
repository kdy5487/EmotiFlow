import 'package:emoti_flow/theme/app_colors.dart';
import 'package:emoti_flow/theme/app_typography.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/emotion.dart';

class FilterDialog extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onFiltersChanged;

  const FilterDialog({super.key, required this.currentFilters, required this.onFiltersChanged});

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late Map<String, dynamic> _filters;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.currentFilters);
    _startDate = _filters['startDate'];
    _endDate = _filters['endDate'];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.filter_list, color: AppColors.primary),
          SizedBox(width: 8),
          Text('필터 설정', style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildEmotionFilter(),
            const SizedBox(height: 20),
            _buildDateRangeFilter(),
            const SizedBox(height: 20),
            _buildOtherFilters(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              _filters.clear();
              _startDate = null;
              _endDate = null;
            });
          },
          child: Text('초기화', style: TextStyle(color: Colors.grey[600])),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('취소', style: TextStyle(color: Colors.grey[600])),
        ),
        ElevatedButton(
          onPressed: () {
            if (_startDate != null) _filters['startDate'] = _startDate;
            if (_endDate != null) _filters['endDate'] = _endDate;
            widget.onFiltersChanged(_filters);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('적용'),
        ),
      ],
    );
  }

  Widget _buildEmotionFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.emoji_emotions, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text('감정별 필터', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: Emotion.basicEmotions.map((emotion) {
            final isSelected = _filters['emotion'] == emotion.name;
            return FilterChip(
              label: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(emotion.emoji), const SizedBox(width: 6), Text(emotion.name, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
              ]),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _filters['emotion'] = emotion.name;
                  } else {
                    _filters.remove('emotion');
                  }
                });
              },
              selectedColor: emotion.color.withOpacity(0.2),
              checkmarkColor: emotion.color,
              labelStyle: TextStyle(color: isSelected ? emotion.color : AppColors.textSecondary),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text('날짜 범위', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _buildDateButton(isStartDate: true, date: _startDate, label: '시작일', onTap: () => _selectDate(true))),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('~', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500))),
          Expanded(child: _buildDateButton(isStartDate: false, date: _endDate, label: '종료일', onTap: () => _selectDate(false))),
        ]),
      ],
    );
  }

  Widget _buildDateButton({required bool isStartDate, required DateTime? date, required String label, required VoidCallback onTap}) {
    final hasDate = date != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: hasDate ? AppColors.primary.withOpacity(0.1) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: hasDate ? AppColors.primary : Colors.grey[300]!, width: hasDate ? 2 : 1),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.calendar_today, size: 16, color: hasDate ? AppColors.primary : Colors.grey[600]),
            const SizedBox(width: 8),
            Text(hasDate ? '${date.month}/${date.day}' : label, style: TextStyle(color: hasDate ? AppColors.primary : Colors.grey[600], fontWeight: hasDate ? FontWeight.w600 : FontWeight.normal, fontSize: 12)),
          ]),
        ),
      ),
    );
  }

  Widget _buildOtherFilters() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.tune, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text('기타 옵션', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600)),
      ]),
      const SizedBox(height: 12),
      _buildCheckboxOption(
        title: 'AI 분석 완료된 일기만', subtitle: 'AI가 분석한 일기만 표시', icon: Icons.psychology, value: _filters['hasAIAnalysis'] == true,
        onChanged: (value) => setState(() => value == true ? _filters['hasAIAnalysis'] = true : _filters.remove('hasAIAnalysis')),
      ),
      _buildCheckboxOption(
        title: '미디어가 첨부된 일기만', subtitle: '사진이나 파일이 첨부된 일기만 표시', icon: Icons.image, value: _filters['hasMedia'] == true,
        onChanged: (value) => setState(() => value == true ? _filters['hasMedia'] = true : _filters.remove('hasMedia')),
      ),
    ]);
  }

  Widget _buildCheckboxOption({required String title, required String subtitle, required IconData icon, required bool value, required ValueChanged<bool?> onChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: value ? AppColors.primary.withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: value ? AppColors.primary.withOpacity(0.3) : Colors.grey[200]!),
      ),
      child: CheckboxListTile(
        title: Row(children: [
          Icon(icon, color: value ? AppColors.primary : Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: value ? AppColors.primary : AppColors.textPrimary)),
            Text(subtitle, style: TextStyle(fontSize: 11, color: value ? AppColors.primary.withOpacity(0.7) : Colors.grey[600])),
          ])),
        ]),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }
}


