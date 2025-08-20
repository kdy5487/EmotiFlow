import '../../../core/ai/gemini/gemini_service.dart';
import '../../diary/models/diary_entry.dart';

/// AI 일기 분석 결과
class DiaryAnalysisResult {
  final String summary;
  final List<String> keywords;
  final Map<String, double> emotionScores;
  final String advice;
  final List<String> actionItems;
  final String moodTrend;
  final double stressLevel;
  final List<String> positiveAspects;
  final List<String> concernAreas;
  final String encouragement;

  DiaryAnalysisResult({
    required this.summary,
    required this.keywords,
    required this.emotionScores,
    required this.advice,
    required this.actionItems,
    required this.moodTrend,
    required this.stressLevel,
    required this.positiveAspects,
    required this.concernAreas,
    required this.encouragement,
  });
}

/// AI 일기 분석 및 위로 서비스 (Gemini 기반)
class DiaryAnalysisService {
  DiaryAnalysisService._();
  static final DiaryAnalysisService instance = DiaryAnalysisService._();

  /// 단일 일기 분석
  Future<DiaryAnalysisResult> analyzeSingleEntry(DiaryEntry entry) async {
    try {
      // Gemini API를 사용한 분석
      final selectedEmotion = entry.emotions.isNotEmpty ? entry.emotions.first : '평온';
      final aiResponse = await GeminiService.instance.analyzeEmotionAndComfort(entry.content, selectedEmotion);
      
      return _parseAIResponse(entry, aiResponse);
    } catch (e) {
      print('일기 분석 실패: $e');
      return _performLocalAnalysis(entry);
    }
  }

  /// 여러 일기 종합 분석
  Future<DiaryAnalysisResult> analyzeMultipleEntries(List<DiaryEntry> entries) async {
    if (entries.isEmpty) {
      return DiaryAnalysisResult(
        summary: '분석할 일기가 없습니다.',
        keywords: [],
        emotionScores: {},
        advice: '일기를 작성해보세요.',
        actionItems: ['일기 작성하기'],
        moodTrend: '데이터 부족',
        stressLevel: 0.0,
        positiveAspects: [],
        concernAreas: ['일기 부족'],
        encouragement: '꾸준한 일기 작성으로 감정을 기록해보세요.',
      );
    }

    try {
      return _performMultipleAnalysis(entries);
    } catch (e) {
      print('종합 분석 실패: $e');
      return _performMultipleAnalysis(entries);
    }
  }

  /// AI 응답을 파싱하여 구조화된 결과 생성
  DiaryAnalysisResult _parseAIResponse(DiaryEntry entry, String aiResponse) {
    // AI 응답을 분석하여 구조화된 데이터로 변환
    final emotions = _extractEmotions(entry.content);
    final emotionScores = _calculateEmotionScores(emotions);
    
    return DiaryAnalysisResult(
      summary: aiResponse.length > 100 ? '${aiResponse.substring(0, 100)}...' : aiResponse,
      keywords: _extractKeywords(entry.content),
      emotionScores: emotionScores,
      advice: aiResponse,
      actionItems: _extractActionItems(aiResponse),
      moodTrend: _determineMoodTrend(emotionScores),
      stressLevel: _calculateStressLevel(emotionScores),
      positiveAspects: _extractPositiveAspects(aiResponse),
      concernAreas: _extractConcernAreas(aiResponse),
      encouragement: aiResponse,
    );
  }

