import 'package:flutter/material.dart';
import 'package:emoti_flow/features/diary/domain/entities/diary_entry.dart';

class DetailContentSection extends StatelessWidget {
  final DiaryEntry entry;

  const DetailContentSection({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        entry.content,
        style: const TextStyle(
          fontSize: 16,
          height: 1.6,
          color: Color(0xFF111827),
        ),
      ),
    );
  }
}
