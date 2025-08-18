import '../../../core/ai/openai/openai_service.dart';
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

/// AI 일기 분석 및 위로 서비스
class DiaryAnalysisService {
  DiaryAnalysisService._();
  static final DiaryAnalysisService instance = DiaryAnalysisService._();

  /// 단일 일기 분석
  Future<DiaryAnalysisResult> analyzeSingleEntry(DiaryEntry entry) async {
    try {
      // OpenAI API를 사용한 분석 (실제 구현 시)
      // final result = await OpenAIService.instance.analyzeDiaryEntry(entry);
      
      // 현재는 로컬 분석 사용
      return _performLocalAnalysis(entry);
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
    final dominantEmotions = emotionCounts.entries
        .where((e) => e.value > 1)
        .map((e) => e.key)
        .take(5)
        .toList();

    // 감정 균형 분석
    final positiveEmotions = ['기쁨', '감사', '평온', '설렘', '사랑'];
    final negativeEmotions = ['슬픔', '분노', '걱정', '스트레스', '지루함'];
    
    int positiveCount = 0;
    int negativeCount = 0;
    
    for (final emotion in emotionCounts.keys) {
      if (positiveEmotions.contains(emotion)) {
        positiveCount += emotionCounts[emotion]!;
      } else if (negativeEmotions.contains(emotion)) {
        negativeCount += emotionCounts[emotion]!;
      }
    }

    String emotionBalance;
    if (positiveCount > negativeCount * 1.5) {
      emotionBalance = 'positive';
    } else if (negativeCount > positiveCount * 1.5) {
      emotionBalance = 'negative';
    } else {
      emotionBalance = 'balanced';
    }

    // 감정 안정성 계산 (변동성의 역수)
    double totalVariance = 0.0;
    int emotionTypeCount = 0;
    
    emotionIntensities.forEach((emotion, intensities) {
      if (intensities.length > 1) {
        final mean = intensities.reduce((a, b) => a + b) / intensities.length;
        final variance = intensities
            .map((x) => (x - mean) * (x - mean))
            .reduce((a, b) => a + b) / intensities.length;
        totalVariance += variance;
        emotionTypeCount++;
      }
    });

    final emotionStability = emotionTypeCount > 0 
        ? 1.0 - (totalVariance / emotionTypeCount / 25.0).clamp(0.0, 1.0)
        : 0.5;

    return {
      'dominantEmotions': dominantEmotions,
      'emotionTrends': emotionIntensities,
      'emotionBalance': emotionBalance,
      'emotionStability': emotionStability,
    };
  }

  /// 스트레스 레벨 분석
  double analyzeStressLevel(List<DiaryEntry> entries) {
    if (entries.isEmpty) return 0.0;

    final stressEmotions = ['걱정', '불안', '스트레스', '분노', '짜증'];
    final calmEmotions = ['평온', '안정', '편안', '차분'];
    
    double stressScore = 0.0;
    double calmScore = 0.0;
    int totalEmotions = 0;

    for (final entry in entries) {
      for (final emotion in entry.emotions) {
        final intensity = entry.emotionIntensities[emotion]?.toDouble() ?? 5.0;
        
        if (stressEmotions.contains(emotion)) {
          stressScore += intensity;
        } else if (calmEmotions.contains(emotion)) {
          calmScore += intensity;
        }
        totalEmotions++;
      }
    }

    if (totalEmotions == 0) return 0.0;

    // 0-1 범위로 정규화
    final normalizedStress = (stressScore / (stressScore + calmScore + 1)).clamp(0.0, 1.0);
    return normalizedStress;
  }

  /// 로컬 단일 일기 분석
  DiaryAnalysisResult _performLocalAnalysis(DiaryEntry entry) {
    final content = '${entry.title} ${entry.content}';
    final keywords = _extractKeywords(content);
    final emotionScores = entry.emotions.asMap().map(
      (index, emotion) => MapEntry(
        emotion,
        entry.emotionIntensities[emotion]?.toDouble() ?? 5.0,
      ),
    );

    final advice = _generateAdvice(entry);
    final actionItems = _generateActionItems(entry);
    final encouragement = _generateEncouragement(entry);
    
    return DiaryAnalysisResult(
      summary: _generateSummary(entry),
      keywords: keywords,
      emotionScores: emotionScores,
      advice: advice,
      actionItems: actionItems,
      moodTrend: _analyzeMoodTrend([entry]),
      stressLevel: analyzeStressLevel([entry]),
      positiveAspects: _findPositiveAspects(entry),
      concernAreas: _findConcernAreas(entry),
      encouragement: encouragement,
    );
  }

  /// 로컬 다중 일기 분석
  DiaryAnalysisResult _performMultipleAnalysis(List<DiaryEntry> entries) {
    final allContent = entries.map((e) => '${e.title} ${e.content}').join(' ');
    final keywords = _extractKeywords(allContent);
    
    // 감정 점수 집계
    final emotionScores = <String, double>{};
    final emotionCounts = <String, int>{};
    
    for (final entry in entries) {
      for (final emotion in entry.emotions) {
        final intensity = entry.emotionIntensities[emotion]?.toDouble() ?? 5.0;
        emotionScores[emotion] = (emotionScores[emotion] ?? 0.0) + intensity;
        emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + 1;
      }
    }
    
    // 평균 계산
    emotionScores.forEach((emotion, totalScore) {
      emotionScores[emotion] = totalScore / emotionCounts[emotion]!;
    });

    return DiaryAnalysisResult(
      summary: _generateMultipleSummary(entries),
      keywords: keywords,
      emotionScores: emotionScores,
      advice: _generateMultipleAdvice(entries),
      actionItems: _generateMultipleActionItems(entries),
      moodTrend: _analyzeMoodTrend(entries),
      stressLevel: analyzeStressLevel(entries),
      positiveAspects: _findMultiplePositiveAspects(entries),
      concernAreas: _findMultipleConcernAreas(entries),
      encouragement: _generateMultipleEncouragement(entries),
    );
  }

  /// 키워드 추출
  List<String> _extractKeywords(String content) {
    final keywords = <String>[];
    final lowerContent = content.toLowerCase();
    
    // 감정 키워드
    final emotionKeywords = ['기쁨', '슬픔', '분노', '평온', '설렘', '걱정', '감사', '사랑'];
    for (final keyword in emotionKeywords) {
      if (lowerContent.contains(keyword.toLowerCase())) {
        keywords.add(keyword);
      }
    }
    
    // 활동 키워드
    final activityKeywords = ['일', '가족', '친구', '운동', '여행', '공부', '취미'];
    for (final keyword in activityKeywords) {
      if (lowerContent.contains(keyword.toLowerCase())) {
        keywords.add(keyword);
      }
    }
    
    return keywords.take(10).toList();
  }

  /// 요약 생성
  String _generateSummary(DiaryEntry entry) {
    if (entry.content.length <= 100) {
      return entry.content;
    }
    return '${entry.content.substring(0, 100)}...';
  }

  /// 다중 일기 요약 생성
  String _generateMultipleSummary(List<DiaryEntry> entries) {
    final recentEntries = entries.take(3).toList();
    final summaries = recentEntries.map((e) => e.title).join(', ');
    return '최근 일기: $summaries 등 총 ${entries.length}개의 일기를 분석했습니다.';
  }

  /// 조언 생성
  String _generateAdvice(DiaryEntry entry) {
    final positiveEmotions = ['기쁨', '감사', '평온', '설렘'];
    final negativeEmotions = ['슬픔', '분노', '걱정', '스트레스'];
    
    final hasPositive = entry.emotions.any((e) => positiveEmotions.contains(e));
    final hasNegative = entry.emotions.any((e) => negativeEmotions.contains(e));
    
    if (hasPositive && !hasNegative) {
      return '긍정적인 감정을 느끼고 계시네요! 이런 좋은 순간들을 더 자주 만들어보세요.';
    } else if (hasNegative && !hasPositive) {
      return '힘든 감정을 느끼고 계시는군요. 스스로에게 더 친절하게 대해주시고, 작은 기쁨을 찾아보세요.';
    } else if (hasPositive && hasNegative) {
      return '복합적인 감정을 느끼고 계시네요. 이는 자연스러운 것이니 자신을 이해해주세요.';
    } else {
      return '감정을 솔직하게 기록하는 것만으로도 큰 도움이 됩니다. 계속 이어가세요.';
    }
  }

  /// 다중 일기 조언 생성
  String _generateMultipleAdvice(List<DiaryEntry> entries) {
    final patterns = analyzeEmotionPatterns(entries);
    final balance = patterns['emotionBalance'] as String;
    final stability = patterns['emotionStability'] as double;
    
    if (balance == 'positive' && stability > 0.7) {
      return '감정적으로 안정되고 긍정적인 상태를 잘 유지하고 계시네요. 현재의 좋은 습관들을 계속 이어가세요.';
    } else if (balance == 'negative' && stability < 0.3) {
      return '최근 감정적으로 어려운 시기를 보내고 계시는 것 같아요. 전문가의 도움을 받거나 신뢰할 수 있는 사람과 이야기해보세요.';
    } else if (stability < 0.5) {
      return '감정 변화가 큰 시기인 것 같아요. 규칙적인 생활과 충분한 휴식을 통해 안정을 찾아보세요.';
    } else {
      return '전반적으로 균형 잡힌 감정 상태를 보이고 계세요. 지금처럼 꾸준히 자기 돌봄을 실천해보세요.';
    }
  }

  /// 실행 항목 생성
  List<String> _generateActionItems(DiaryEntry entry) {
    final items = <String>[];
    
    if (entry.emotions.contains('스트레스') || entry.emotions.contains('걱정')) {
      items.add('깊게 숨쉬기 연습하기');
      items.add('산책이나 가벼운 운동하기');
    }
    
    if (entry.emotions.contains('슬픔')) {
      items.add('좋아하는 음악 듣기');
      items.add('신뢰하는 사람과 대화하기');
    }
    
    if (entry.emotions.contains('기쁨') || entry.emotions.contains('감사')) {
      items.add('이 순간을 기억하고 감사하기');
      items.add('긍정적인 경험 더 만들어보기');
    }
    
    // 기본 항목
    if (items.isEmpty) {
      items.addAll([
        '충분한 수면 취하기',
        '건강한 식사하기',
        '자신에게 친절하게 대하기',
      ]);
    }
    
    return items.take(3).toList();
  }

  /// 다중 일기 실행 항목 생성
  List<String> _generateMultipleActionItems(List<DiaryEntry> entries) {
    final stressLevel = analyzeStressLevel(entries);
    final patterns = analyzeEmotionPatterns(entries);
    final balance = patterns['emotionBalance'] as String;
    
    final items = <String>[];
    
    if (stressLevel > 0.6) {
      items.addAll([
        '스트레스 관리 기법 연습하기',
        '전문가 상담 고려하기',
        '충분한 휴식 취하기',
      ]);
    } else if (balance == 'negative') {
      items.addAll([
        '긍정적인 활동 늘리기',
        '사회적 지지망 활용하기',
        '자기 돌봄 실천하기',
      ]);
    } else {
      items.addAll([
        '현재의 좋은 습관 유지하기',
        '새로운 도전 시도하기',
        '감사 인식 늘리기',
      ]);
    }
    
    return items.take(3).toList();
  }

  /// 격려 메시지 생성
  String _generateEncouragement(DiaryEntry entry) {
    final encouragements = [
      '오늘도 자신의 감정을 솔직하게 기록해주셔서 감사해요.',
      '감정을 인정하고 표현하는 것은 용기 있는 일이에요.',
      '매일 조금씩 성장하고 있는 자신을 인정해주세요.',
      '힘든 순간도 지나갈 것이니 자신을 믿어보세요.',
      '작은 변화도 의미 있는 발걸음이에요.',
    ];
    
    return encouragements[DateTime.now().millisecond % encouragements.length];
  }

  /// 다중 일기 격려 메시지 생성
  String _generateMultipleEncouragement(List<DiaryEntry> entries) {
    final dayCount = entries.length;
    
    if (dayCount >= 7) {
      return '일주일 이상 꾸준히 일기를 작성하고 계시네요! 정말 대단해요. 이런 노력이 분명 좋은 변화를 가져올 거예요.';
    } else if (dayCount >= 3) {
      return '며칠째 일기를 작성하고 계시는군요. 자기 성찰의 시간을 갖는 것은 정말 소중한 일이에요.';
    } else {
      return '일기 작성을 시작하신 것을 축하해요. 작은 시작이 큰 변화의 첫걸음이 될 수 있어요.';
    }
  }

  /// 기분 트렌드 분석
  String _analyzeMoodTrend(List<DiaryEntry> entries) {
    if (entries.length < 2) return '데이터 부족';
    
    // 최근 3개 일기의 감정 점수 평균 계산
    final recentEntries = entries.take(3).toList();
    final olderEntries = entries.skip(3).take(3).toList();
    
    double recentScore = 0.0;
    double olderScore = 0.0;
    
    for (final entry in recentEntries) {
      recentScore += _calculateEntryMoodScore(entry);
    }
    recentScore /= recentEntries.length;
    
    if (olderEntries.isNotEmpty) {
      for (final entry in olderEntries) {
        olderScore += _calculateEntryMoodScore(entry);
      }
      olderScore /= olderEntries.length;
      
      if (recentScore > olderScore + 0.5) {
        return '상승 추세';
      } else if (recentScore < olderScore - 0.5) {
        return '하락 추세';
      } else {
        return '안정적';
      }
    }
    
    return '안정적';
  }

  /// 일기의 기분 점수 계산
  double _calculateEntryMoodScore(DiaryEntry entry) {
    final positiveEmotions = ['기쁨', '감사', '평온', '설렘', '사랑'];
    final negativeEmotions = ['슬픔', '분노', '걱정', '스트레스'];
    
    double score = 5.0; // 중립
    
    for (final emotion in entry.emotions) {
      final intensity = entry.emotionIntensities[emotion]?.toDouble() ?? 5.0;
      
      if (positiveEmotions.contains(emotion)) {
        score += intensity * 0.1;
      } else if (negativeEmotions.contains(emotion)) {
        score -= intensity * 0.1;
      }
    }
    
    return score.clamp(0.0, 10.0);
  }

  /// 긍정적 측면 찾기
  List<String> _findPositiveAspects(DiaryEntry entry) {
    final aspects = <String>[];
    
    if (entry.emotions.contains('기쁨')) {
      aspects.add('기쁜 순간을 경험했어요');
    }
    if (entry.emotions.contains('감사')) {
      aspects.add('감사할 일을 찾았어요');
    }
    if (entry.emotions.contains('평온')) {
      aspects.add('마음의 평온을 느꼈어요');
    }
    if (entry.content.contains('성공') || entry.content.contains('달성')) {
      aspects.add('목표를 달성했어요');
    }
    if (entry.content.contains('도움') || entry.content.contains('배움')) {
      aspects.add('새로운 것을 배웠어요');
    }
    
    return aspects;
  }

  /// 다중 일기 긍정적 측면 찾기
  List<String> _findMultiplePositiveAspects(List<DiaryEntry> entries) {
    final aspects = <String>[];
    
    final totalPositiveEmotions = entries
        .expand((e) => e.emotions)
        .where((e) => ['기쁨', '감사', '평온', '설렘', '사랑'].contains(e))
        .length;
    
    if (totalPositiveEmotions > entries.length) {
      aspects.add('전반적으로 긍정적인 감정을 많이 경험하고 있어요');
    }
    
    if (entries.length >= 5) {
      aspects.add('꾸준한 일기 작성으로 자기 성찰을 실천하고 있어요');
    }
    
    final aiChatEntries = entries.where((e) => e.diaryType == DiaryType.aiChat).length;
    if (aiChatEntries > 0) {
      aspects.add('AI와의 대화를 통해 새로운 관점을 얻고 있어요');
    }
    
    return aspects;
  }

  /// 우려 영역 찾기
  List<String> _findConcernAreas(DiaryEntry entry) {
    final concerns = <String>[];
    
    if (entry.emotions.contains('스트레스')) {
      concerns.add('스트레스 수준이 높아 보여요');
    }
    if (entry.emotions.contains('걱정')) {
      concerns.add('걱정이 많으신 것 같아요');
    }
    if (entry.emotions.contains('슬픔')) {
      concerns.add('슬픈 감정을 경험하고 있어요');
    }
    
    return concerns;
  }

  /// 다중 일기 우려 영역 찾기
  List<String> _findMultipleConcernAreas(List<DiaryEntry> entries) {
    final concerns = <String>[];
    
    final stressLevel = analyzeStressLevel(entries);
    if (stressLevel > 0.7) {
      concerns.add('지속적인 높은 스트레스 수준');
    }
    
    final patterns = analyzeEmotionPatterns(entries);
    final balance = patterns['emotionBalance'] as String;
    if (balance == 'negative') {
      concerns.add('부정적인 감정이 우세함');
    }
    
    final stability = patterns['emotionStability'] as double;
    if (stability < 0.3) {
      concerns.add('감정 변화가 매우 큼');
    }
    
    return concerns;
  }
}