  /// 감정 패턴 분석
  Map<String, dynamic> analyzeEmotionPatterns(List<DiaryEntry> entries) {
    if (entries.isEmpty) {
      return {
        'dominantEmotions': <String>[],
        'emotionTrends': <String, List<double>>{},
        'emotionBalance': 'neutral',
        'emotionStability': 0.0,
      };
    }

    // 감정 빈도 계산
    final emotionCounts = <String, int>{};
    final emotionIntensities = <String, List<double>>{};
    
    for (final entry in entries) {
      for (final emotion in entry.emotions) {
        emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + 1;
        
        final intensity = entry.emotionIntensities[emotion]?.toDouble() ?? 5.0;
        emotionIntensities.putIfAbsent(emotion, () => []).add(intensity);
      }
    }

    // 주요 감정 추출
    final sortedEntries = emotionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final dominantEmotions = sortedEntries
        .take(3)
        .map((e) => e.key)
        .toList();

    // 감정 트렌드 계산
    final emotionTrends = <String, List<double>>{};
    for (final emotion in dominantEmotions) {
      emotionTrends[emotion] = emotionIntensities[emotion] ?? [];
    }

    // 감정 균형 계산
    final positiveEmotions = ['기쁨', '감사', '평온', '설렘'];
    final negativeEmotions = ['슬픔', '걱정', '분노', '지루함'];
    
    int positiveCount = 0;
    int negativeCount = 0;
    
    for (final entry in entries) {
      for (final emotion in entry.emotions) {
        if (positiveEmotions.contains(emotion)) {
          positiveCount++;
        } else if (negativeEmotions.contains(emotion)) {
          negativeCount++;
        }
      }
    }

    String emotionBalance;
    if (positiveCount > negativeCount) {
      emotionBalance = 'positive';
    } else if (negativeCount > positiveCount) {
      emotionBalance = 'negative';
    } else {
      emotionBalance = 'neutral';
    }

    // 감정 안정성 계산
    double emotionStability = 0.0;
    if (entries.length > 1) {
      final emotionVariances = <double>[];
      for (final emotion in dominantEmotions) {
        final intensities = emotionIntensities[emotion] ?? [];
        if (intensities.length > 1) {
          final mean = intensities.reduce((a, b) => a + b) / intensities.length;
          final variance = intensities.map((i) => (i - mean) * (i - mean)).reduce((a, b) => a + b) / intensities.length;
          emotionVariances.add(variance);
        }
      }
      if (emotionVariances.isNotEmpty) {
        emotionStability = 1.0 / (1.0 + emotionVariances.reduce((a, b) => a + b) / emotionVariances.length);
      }
    }

    return {
      'dominantEmotions': dominantEmotions,
      'emotionTrends': emotionTrends,
      'emotionBalance': emotionBalance,
      'emotionStability': emotionStability,
    };
  }

  // 로컬 분석 메서드들
  DiaryAnalysisResult _performLocalAnalysis(DiaryEntry entry) {
    final emotions = _extractEmotions(entry.content);
    final emotionScores = _calculateEmotionScores(emotions);
    
    return DiaryAnalysisResult(
      summary: '일기 분석이 완료되었습니다.',
      keywords: _extractKeywords(entry.content),
      emotionScores: emotionScores,
      advice: '오늘 하루도 수고하셨습니다. 감정을 정리하는 것은 좋은 습관이에요.',
      actionItems: ['감정 상태 점검하기', '긍정적 사고하기'],
      moodTrend: _determineMoodTrend(emotionScores),
      stressLevel: _calculateStressLevel(emotionScores),
      positiveAspects: ['일기 작성 완료'],
      concernAreas: [],
      encouragement: '꾸준한 기록으로 더 나은 내일을 만들어가세요!',
    );
  }

  DiaryAnalysisResult _performMultipleAnalysis(List<DiaryEntry> entries) {
    final patterns = analyzeEmotionPatterns(entries);
    final dominantEmotions = patterns['dominantEmotions'] as List<String>;
    
    return DiaryAnalysisResult(
      summary: '${entries.length}개의 일기를 분석했습니다.',
      keywords: _extractKeywordsFromMultiple(entries),
      emotionScores: _calculateAverageEmotionScores(entries),
      advice: _generateAdviceFromPatterns(patterns),
      actionItems: _generateActionItemsFromPatterns(patterns),
      moodTrend: _determineOverallMoodTrend(entries),
      stressLevel: _calculateAverageStressLevel(entries),
      positiveAspects: _extractPositiveAspectsFromPatterns(patterns),
      concernAreas: _extractConcernAreasFromPatterns(patterns),
      encouragement: '감정 패턴을 파악하는 것은 성장의 첫걸음입니다!',
    );
  }

