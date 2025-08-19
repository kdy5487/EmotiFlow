import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../shared/widgets/cards/emoti_card.dart';
import '../../../shared/widgets/buttons/emoti_button.dart';
import '../../diary/models/diary_entry.dart';
import '../../diary/providers/diary_provider.dart';
import '../services/diary_analysis_service.dart';
import '../../../core/ai/gemini/gemini_service.dart';

/// AI 분석 페이지
class AIPage extends ConsumerStatefulWidget {
  const AIPage({super.key});

  @override
  ConsumerState<AIPage> createState() => _AIPageState();
}

class _AIPageState extends ConsumerState<AIPage> {
  bool _isAnalyzing = false;
  DiaryAnalysisResult? _analysisResult;
  String _aiAdvice = '';
  List<String> _insights = [];

  @override
  void initState() {
    super.initState();
    _loadAnalysisData();
  }

  /// 분석 데이터 로드
  Future<void> _loadAnalysisData() async {
    setState(() => _isAnalyzing = true);
    
    try {
      final diaryState = ref.read(diaryProvider);
      final recentEntries = diaryState.diaryEntries.take(7).toList();
      
      if (recentEntries.isNotEmpty) {
        // Gemini AI 분석 서비스 사용
        _analysisResult = await DiaryAnalysisService.instance.analyzeMultipleEntries(recentEntries);
        _aiAdvice = _analysisResult!.advice;
        _insights = [
          ..._analysisResult!.positiveAspects,
          ..._analysisResult!.actionItems,
        ];
      } else {
        _analysisResult = DiaryAnalysisResult(
          summary: '분석할 일기가 없습니다.',
          keywords: [],
          emotionScores: {'평온': 7.0, '기쁨': 6.0, '걱정': 3.0},
          advice: '일기를 더 많이 작성하시면 더 정확한 분석을 제공할 수 있어요.',
          actionItems: ['일기 작성하기'],
          moodTrend: '데이터 부족',
          stressLevel: 0.0,
          positiveAspects: [],
          concernAreas: ['일기 부족'],
          encouragement: '꾸준한 일기 작성으로 감정을 기록해보세요.',
        );
        _aiAdvice = _analysisResult!.advice;
        _insights = ['꾸준한 일기 작성으로 감정을 기록해보세요'];
      }
    } catch (e) {
      print('분석 데이터 로드 실패: $e');
      _analysisResult = null;
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  /// Gemini AI로 개인화된 조언 생성
  Future<void> _generatePersonalizedAdvice() async {
    setState(() => _isAnalyzing = true);
    
    try {
      final diaryState = ref.read(diaryProvider);
      final recentEntries = diaryState.diaryEntries.take(3).toList();
      
      if (recentEntries.isNotEmpty) {
        final latestEntry = recentEntries.first;
        final selectedEmotion = latestEntry.emotions.isNotEmpty ? latestEntry.emotions.first : '평온';
        
        // Gemini AI로 개인화된 조언 생성
        final personalizedAdvice = await GeminiService.instance.analyzeEmotionAndComfort(
          latestEntry.content, 
          selectedEmotion
        );
        
        setState(() {
          _aiAdvice = personalizedAdvice;
          _insights = _extractInsightsFromAdvice(personalizedAdvice);
        });
      }
    } catch (e) {
      print('개인화된 조언 생성 실패: $e');
      setState(() {
        _aiAdvice = 'AI 조언을 생성하는 중 문제가 발생했습니다. 잠시 후 다시 시도해주세요.';
      });
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  /// AI 조언에서 인사이트 추출
  List<String> _extractInsightsFromAdvice(String advice) {
    final insights = <String>[];
    
    if (advice.contains('감정')) {
      insights.add('감정 인식 및 관리');
    }
    if (advice.contains('스트레스')) {
      insights.add('스트레스 관리');
    }
    if (advice.contains('긍정')) {
      insights.add('긍정적 사고');
    }
    if (advice.contains('관계')) {
      insights.add('인간관계 개선');
    }
    if (advice.contains('목표')) {
      insights.add('목표 설정 및 달성');
    }
    
    return insights.isEmpty ? ['자기 성찰'] : insights;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 감정 분석'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isAnalyzing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AI 분석 결과 요약
                  if (_analysisResult != null) ...[
                    _buildAnalysisSummary(),
                    const SizedBox(height: 24),
                  ],
                  
                  // AI 조언 섹션
                  _buildAIAdviceSection(),
                  const SizedBox(height: 24),
                  
                  // 인사이트 섹션
                  _buildInsightsSection(),
                  const SizedBox(height: 24),
                  
                  // 액션 아이템 섹션
                  if (_analysisResult != null) ...[
                    _buildActionItemsSection(),
                    const SizedBox(height: 24),
                  ],
                  
                  // 새로운 조언 생성 버튼
                  _buildGenerateAdviceButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildAnalysisSummary() {
    return EmotiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '감정 분석 요약',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _analysisResult!.summary,
            style: AppTypography.bodyLarge,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip('기분 트렌드', _analysisResult!.moodTrend),
              const SizedBox(width: 8),
              _buildInfoChip('스트레스 레벨', '${_analysisResult!.stressLevel.toStringAsFixed(1)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAIAdviceSection() {
    return EmotiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'AI 조언',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _aiAdvice.isNotEmpty ? _aiAdvice : 'AI 조언을 생성해보세요.',
            style: AppTypography.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection() {
    return EmotiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                '주요 인사이트',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_insights.isNotEmpty)
            ...(_insights.map((insight) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(insight, style: AppTypography.bodyMedium)),
                ],
              ),
            )))
          else
            Text(
              '인사이트를 생성해보세요.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
        ],
      ),
    );
  }

  Widget _buildActionItemsSection() {
    return EmotiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                '실행 계획',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_analysisResult!.actionItems.isNotEmpty)
            ...(_analysisResult!.actionItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.play_arrow, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item, style: AppTypography.bodyMedium)),
                ],
              ),
            )))
          else
            Text(
              '실행 계획이 없습니다.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
        ],
      ),
    );
  }

  Widget _buildGenerateAdviceButton() {
    return EmotiButton(
      text: '새로운 AI 조언 생성',
      onPressed: _generatePersonalizedAdvice,
      isFullWidth: true,
      icon: Icons.refresh,
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}