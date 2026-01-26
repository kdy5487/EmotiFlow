import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emoti_flow/features/diary/domain/entities/diary_entry.dart';
import 'package:emoti_flow/core/ai/gemini/gemini_service.dart';

class AIDetailedAnalysisDialog extends ConsumerStatefulWidget {
  final DiaryEntry entry;

  const AIDetailedAnalysisDialog({
    super.key,
    required this.entry,
  });

  @override
  ConsumerState<AIDetailedAnalysisDialog> createState() => _AIDetailedAnalysisDialogState();
}

class _AIDetailedAnalysisDialogState extends ConsumerState<AIDetailedAnalysisDialog> {
  String? _diarySummary;
  String? _detailedAdvice;
  bool _isLoading = true;
  bool _hasGenerated = false;

  @override
  void initState() {
    super.initState();
    _loadAnalysis();
  }

  Future<void> _loadAnalysis() async {
    // aiAnalysis에 이미 분석 결과가 있으면 사용 (재시도 방지)
    if (widget.entry.aiAnalysis != null) {
      setState(() {
        _diarySummary = widget.entry.aiAnalysis!.summary;
        _detailedAdvice = widget.entry.aiAnalysis!.advice;
        _isLoading = false;
      });
      return;
    }

    // 분석 결과가 없고, 최초 1회만 생성
    final prefs = await SharedPreferences.getInstance();
    final generatedKey = 'ai_analysis_generated_${widget.entry.id}';
    final hasGenerated = prefs.getBool(generatedKey) ?? false;

    if (!hasGenerated && !_hasGenerated) {
      // 최초 1회 생성
      _hasGenerated = true;
      await prefs.setBool(generatedKey, true);
      
      setState(() {
        _isLoading = true;
      });

      try {
        final geminiService = GeminiService.instance;
        final summary = await geminiService.generateDetailedDiarySummary(widget.entry);
        final advice = await geminiService.generateDetailedAdvice(widget.entry);
        
        if (mounted) {
          setState(() {
            _diarySummary = summary;
            _detailedAdvice = advice;
            _isLoading = false;
          });
          
          // 알림 표시
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('AI 분석이 생성되었습니다.'),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } catch (e) {
        print('AI 분석 생성 실패: $e');
        if (mounted) {
          setState(() {
            _diarySummary = 'AI 분석 생성에 실패했습니다.';
            _detailedAdvice = '다시 시도해주세요.';
            _isLoading = false;
          });
        }
      }
    } else {
      // 이미 생성했거나 생성 불가
      if (mounted) {
        setState(() {
          _diarySummary = 'AI 분석 결과가 아직 생성되지 않았습니다.';
          _detailedAdvice = '일기를 작성할 때 AI 분석이 자동으로 생성됩니다.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.psychology,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'AI 상세 분석',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    color: theme.colorScheme.onSurface,
                  ),
                ],
              ),
            ),
            // 내용
            Flexible(
              child: _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDiarySummary(theme),
                          const SizedBox(height: 20),
                          _buildDetailedAdvice(theme),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiarySummary(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            Colors.white,
          ],
        ),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.summarize,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '일기 요약',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _diarySummary ?? '일기 요약을 생성하는 중...',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
              height: 1.6,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedAdvice(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            Colors.white,
          ],
        ),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.psychology,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'AI 상세 조언',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _detailedAdvice ?? '상세 조언을 생성하는 중...',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
              height: 1.6,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

}