  // 헬퍼 메서드들
  List<String> _extractEmotions(String text) {
    final emotionKeywords = {
      '기쁨': ['기쁘', '행복', '즐거', '신나', '웃'],
      '슬픔': ['슬프', '우울', '속상', '눈물', '아프'],
      '분노': ['화나', '짜증', '열받', '분노', '화'],
      '평온': ['차분', '평온', '고요', '안정', '편안'],
      '설렘': ['설레', '기대', '떨리', '긴장', '두근'],
      '걱정': ['걱정', '불안', '긴장', '초조', '무서'],
      '감사': ['감사', '고마', '은혜', '축복', '행운'],
      '지루함': ['지루', '심심', '따분', '재미없', '단조'],
    };

    final foundEmotions = <String>[];
    for (final entry in emotionKeywords.entries) {
      for (final keyword in entry.value) {
        if (text.contains(keyword)) {
          foundEmotions.add(entry.key);
          break;
        }
      }
    }

    return foundEmotions.isEmpty ? ['평온'] : foundEmotions;
  }

  Map<String, double> _calculateEmotionScores(List<String> emotions) {
    final scores = <String, double>{};
    for (final emotion in emotions) {
      scores[emotion] = 7.0; // 기본 강도
    }
    return scores;
  }

  List<String> _extractKeywords(String text) {
    // 간단한 키워드 추출 (실제로는 더 정교한 NLP 사용)
    final words = text.split(' ');
    return words.where((word) => word.length > 2).take(5).toList();
  }

  List<String> _extractActionItems(String text) {
    // AI 응답에서 액션 아이템 추출
    if (text.contains('해보세요') || text.contains('시도해보세요')) {
      return ['AI 조언 실천하기'];
    }
    return ['감정 상태 점검하기'];
  }

  String _determineMoodTrend(Map<String, double> emotionScores) {
    final positiveEmotions = ['기쁨', '감사', '평온', '설렘'];
    final negativeEmotions = ['슬픔', '걱정', '분노', '지루함'];
    
    double positiveScore = 0;
    double negativeScore = 0;
    
    for (final entry in emotionScores.entries) {
      if (positiveEmotions.contains(entry.key)) {
        positiveScore += entry.value;
      } else if (negativeEmotions.contains(entry.key)) {
        negativeScore += entry.value;
      }
    }
    
    if (positiveScore > negativeScore) {
      return '긍정적';
    } else if (negativeScore > positiveScore) {
      return '부정적';
    } else {
      return '중립적';
    }
  }

  double _calculateStressLevel(Map<String, double> emotionScores) {
    final stressEmotions = ['걱정', '불안', '긴장', '초조'];
    double stressScore = 0;
    
    for (final emotion in stressEmotions) {
      stressScore += emotionScores[emotion] ?? 0;
    }
    
    return stressScore / stressEmotions.length;
  }

  List<String> _extractPositiveAspects(String text) {
    if (text.contains('좋') || text.contains('긍정')) {
      return ['긍정적 사고'];
    }
    return ['일기 작성 완료'];
  }

  List<String> _extractConcernAreas(String text) {
    if (text.contains('걱정') || text.contains('불안')) {
      return ['감정 관리'];
    }
    return [];
  }

  // 다중 일기 분석 헬퍼 메서드들
  List<String> _extractKeywordsFromMultiple(List<DiaryEntry> entries) {
    final allKeywords = <String>[];
    for (final entry in entries) {
      allKeywords.addAll(_extractKeywords(entry.content));
    }
    return allKeywords.take(10).toList();
  }

