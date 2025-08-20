import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/diary_entry.dart';
import '../../../providers/diary_provider.dart';

/// 삭제할 일기 선택 시트
class DeleteSelectionSheet extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final Function(List<DiaryEntry>) onDeleteSelected;

  const DeleteSelectionSheet({
    super.key,
    required this.scrollController,
    required this.onDeleteSelected,
  });

  @override
  ConsumerState<DeleteSelectionSheet> createState() => _DeleteSelectionSheetState();
}

class _DeleteSelectionSheetState extends ConsumerState<DeleteSelectionSheet> {
  final Set<String> _selectedEntryIds = {};

  @override
  Widget build(BuildContext context) {
    final diaryState = ref.watch(diaryProvider);
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 핸들
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // 헤더
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  '삭제할 일기 선택',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_selectedEntryIds.isNotEmpty)
                  Text(
                    '${_selectedEntryIds.length}개 선택됨',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
          
          const Divider(height: 20),
          
          // 일기 목록
          Expanded(
            child: diaryState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : diaryState.errorMessage != null
                    ? Center(child: Text('오류가 발생했습니다: ${diaryState.errorMessage}'))
                    : diaryState.diaryEntries.isEmpty
                        ? const Center(child: Text('삭제할 일기가 없습니다.'))
                        : ListView.builder(
                            controller: widget.scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: diaryState.diaryEntries.length,
                            itemBuilder: (context, index) {
                              final entry = diaryState.diaryEntries[index];
                              final isSelected = _selectedEntryIds.contains(entry.id);
                              
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.red.withOpacity(0.1) : Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: isSelected 
                                      ? Border.all(color: Colors.red, width: 2)
                                      : Border.all(color: Colors.grey[200]!),
                                ),
                                child: CheckboxListTile(
                                  value: isSelected,
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedEntryIds.add(entry.id);
                                      } else {
                                        _selectedEntryIds.remove(entry.id);
                                      }
                                    });
                                  },
                                  title: Text(
                                    entry.title.isNotEmpty ? entry.title : '제목 없음',
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.content,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${entry.createdAt.year}.${entry.createdAt.month.toString().padLeft(2, '0')}.${entry.createdAt.day.toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  activeColor: Colors.red,
                                  controlAffinity: ListTileControlAffinity.leading,
                                ),
                              );
                            },
                          ),
          ),
          
          // 하단 버튼들
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('취소'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedEntryIds.isEmpty
                        ? null
                        : () {
                            final diaryStateValue = ref.read(diaryProvider);
                            final selectedEntries = diaryStateValue.diaryEntries
                                .where((entry) => _selectedEntryIds.contains(entry.id))
                                .toList();
                            
                            Navigator.of(context).pop();
                            widget.onDeleteSelected(selectedEntries);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('삭제 (${_selectedEntryIds.length})'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


