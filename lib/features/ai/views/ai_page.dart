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
        // AI 분석 서비스 사용
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

  /// 감정 점수 계산
  Map<String, double> _calculateEmotionScores(List<DiaryEntry> entries) {
    final emotionCounts = <String, List<int>>{};
    
    for (final entry in entries) {
      for (final emotion in entry.emotions) {
        final intensity = entry.emotionIntensities[emotion] ?? 5;
        emotionCounts.putIfAbsent(emotion, () => []).add(intensity);
      }
    }
    
    final scores = <String, double>{};
    emotionCounts.forEach((emotion, intensities) {
      final average = intensities.reduce((a, b) => a + b) / intensities.length;
      scores[emotion] = average;
    });
    
    return scores;
  }

  /// AI 조언 생성
  String _generateAdvice(List<DiaryEntry> entries) {
    final positiveEmotions = ['기쁨', '감사', '평온', '설렘'];
    final negativeEmotions = ['슬픔', '걱정', '분노', '스트레스'];
    
    int positiveCount = 0;
    int negativeCount = 0;
    
    for (final entry in entries) {
      for (final emotion in entry.emotions) {
        if (positiveEmotions.contains(emotion)) positiveCount++;
        if (negativeEmotions.contains(emotion)) negativeCount++;
      }
    }
    
    if (positiveCount > negativeCount) {
      return '최근 긍정적인 감정을 많이 느끼고 계시네요! 이런 좋은 상태를 유지하기 위해 감사한 일들을 계속 기록해보세요.';
    } else if (negativeCount > positiveCount) {
      return '최근 힘든 감정들을 많이 느끼고 계시는군요. 스스로에게 더 친절하게 대해주시고, 작은 기쁨들을 찾아보세요.';
    } else {
      return '감정의 균형을 잘 유지하고 계시네요. 지금처럼 솔직하게 감정을 기록하는 것이 도움이 될 거예요.';
    }
  }

  /// 인사이트 생성
  List<String> _generateInsights(List<DiaryEntry> entries) {
    final insights = <String>[];
    
    // 일기 작성 빈도 분석
    final days = entries.length;
    if (days >= 5) {
      insights.add('꾸준한 일기 작성으로 자기 성찰을 잘하고 계세요');
    } else {
      insights.add('더 자주 일기를 작성하면 감정 패턴을 더 잘 파악할 수 있어요');
    }
    
    // AI 대화 사용 분석
    final aiChatCount = entries.where((e) => e.diaryType == DiaryType.aiChat).length;
    if (aiChatCount > 0) {
      insights.add('AI와의 대화를 통해 감정을 잘 정리하고 계세요');
    } else {
      insights.add('AI 대화형 일기도 시도해보세요. 새로운 관점을 얻을 수 있어요');
    }
    
    // 감정 다양성 분석
    final uniqueEmotions = entries.expand((e) => e.emotions).toSet();
    if (uniqueEmotions.length >= 5) {
      insights.add('다양한 감정을 솔직하게 표현하고 계시네요');
    } else {
      insights.add('더 다양한 감정 표현을 시도해보세요');
    }
    
    return insights;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI 분석',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadAnalysisData,
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: '분석 새로고침',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAnalysisData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AI 분석 소개
              _buildIntroCard(),
              const SizedBox(height: 24),
              
              // 감정 분석 결과
              _buildEmotionAnalysis(),
              const SizedBox(height: 24),
              
              // AI 조언 카드
              _buildAIAdviceCard(),
              const SizedBox(height: 24),
              
              // 인사이트 카드
              _buildInsightsCard(),
              const SizedBox(height: 24),
              
              // 감정 시각화
              _buildEmotionVisualization(),
              const SizedBox(height: 24),
              
              // 위로 및 격려 섹션
              _buildEncouragementSection(),
              const SizedBox(height: 24),
              
              // 스트레스 레벨 및 관리
              _buildStressManagementSection(),
              const SizedBox(height: 24),
              
              // 대화형 인터페이스
              _buildChatInterface(),
              
              // 하단 여백
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  /// AI 분석 소개 카드
  Widget _buildIntroCard() {
    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Text(
                  'AI 감정 분석 서비스',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'AI가 당신의 일기를 분석하여 감정 상태와 맞춤형 조언을 제공합니다.',
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: EmotiButton(
                    text: 'AI와 대화 시작',
                    onPressed: () => context.push('/diary/chat-write'),
                    type: EmotiButtonType.primary,
                    icon: Icons.chat,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: EmotiButton(
                    text: '분석 새로고침',
                    onPressed: _loadAnalysisData,
                    type: EmotiButtonType.secondary,
                    icon: Icons.refresh,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 감정 분석 결과
  Widget _buildEmotionAnalysis() {
    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite, color: Colors.red[400], size: 24),
                const SizedBox(width: 12),
                Text(
                  '최근 감정 분석',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            if (_isAnalyzing)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_analysisResult == null || _analysisResult!.emotionScores.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    '분석할 일기가 없습니다.\n일기를 작성해주세요.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              )
            else
              ..._analysisResult!.emotionScores.entries.map((entry) => 
                _buildEmotionScore(entry.key, entry.value)
              ).toList(),
          ],
        ),
      ),
    );
  }

  /// 감정 점수 위젯
  Widget _buildEmotionScore(String emotion, double score) {
    final color = _getEmotionColor(emotion);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                emotion,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${score.toStringAsFixed(1)}/10',
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: score / 10,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  /// 감정별 색상 가져오기
  Color _getEmotionColor(String emotion) {
    switch (emotion) {
      case '기쁨': return Colors.yellow[600]!;
      case '슬픔': return Colors.blue[600]!;
      case '분노': return Colors.red[600]!;
      case '평온': return Colors.green[600]!;
      case '설렘': return Colors.pink[600]!;
      case '걱정': return Colors.orange[600]!;
      case '감사': return Colors.purple[600]!;
      case '지루함': return Colors.grey[600]!;
      default: return Colors.blue[600]!;
    }
  }

  /// AI 조언 카드
  Widget _buildAIAdviceCard() {
    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber[600], size: 24),
                const SizedBox(width: 12),
                Text(
                  'AI 조언',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Text(
                _aiAdvice.isEmpty ? '분석 중입니다...' : _aiAdvice,
                style: AppTypography.bodyMedium.copyWith(
                  height: 1.6,
                  color: Colors.amber[800],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 인사이트 카드
  Widget _buildInsightsCard() {
    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights, color: Colors.blue[600], size: 24),
                const SizedBox(width: 12),
                Text(
                  '인사이트',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._insights.map((insight) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.arrow_right,
                    color: Colors.blue[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      insight,
                      style: AppTypography.bodyMedium.copyWith(
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  /// 감정 시각화
  Widget _buildEmotionVisualization() {
    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.purple[600], size: 24),
                const SizedBox(width: 12),
                Text(
                  '감정 시각화',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '감정 차트',
                      style: AppTypography.bodyLarge.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '더 많은 일기를 작성하면\n상세한 차트를 볼 수 있어요',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 위로 및 격려 섹션
  Widget _buildEncouragementSection() {
    final encouragement = _analysisResult?.encouragement ?? '오늘도 자신의 감정을 기록해주셔서 감사해요.';
    
    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite, color: Colors.pink[400], size: 24),
                const SizedBox(width: 12),
                Text(
                  '따뜻한 위로',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.pink[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.pink[200]!),
              ),
              child: Text(
                encouragement,
                style: AppTypography.bodyMedium.copyWith(
                  height: 1.6,
                  color: Colors.pink[800],
                ),
              ),
            ),
            if (_analysisResult != null && _analysisResult!.concernAreas.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                '관심이 필요한 영역:',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ..._analysisResult!.concernAreas.map((concern) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange[600], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        concern,
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ],
          ],
        ),
      ),
    );
  }

  /// 스트레스 레벨 및 관리 섹션
  Widget _buildStressManagementSection() {
    final stressLevel = _analysisResult?.stressLevel ?? 0.0;
    final actionItems = _analysisResult?.actionItems ?? [];
    
    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.health_and_safety, color: Colors.green[600], size: 24),
                const SizedBox(width: 12),
                Text(
                  '스트레스 관리',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 스트레스 레벨 표시
            Row(
              children: [
                Text(
                  '현재 스트레스 레벨: ',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${(stressLevel * 100).toInt()}%',
                  style: AppTypography.bodyMedium.copyWith(
                    color: _getStressColor(stressLevel),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: stressLevel,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(_getStressColor(stressLevel)),
              minHeight: 8,
            ),
            const SizedBox(height: 16),
            
            // 실행 항목
            if (actionItems.isNotEmpty) ...[
              Text(
                '추천 실행 항목:',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ...actionItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.green[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: AppTypography.bodyMedium.copyWith(
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ],
          ],
        ),
      ),
    );
  }

  /// 스트레스 레벨에 따른 색상 반환
  Color _getStressColor(double stressLevel) {
    if (stressLevel < 0.3) {
      return Colors.green[600]!;
    } else if (stressLevel < 0.6) {
      return Colors.orange[600]!;
    } else {
      return Colors.red[600]!;
    }
  }

  /// 대화형 인터페이스
  Widget _buildChatInterface() {
    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.chat_bubble, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  'AI와 대화하기',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'AI와 대화하며 더 깊은 감정 분석과 맞춤형 조언을 받아보세요.',
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: EmotiButton(
                    text: 'AI 대화 시작',
                    onPressed: () => context.push('/diary/chat-write'),
                    type: EmotiButtonType.primary,
                    icon: Icons.chat,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: EmotiButton(
                    text: '일기 목록',
                    onPressed: () => context.push('/diary'),
                    type: EmotiButtonType.secondary,
                    icon: Icons.list,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}