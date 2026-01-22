/// 사용자의 일기 작성 성장 상태를 표현하는 모델
class GrowthStatus {
  /// 연속 일기 작성 일수
  final int consecutiveDays;

  /// 총 일기 작성 수
  final int totalDiaryCount;

  /// 오늘 일기 작성 완료 여부
  final bool todayCompleted;

  /// 최근 7일 스탬프 데이터
  final List<DailyStamp> last7Days;

  const GrowthStatus({
    required this.consecutiveDays,
    required this.totalDiaryCount,
    required this.todayCompleted,
    required this.last7Days,
  });

  /// 현재 성장 레벨 (0-4)
  /// 0: 씨앗, 1: 싹, 2: 작은 나무, 3: 큰 나무, 4: 꽃 핀 나무
  int get currentLevel {
    if (consecutiveDays >= 30) return 4;
    if (consecutiveDays >= 15) return 3;
    if (consecutiveDays >= 8) return 2;
    if (consecutiveDays >= 4) return 1;
    return 0;
  }

  /// 현재 단계 이름
  String get stageName {
    switch (currentLevel) {
      case 0:
        return '씨앗';
      case 1:
        return '싹';
      case 2:
        return '작은 나무';
      case 3:
        return '큰 나무';
      case 4:
        return '꽃 핀 나무';
      default:
        return '씨앗';
    }
  }

  /// 현재 단계 이모지 (임시)
  String get stageEmoji {
    switch (currentLevel) {
      case 0:
        return '🌰';
      case 1:
        return '🌱';
      case 2:
        return '🌿';
      case 3:
        return '🌳';
      case 4:
        return '🌸';
      default:
        return '🌰';
    }
  }

  /// 다음 레벨까지 필요한 일수
  int get daysToNextLevel {
    switch (currentLevel) {
      case 0:
        return 4 - consecutiveDays;
      case 1:
        return 8 - consecutiveDays;
      case 2:
        return 15 - consecutiveDays;
      case 3:
        return 30 - consecutiveDays;
      case 4:
        return 0; // 최대 레벨
      default:
        return 0;
    }
  }

  /// 성장 진행률 (0.0 ~ 1.0)
  double get progressToNextLevel {
    if (currentLevel == 4) return 1.0;

    final levelThresholds = [0, 4, 8, 15, 30];
    final currentThreshold = levelThresholds[currentLevel];
    final nextThreshold = levelThresholds[currentLevel + 1];
    final range = nextThreshold - currentThreshold;

    return ((consecutiveDays - currentThreshold) / range).clamp(0.0, 1.0);
  }
}

/// 일별 스탬프 데이터
class DailyStamp {
  /// 날짜
  final DateTime date;

  /// 일기 작성 여부
  final bool hasEntry;

  /// 주요 감정 (있을 경우)
  final String? primaryEmotion;

  const DailyStamp({
    required this.date,
    required this.hasEntry,
    this.primaryEmotion,
  });

  /// 요일 이름 (한글 1글자)
  String get dayName {
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    return days[date.weekday - 1];
  }

  /// 스탬프 색상
  int get stampColor {
    if (!hasEntry) return 0xFFE0E0E0; // 회색

    // 감정별 색상
    switch (primaryEmotion) {
      case '기쁨':
      case 'joy':
        return 0xFFFFD700; // 금색
      case '슬픔':
      case 'sadness':
        return 0xFF6B73FF; // 파랑
      case '분노':
      case 'anger':
        return 0xFFFF6B6B; // 빨강
      case '평온':
      case 'peace':
        return 0xFF87CEEB; // 하늘색
      case '걱정':
      case 'anxiety':
        return 0xFF9370DB; // 보라
      case '설렘':
      case 'excitement':
        return 0xFFFF69B4; // 핑크
      default:
        return 0xFF4CAF50; // 기본 초록
    }
  }
}
