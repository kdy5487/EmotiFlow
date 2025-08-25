import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:emoti_flow/theme/app_theme.dart';
import 'package:emoti_flow/theme/app_typography.dart';
import 'package:emoti_flow/shared/widgets/cards/emoti_card.dart';
import 'package:emoti_flow/features/diary/providers/diary_provider.dart';
import 'package:emoti_flow/features/diary/models/diary_entry.dart';
import 'package:emoti_flow/shared/widgets/charts/bar_chart_painter.dart';
import 'package:emoti_flow/core/ai/gemini/gemini_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AIPage extends ConsumerStatefulWidget {
  const AIPage({super.key});

  @override
  ConsumerState<AIPage> createState() => _AIPageState();
}

class _AIPageState extends ConsumerState<AIPage> {
  String _selectedPeriod = 'weekly'; // 'weekly' or 'monthly'

  final List<Map<String, dynamic>> _adviceCards = [
    {
      'id': 'nature',
      'title': '자연과 힐링',
      'icon': Icons.nature,
      'color': Colors.green,
      'category': 'nature',
    },
    {
      'id': 'gratitude',
      'title': '감사와 성찰',
      'icon': Icons.favorite,
      'color': Colors.red,
      'category': 'gratitude',
    },
    {
      'id': 'growth',
      'title': '새로운 시작',
      'icon': Icons.trending_up,
      'color': Colors.blue,
      'category': 'growth',
    },
    {
      'id': 'relationship',
      'title': '관계와 소통',
      'icon': Icons.people,
      'color': Colors.purple,
      'category': 'relationship',
    },
    {
      'id': 'selfcare',
      'title': '자기 돌봄',
      'icon': Icons.spa,
      'color': Colors.orange,
      'category': 'selfcare',
    },
    {
      'id': 'creativity',
      'title': '창의적 활동',
      'icon': Icons.brush,
      'color': Colors.teal,
      'category': 'creativity',
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'AI 감정 분석',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              _showSnackBar('공유 기능은 추후 업데이트 예정입니다.');
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16), // 가로 여백 더 줄임
        itemCount: 4,
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return Column(
                children: [
                  _buildEmotionSummaryCard(),
                  const SizedBox(height: 16),
                ],
              );
            case 1:
              return Column(
                children: [
                  _buildEmotionTrendsChart(),
                  const SizedBox(height: 16),
                ],
              );
            case 2:
              return Column(
                children: [
                  _buildPersonalizedAdviceSection(),
                  const SizedBox(height: 16),
                ],
              );
            case 3:
              return _buildAdviceCardSection();
            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  // 감정 요약 카드
  Widget _buildEmotionSummaryCard() {
    return Consumer(
      builder: (context, ref, child) {
        final diaryState = ref.watch(diaryProvider);
        final entries = diaryState.diaryEntries;

        if (entries.isEmpty) {
          return EmotiCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.sentiment_neutral, size: 48, color: AppTheme.textSecondary),
                  const SizedBox(height: 16),
                  Text(
                    '아직 일기 기록이 없습니다',
                    style: AppTypography.titleMedium.copyWith(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '일기를 작성하면 AI가 감정을 분석해드려요!',
                    style: AppTypography.bodyMedium.copyWith(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          );
        }

        final recentEntries = entries.take(7).toList();
        final emotionCounts = <String, int>{};
        for (final entry in recentEntries) {
          for (final emotion in entry.emotions) {
            emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + 1;
          }
        }

        final dominantEmotion = emotionCounts.isEmpty 
            ? '평온' 
            : emotionCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

        return EmotiCard(
          child: Padding(
            padding: const EdgeInsets.all(24), // 패딩 증가로 더 넓게
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.psychology, color: AppTheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      'AI 감정 분석 요약',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '최근 7일간의 감정 분석',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '주요 감정: $dominantEmotion',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '분석된 일기: ${recentEntries.length}개',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 감정 트렌드 차트
  Widget _buildEmotionTrendsChart() {
    return Consumer(
      builder: (context, ref, child) {
        final diaryState = ref.watch(diaryProvider);
        final entries = diaryState.diaryEntries;

        return EmotiCard(
          child: Padding(
            padding: const EdgeInsets.all(24), // 패딩 증가로 더 넓게
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.trending_up, color: AppTheme.info),
                    const SizedBox(width: 12),
                    Text(
                      '감정 변화 트렌드',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('분석 기간: ', style: AppTypography.bodyMedium),
                    GestureDetector(
                      onTap: () => setState(() => _selectedPeriod = 'weekly'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _selectedPeriod == 'weekly' 
                              ? AppTheme.primary 
                              : AppTheme.background,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.primary),
                        ),
                        child: Text(
                          '주간',
                          style: AppTypography.bodySmall.copyWith(
                            color: _selectedPeriod == 'weekly' 
                                ? Colors.white 
                                : AppTheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() => _selectedPeriod = 'monthly'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _selectedPeriod == 'monthly' 
                              ? AppTheme.primary 
                              : AppTheme.background,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.primary),
                        ),
                        child: Text(
                          '월간',
                          style: AppTypography.bodySmall.copyWith(
                            color: _selectedPeriod == 'monthly' 
                                ? Colors.white 
                                : AppTheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // 막대 차트 - 가로 공간 최대 활용
                Container(
                  height: 450,
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _selectedPeriod == 'weekly'
                      ? _buildWeeklyBarChart(entries)
                      : _buildMonthlyBarChart(entries),
                ),
                const SizedBox(height: 16),
                // AI 분석 결과 텍스트
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.info.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.info.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.psychology, color: AppTheme.info, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'AI 분석 결과',
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.info,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _selectedPeriod == 'weekly'
                            ? _generateWeeklyAnalysisText(entries)
                            : _generateMonthlyAnalysisText(entries),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppTheme.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 주간 막대 차트
  Widget _buildWeeklyBarChart(List<DiaryEntry> entries) {
    final chartData = _getWeeklyChartData(entries);
    
    if (chartData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 20),
            Text(
              '주간 감정 기록이 없습니다',
              style: AppTypography.titleMedium.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '일기를 작성하면 감정 변화를 확인할 수 있어요',
              style: AppTypography.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final data = chartData.map((e) => e['intensity'] as double).toList();
    final labels = chartData.map((e) => e['label'] as String).toList();

    return CustomPaint(
      size: const Size(double.infinity, 320),
      painter: BarChartPainter(
        data: data,
        labels: labels,
        primaryColor: AppTheme.primary,
        maxValue: 10.0,
      ),
    );
  }

  // 월간 막대 차트
  Widget _buildMonthlyBarChart(List<DiaryEntry> entries) {
    final chartData = _getMonthlyChartData(entries);
    
    if (chartData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              '월간 감정 기록이 없습니다',
              style: AppTypography.titleMedium.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '일기를 작성하면 감정 변화를 확인할 수 있어요',
              style: AppTypography.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final data = chartData.map((e) => e['intensity'] as double).toList();
    final labels = chartData.map((e) => e['label'] as String).toList();

    return CustomPaint(
      size: const Size(double.infinity, 320),
      painter: BarChartPainter(
        data: data,
        labels: labels,
        primaryColor: AppTheme.secondary,
        maxValue: 10.0,
      ),
    );
  }

  // 주간 차트 데이터
  List<Map<String, dynamic>> _getWeeklyChartData(List<DiaryEntry> entries) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekData = List.filled(7, 0.0);
    final labels = ['월', '화', '수', '목', '금', '토', '일'];

    for (final entry in entries) {
      final entryDate = entry.createdAt is DateTime ? entry.createdAt : (entry.createdAt as dynamic).toDate();
      final daysDiff = entryDate.difference(weekStart).inDays;
      if (daysDiff >= 0 && daysDiff < 7) {
        final intensity = entry.emotionIntensities.values.isNotEmpty 
            ? entry.emotionIntensities.values.first.toDouble() 
            : 5.0;
        weekData[daysDiff] = intensity;
      }
    }

    return List.generate(7, (index) => {
      'intensity': weekData[index],
      'label': labels[index],
    });
  }

  // 월간 차트 데이터
  List<Map<String, dynamic>> _getMonthlyChartData(List<DiaryEntry> entries) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final weekData = List.filled(4, 0.0);
    final weekCounts = List.filled(4, 0);
    final labels = ['1주', '2주', '3주', '4주'];

    for (final entry in entries) {
      final entryDate = entry.createdAt is DateTime ? entry.createdAt : (entry.createdAt as dynamic).toDate();
      if (entryDate.isAfter(monthStart)) {
        final weekIndex = ((entryDate.day - 1) / 7).floor();
        if (weekIndex >= 0 && weekIndex < 4) {
          final intensity = entry.emotionIntensities.values.isNotEmpty 
              ? entry.emotionIntensities.values.first.toDouble() 
              : 5.0;
          weekData[weekIndex] += intensity;
          weekCounts[weekIndex]++;
        }
      }
    }

    // 평균 계산
    for (int i = 0; i < 4; i++) {
      if (weekCounts[i] > 0) {
        weekData[i] /= weekCounts[i];
      }
    }

    return List.generate(4, (index) => {
      'intensity': weekData[index],
      'label': labels[index],
    });
  }

  // 주간 분석 텍스트 생성
  String _generateWeeklyAnalysisText(List<DiaryEntry> entries) {
    if (entries.isEmpty) return '주간 데이터가 부족합니다.';
    
    final dominantEmotion = _getDominantEmotion(entries);
    final avgIntensity = _calculateAverageIntensity(entries);
    final emotionVariety = _calculateEmotionVariety(entries);
    final weeklyPattern = _analyzeWeeklyPattern(entries);
    
    String analysis = '이번 주는 주로 $dominantEmotion 감정을 경험하셨네요. ';
    analysis += '평균 강도는 ${avgIntensity.toStringAsFixed(1)}/10으로 ';
    analysis += '${avgIntensity > 7 ? '매우 강한' : avgIntensity > 4 ? '보통' : '약한'} 감정 상태입니다. ';
    
    if (emotionVariety > 0.7) {
      analysis += '다양한 감정을 경험하고 있어 감정 표현이 풍부하시네요. ';
    } else if (emotionVariety > 0.4) {
      analysis += '비교적 안정적인 감정 상태를 유지하고 계세요. ';
    } else {
      analysis += '감정 변화가 적어 안정적인 한 주를 보내고 계세요. ';
    }
    
    if (weeklyPattern.isNotEmpty) {
      analysis += weeklyPattern;
    }
    
    return analysis;
  }

  // 월간 분석 텍스트 생성
  String _generateMonthlyAnalysisText(List<DiaryEntry> entries) {
    if (entries.isEmpty) return '월간 데이터가 부족합니다.';
    
    final dominantEmotion = _getDominantEmotion(entries);
    final avgIntensity = _calculateAverageIntensity(entries);
    final monthlyTrend = _analyzeMonthlyTrend(entries);
    final emotionStability = _calculateEmotionStability(entries);
    
    String analysis = '이번 달은 주로 $dominantEmotion 감정을 경험하셨네요. ';
    analysis += '평균 강도는 ${avgIntensity.toStringAsFixed(1)}/10으로 ';
    analysis += '${avgIntensity > 7 ? '매우 강한' : avgIntensity > 4 ? '보통' : '약한'} 감정 상태입니다. ';
    
    if (emotionStability > 0.8) {
      analysis += '감정이 매우 안정적으로 유지되고 있어요. ';
    } else if (emotionStability > 0.6) {
      analysis += '감정에 약간의 변화가 있지만 전반적으로 안정적입니다. ';
    } else {
      analysis += '감정 변화가 다소 크게 나타나고 있어요. ';
    }
    
    if (monthlyTrend.isNotEmpty) {
      analysis += monthlyTrend;
    }
    
    return analysis;
  }

  // 지배적인 감정 찾기
  String _getDominantEmotion(List<DiaryEntry> entries) {
    if (entries.isEmpty) return '평온';
    
    final emotionCounts = <String, int>{};
    for (final entry in entries) {
      for (final emotion in entry.emotions) {
        emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + 1;
      }
    }
    
    if (emotionCounts.isEmpty) return '평온';
    
    final dominant = emotionCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    
    return dominant.key;
  }

  // 평균 강도 계산
  double _calculateAverageIntensity(List<DiaryEntry> entries) {
    if (entries.isEmpty) return 5.0;
    
    double totalIntensity = 0.0;
    int count = 0;
    
    for (final entry in entries) {
      if (entry.emotionIntensities.isNotEmpty) {
        totalIntensity += entry.emotionIntensities.values.first.toDouble();
        count++;
      }
    }
    
    return count > 0 ? totalIntensity / count : 5.0;
  }

  // 감정 다양성 계산
  double _calculateEmotionVariety(List<DiaryEntry> entries) {
    if (entries.isEmpty) return 0.0;
    
    final uniqueEmotions = <String>{};
    for (final entry in entries) {
      uniqueEmotions.addAll(entry.emotions);
    }
    
    // 감정 종류가 많을수록 높은 값 (0.0 ~ 1.0)
    return uniqueEmotions.length / 8.0; // 8가지 기본 감정 기준
  }

  // 주간 패턴 분석
  String _analyzeWeeklyPattern(List<DiaryEntry> entries) {
    if (entries.length < 3) return '';
    
    final weekData = _getWeeklyChartData(entries);
    final midWeekAvg = (weekData[1]['intensity'] + weekData[2]['intensity'] + weekData[3]['intensity']) / 3;
    final weekendAvg = (weekData[5]['intensity'] + weekData[6]['intensity']) / 2;
    
    if (midWeekAvg > weekendAvg + 2) {
      return '평일에는 감정이 더 강하게 나타나고 주말에는 상대적으로 평온한 패턴을 보이고 있어요.';
    } else if (weekendAvg > midWeekAvg + 2) {
      return '주말에 감정이 더 강하게 나타나고 평일에는 상대적으로 안정적인 패턴을 보이고 있어요.';
    } else {
      return '평일과 주말의 감정 패턴이 비슷하게 나타나고 있어요.';
    }
  }

  // 월간 트렌드 분석
  String _analyzeMonthlyTrend(List<DiaryEntry> entries) {
    if (entries.length < 5) return '';
    
    final monthData = _getMonthlyChartData(entries);
    bool isIncreasing = true;
    bool isDecreasing = true;
    
    for (int i = 1; i < monthData.length; i++) {
      if (monthData[i]['intensity'] <= monthData[i-1]['intensity']) {
        isIncreasing = false;
      }
      if (monthData[i]['intensity'] >= monthData[i-1]['intensity']) {
        isDecreasing = false;
      }
    }
    
    if (isIncreasing) {
      return '한 달 동안 감정 강도가 점진적으로 증가하는 추세를 보이고 있어요.';
    } else if (isDecreasing) {
      return '한 달 동안 감정 강도가 점진적으로 감소하는 추세를 보이고 있어요.';
    } else {
      return '한 달 동안 감정 강도가 일정하게 유지되는 패턴을 보이고 있어요.';
    }
  }

  // 감정 안정성 계산
  double _calculateEmotionStability(List<DiaryEntry> entries) {
    if (entries.length < 2) return 1.0;
    
    double totalVariation = 0.0;
    int count = 0;
    
    for (int i = 1; i < entries.length; i++) {
      final prevIntensity = entries[i-1].emotionIntensities.values.isNotEmpty 
          ? entries[i-1].emotionIntensities.values.first.toDouble() 
          : 5.0;
      final currIntensity = entries[i].emotionIntensities.values.isNotEmpty 
          ? entries[i].emotionIntensities.values.first.toDouble() 
          : 5.0;
      
      totalVariation += (currIntensity - prevIntensity).abs();
      count++;
    }
    
    // 변화가 적을수록 높은 값 (0.0 ~ 1.0)
    final avgVariation = totalVariation / count;
    return (10.0 - avgVariation) / 10.0;
  }

  // 주간 조언 및 피드백 섹션
  Widget _buildPersonalizedAdviceSection() {
    return Consumer(
      builder: (context, ref, child) {
        final diaryState = ref.watch(diaryProvider);
        final entries = diaryState.diaryEntries;

        return EmotiCard(
          child: Padding(
            padding: const EdgeInsets.all(24), // 패딩 증가로 더 넓게
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.psychology, color: AppTheme.warning),
                    const SizedBox(width: 12),
                    Text(
                      '주간 조언 및 피드백',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.warning.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: AppTheme.warning),
                          const SizedBox(width: 8),
                          Text(
                            '이번 주 (${_getCurrentWeekRange()})',
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.warning,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _generateWeeklyAdviceText(entries),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppTheme.textPrimary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: AppTheme.border),
                      const SizedBox(height: 12),
                      Text(
                        '💡 주간 개선 방안',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._generateWeeklyAdviceItems(entries),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 현재 주 범위 가져오기
  String _getCurrentWeekRange() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    return '${weekStart.month}/${weekStart.day} - ${weekEnd.month}/${weekEnd.day}';
  }

  // 주간 조언 텍스트 생성
  String _generateWeeklyAdviceText(List<DiaryEntry> entries) {
    if (entries.isEmpty) return '이번 주 일기 기록이 없습니다.';
    
    final dominantEmotion = _getDominantEmotion(entries);
    final avgIntensity = _calculateAverageIntensity(entries);
    
    return '이번 주는 주로 $dominantEmotion 감정을 경험하셨네요. '
           '감정 강도는 평균 ${avgIntensity.toStringAsFixed(1)}/10으로 '
           '${avgIntensity > 7 ? '매우 강한' : avgIntensity > 4 ? '보통' : '약한'} 상태입니다. '
           '이런 감정 패턴을 바탕으로 개선 방안을 제시해드릴게요.';
  }

  // 주간 조언 아이템 생성
  List<Widget> _generateWeeklyAdviceItems(List<DiaryEntry> entries) {
    if (entries.isEmpty) {
      return [
        _buildAdviceItem('일기를 꾸준히 작성해보세요.'),
        _buildAdviceItem('감정을 기록하는 습관을 만들어보세요.'),
      ];
    }

    final dominantEmotion = _getDominantEmotion(entries);
    final adviceItems = <Widget>[];

    switch (dominantEmotion) {
      case '슬픔':
        adviceItems.addAll([
          _buildAdviceItem('자신에게 친절하게 대해주세요.'),
          _buildAdviceItem('가까운 사람들과 대화해보세요.'),
          _buildAdviceItem('자연 속에서 시간을 보내보세요.'),
        ]);
        break;
      case '분노':
        adviceItems.addAll([
          _buildAdviceItem('깊은 숨을 들이마시며 마음을 진정시켜보세요.'),
          _buildAdviceItem('운동이나 산책으로 스트레스를 해소해보세요.'),
          _buildAdviceItem('감정의 원인을 분석해보세요.'),
        ]);
        break;
      case '기쁨':
        adviceItems.addAll([
          _buildAdviceItem('기쁜 순간을 더 오래 기억해보세요.'),
          _buildAdviceItem('주변 사람들과 기쁨을 나누어보세요.'),
          _buildAdviceItem('감사한 마음을 표현해보세요.'),
        ]);
        break;
      default:
        adviceItems.addAll([
          _buildAdviceItem('현재 감정 상태를 잘 관찰해보세요.'),
          _buildAdviceItem('감정 변화에 대해 기록해보세요.'),
          _buildAdviceItem('자신만의 감정 관리 방법을 찾아보세요.'),
        ]);
    }

    return adviceItems;
  }

  // 조언 아이템 위젯
  Widget _buildAdviceItem(String advice) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(top: 8),
            decoration: const BoxDecoration(
              color: AppTheme.warning,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              advice,
              style: AppTypography.bodySmall.copyWith(
                color: AppTheme.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 조언 카드 섹션
  Widget _buildAdviceCardSection() {
    return Consumer(
      builder: (context, ref, child) {
        final diaryState = ref.watch(diaryProvider);
        final entries = diaryState.diaryEntries;
        final adviceCards = _generateDynamicAdviceCards(entries);
        
        // 오늘 선택된 카드 불러오기
        return FutureBuilder<Map<String, dynamic>?>(
          future: _loadTodaySelectedCard(),
          builder: (context, snapshot) {
            final selectedCard = snapshot.data;
            
            return EmotiCard(
              child: Padding(
                padding: const EdgeInsets.all(24), // 패딩 증가로 더 넓게
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.card_giftcard, color: AppTheme.warning),
                        const SizedBox(width: 12),
                        Text(
                          '오늘의 조언 카드',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // 선택된 카드가 있으면 표시
                    if (selectedCard != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: selectedCard['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedCard['color'].withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  selectedCard['icon'],
                                  color: selectedCard['color'],
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    selectedCard['title'],
                                    style: AppTypography.titleSmall.copyWith(
                                      color: selectedCard['color'],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            FutureBuilder<String?>(
                              future: _loadTodayAdviceText(),
                              builder: (context, adviceSnapshot) {
                                if (adviceSnapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                
                                final advice = adviceSnapshot.data ?? '조언을 불러올 수 없습니다.';
                                return Text(
                                  advice,
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppTheme.textPrimary,
                                    height: 1.5,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedCard != null
                              ? '다른 카드로 변경하고 싶다면 카드 선택하기를 눌러주세요! ✨'
                              : '${adviceCards.length}개의 카드 중 하나를 선택해서 오늘의 맞춤형 조언을 받아보세요! ✨',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => context.push('/ai/advice-cards'),
                          icon: const Icon(Icons.card_giftcard, size: 16),
                          label: Text(selectedCard != null ? '카드 변경' : '카드 선택하기'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            textStyle: AppTypography.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // 카드 선택 안내
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.info.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.info.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: AppTheme.info, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '위의 "카드 선택하기" 버튼을 눌러 오늘의 조언 카드를 선택해보세요!',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppTheme.info,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 오늘 선택된 카드 불러오기
  Future<Map<String, dynamic>?> _loadTodaySelectedCard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final lastSelectedDate = prefs.getString('last_advice_card_date');
      
      if (lastSelectedDate == today) {
        final selectedCardId = prefs.getString('selected_advice_card_id');
        if (selectedCardId != null) {
          return _adviceCards.firstWhere(
            (card) => card['id'] == selectedCardId,
            orElse: () => _adviceCards.first,
          );
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 오늘 선택된 카드의 조언 텍스트 불러오기
  Future<String?> _loadTodayAdviceText() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final lastSelectedDate = prefs.getString('last_advice_card_date');
      
      if (lastSelectedDate == today) {
        return prefs.getString('selected_advice_text');
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 동적 조언 카드 생성
  List<Map<String, dynamic>> _generateDynamicAdviceCards(List<DiaryEntry> entries) {
    final List<Map<String, dynamic>> allCards = [
      {
        'title': '자연과 힐링',
        'category': 'nature',
        'icon': Icons.park,
        'color': AppTheme.success,
      },
      {
        'title': '감사와 성찰',
        'category': 'gratitude',
        'icon': Icons.favorite,
        'color': AppTheme.error,
      },
      {
        'title': '새로운 시작',
        'category': 'growth',
        'icon': Icons.auto_awesome,
        'color': AppTheme.warning,
      },
      {
        'title': '관계와 소통',
        'category': 'relationship',
        'icon': Icons.people,
        'color': AppTheme.primary,
      },
      {
        'title': '자기 돌봄',
        'category': 'selfcare',
        'icon': Icons.spa,
        'color': AppTheme.secondary,
      },
      {
        'title': '창의적 활동',
        'category': 'creativity',
        'icon': Icons.brush,
        'color': AppTheme.info,
      },
    ];

    // 최근 감정에 따라 카드 선택
    if (entries.isNotEmpty) {
      final recentEntries = entries.take(3).toList();
      final dominantEmotion = _getDominantEmotion(recentEntries);
      
      // 감정에 따라 관련 카드 우선 선택
      List<Map<String, dynamic>> selectedCards = [];
      
      switch (dominantEmotion) {
        case '슬픔':
        case '두려움':
          selectedCards.addAll([
            allCards.firstWhere((card) => card['category'] == 'nature'),
            allCards.firstWhere((card) => card['category'] == 'selfcare'),
            allCards.firstWhere((card) => card['category'] == 'gratitude'),
            allCards.firstWhere((card) => card['category'] == 'creativity'),
          ]);
          break;
        case '분노':
          selectedCards.addAll([
            allCards.firstWhere((card) => card['category'] == 'nature'),
            allCards.firstWhere((card) => card['category'] == 'selfcare'),
            allCards.firstWhere((card) => card['category'] == 'creativity'),
            allCards.firstWhere((card) => card['category'] == 'growth'),
          ]);
          break;
        case '기쁨':
        case '사랑':
          selectedCards.addAll([
            allCards.firstWhere((card) => card['category'] == 'relationship'),
            allCards.firstWhere((card) => card['category'] == 'gratitude'),
            allCards.firstWhere((card) => card['category'] == 'creativity'),
            allCards.firstWhere((card) => card['category'] == 'growth'),
          ]);
          break;
        default:
          selectedCards = allCards.take(4).toList();
      }
      
      return selectedCards;
    }
    
    return allCards.take(4).toList();
  }

  /// 조언 카드 선택
  void _selectAdviceCard(Map<String, dynamic> card, List<DiaryEntry> entries) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(card['icon'], color: card['color']),
            const SizedBox(width: 8),
            Text(card['title']),
          ],
        ),
        content: const Text('AI가 맞춤형 조언을 생성하고 있어요...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
        ],
      ),
    );

    _generateAIAdvice(card, entries).then((advice) {
      Navigator.pop(context);
      // 카드 선택 완료 후 상태 업데이트 및 맨 위로 스크롤
      _saveSelectedCard(card, advice);
      _scrollToTopImmediately();
    }).catchError((error) {
      Navigator.pop(context);
      final dominantEmotion = _getDominantEmotion(entries.take(5).toList());
      final fallbackAdvice = _getFallbackAdvice(card['category'], dominantEmotion);
      // 카드 선택 완료 후 상태 업데이트 및 맨 위로 스크롤
      _saveSelectedCard(card, fallbackAdvice);
      _scrollToTopImmediately();
    });
  }

  /// AI 기반 조언 생성
  Future<String> _generateAIAdvice(Map<String, dynamic> card, List<DiaryEntry> entries) async {
    try {
      // 최근 일기 분석
      final recentEntries = entries.take(5).toList();
      final dominantEmotion = _getDominantEmotion(recentEntries);
      final cardCategory = card['category'] as String;
      
      // 카드 카테고리와 감정에 따른 맞춤형 조언 생성
      final prompt = '''
사용자의 현재 감정 상태를 분석하여 간단하고 실용적인 오늘의 조언을 제공해주세요.

현재 주요 감정: $dominantEmotion
조언 카테고리: ${_getCategoryDescription(cardCategory)}

다음 형식으로 간단하게 응답해주세요:
"오늘은 [감정 상태]군요. [구체적인 행동 제안] 어떨까요?"

예시:
- "오늘은 힘든 감정이군요. 빨리 자는 것 어떨까요?"
- "오늘은 기쁜 마음이군요. 좋아하는 음악을 들어보는 것 어떨까요?"
- "오늘은 평온한 마음이군요. 산책을 가보는 것 어떨까요?"

조언만 작성해주세요.
''';

      final geminiService = GeminiService.instance;
      final aiResponse = await geminiService.analyzeEmotionAndComfort(prompt, dominantEmotion);
      
      return aiResponse.isNotEmpty ? aiResponse : _getFallbackAdvice(cardCategory, dominantEmotion);
    } catch (e) {
      final dominantEmotion = _getDominantEmotion(entries.take(5).toList());
      return _getFallbackAdvice(card['category'] as String, dominantEmotion);
    }
  }

  /// 카드 카테고리 설명 가져오기
  String _getCategoryDescription(String category) {
    switch (category) {
      case 'nature':
        return '자연과 힐링 - 자연을 통한 마음의 평화와 휴식';
      case 'gratitude':
        return '감사와 성찰 - 감사한 일들을 생각하고 마음을 정리';
      case 'growth':
        return '새로운 시작 - 새로운 경험과 도전을 통한 성장';
      case 'relationship':
        return '관계와 소통 - 주변 사람들과의 연결과 대화';
      case 'selfcare':
        return '자기 돌봄 - 자신을 위한 특별한 시간과 활동';
      case 'creativity':
        return '창의적 활동 - 예술적 표현과 창의적 사고';
      default:
        return '일반적인 조언';
    }
  }

  /// 대체 조언 제공
  String _getFallbackAdvice(String category, String emotion) {
    // 감정에 따른 기본 조언
    String baseAdvice = '';
    switch (emotion) {
      case '슬픔':
        baseAdvice = '오늘은 슬픈 감정이군요.';
        break;
      case '분노':
        baseAdvice = '오늘은 화가 나는 감정이군요.';
        break;
      case '기쁨':
        baseAdvice = '오늘은 기쁜 마음이군요.';
        break;
      case '사랑':
        baseAdvice = '오늘은 사랑스러운 마음이군요.';
        break;
      case '평온':
        baseAdvice = '오늘은 평온한 마음이군요.';
        break;
      case '두려움':
        baseAdvice = '오늘은 불안한 감정이군요.';
        break;
      case '놀람':
        baseAdvice = '오늘은 놀라운 일이 있었군요.';
        break;
      default:
        baseAdvice = '오늘은 다양한 감정을 경험하고 계시군요.';
    }

    // 카테고리에 따른 구체적 제안
    String suggestion = '';
    switch (category) {
      case 'nature':
        suggestion = '자연 속에서 시간을 보내는 것 어떨까요?';
        break;
      case 'gratitude':
        suggestion = '감사한 일들을 생각해보는 것 어떨까요?';
        break;
      case 'growth':
        suggestion = '새로운 것에 도전해보는 것 어떨까요?';
        break;
      case 'relationship':
        suggestion = '주변 사람들과 대화해보는 것 어떨까요?';
        break;
      case 'selfcare':
        suggestion = '자신을 위한 특별한 시간을 가져보는 것 어떨까요?';
        break;
      case 'creativity':
        suggestion = '창의적인 활동을 해보는 것 어떨까요?';
        break;
      default:
        suggestion = '마음에 드는 활동을 해보는 것 어떨까요?';
    }

    return '$baseAdvice $suggestion';
  }

  /// 조언 결과 표시
  void _showAdviceResult(Map<String, dynamic> card, String advice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(card['icon'], color: card['color']),
            const SizedBox(width: 8),
            Text(card['title']),
          ],
        ),
        content: Text(advice),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 선택된 카드 저장
  Future<void> _saveSelectedCard(Map<String, dynamic> card, String advice) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      await prefs.setString('last_advice_card_date', today);
      await prefs.setString('selected_advice_card_id', card['id']);
      await prefs.setString('selected_advice_text', advice);
      
      // 상태 업데이트를 위해 setState 호출
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // 에러 처리
    }
  }

  /// 즉시 맨 위로 스크롤
  void _scrollToTopImmediately() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // 즉시 맨 위로 스크롤
        final scrollController = PrimaryScrollController.of(context);
        if (scrollController != null) {
          scrollController.jumpTo(0); // animateTo 대신 jumpTo 사용
        }
        
        // UI 강제 업데이트
        setState(() {});
      }
    });
  }
}