  Map<String, double> _calculateAverageEmotionScores(List<DiaryEntry> entries) {
    final emotionCounts = <String, List<double>>{};
    
    for (final entry in entries) {
      for (final emotion in entry.emotions) {
        final intensity = entry.emotionIntensities[emotion]?.toDouble() ?? 5.0;
        emotionCounts.putIfAbsent(emotion, () => []).add(intensity);
      }
    }
    
    final averageScores = <String, double>{};
    emotionCounts.forEach((emotion, intensities) {
      final average = intensities.reduce((a, b) => a + b) / intensities.length;
      averageScores[emotion] = average;
    });
    
    return averageScores;
  }

  String _generateAdviceFromPatterns(Map<String, dynamic> patterns) {
    final balance = patterns['emotionBalance'] as String;
    final stability = patterns['emotionStability'] as double;
    
    if (balance == 'positive' && stability > 0.7) {
      return '안정적이고 긍정적인 감정 상태를 유지하고 계시네요!';
    } else if (balance == 'negative' && stability < 0.3) {
      return '감정 변화가 큰 시기를 보내고 계시네요. 차분히 마음을 정리해보세요.';
    } else {
      return '감정의 균형을 맞추는 것이 중요합니다.';
    }
  }

  List<String> _generateActionItemsFromPatterns(Map<String, dynamic> patterns) {
    final balance = patterns['emotionBalance'] as String;
    final stability = patterns['emotionStability'] as double;
    
    if (balance == 'negative') {
      return ['긍정적 사고 연습하기', '스트레스 관리하기', '취미 활동하기'];
    } else if (stability < 0.5) {
      return ['감정 안정성 향상하기', '일상의 리듬 찾기'];
    } else {
      return ['현재 상태 유지하기', '감정 기록 계속하기'];
    }
  }

  String _determineOverallMoodTrend(List<DiaryEntry> entries) {
    if (entries.length < 2) return '데이터 부족';
    
    final recentEntries = entries.take(3).toList();
    final olderEntries = entries.skip(3).take(3).toList();
    
    if (recentEntries.isEmpty || olderEntries.isEmpty) return '데이터 부족';
    
    final recentMood = _calculateAverageMood(recentEntries);
    final olderMood = _calculateAverageMood(olderEntries);
    
    if (recentMood > olderMood + 1) {
      return '개선';
    } else if (recentMood < olderMood - 1) return '악화';
    else return '안정';
  }

  double _calculateAverageMood(List<DiaryEntry> entries) {
    double totalMood = 0;
    int count = 0;
    
    for (final entry in entries) {
      for (final emotion in entry.emotions) {
        final intensity = entry.emotionIntensities[emotion]?.toDouble() ?? 5.0;
        totalMood += intensity;
        count++;
      }
    }
    
    return count > 0 ? totalMood / count : 5.0;
  }

  double _calculateAverageStressLevel(List<DiaryEntry> entries) {
    double totalStress = 0;
    int count = 0;
    
    for (final entry in entries) {
      totalStress += _calculateStressLevel(_calculateEmotionScores(entry.emotions));
      count++;
    }
    
    return count > 0 ? totalStress / count : 0.0;
  }

  List<String> _extractPositiveAspectsFromPatterns(Map<String, dynamic> patterns) {
    final balance = patterns['emotionBalance'] as String;
    if (balance == 'positive') {
      return ['긍정적 감정 우세', '안정적인 감정 상태'];
    }
    return ['감정 인식 능력'];
  }

  List<String> _extractConcernAreasFromPatterns(Map<String, dynamic> patterns) {
    final balance = patterns['emotionBalance'] as String;
    final stability = patterns['emotionStability'] as double;
    
    final concerns = <String>[];
    if (balance == 'negative') {
      concerns.add('부정적 감정 관리');
    }
    if (stability < 0.5) {
      concerns.add('감정 안정성');
    }
    
    return concerns.isEmpty ? ['감정 균형'] : concerns;
  }
}
