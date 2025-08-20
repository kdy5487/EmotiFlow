import 'package:flutter/material.dart';

class DiaryErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const DiaryErrorState({
    super.key,
    this.message = '데이터를 불러오는 중 오류가 발생했습니다',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
            ),
          ],
        ],
      ),
    );
  }
}


