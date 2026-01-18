import 'package:flutter/material.dart';

/// 감정 엔티티
class Emotion {
  final String id;
  final String name;
  final String emoji;
  final String category; // 기본 감정 카테고리
  final String description;
  final List<String> synonyms; // 유사한 감정 표현들
  final Color color; // 감정을 나타내는 색상
  final List<String> relatedEmotions; // 연관된 감정들
  final String moodType; // 긍정/부정/중립

  const Emotion({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    required this.description,
    required this.synonyms,
    required this.color,
    required this.relatedEmotions,
    required this.moodType,
  });

  /// 기본 감정 카테고리들 (문서 명세에 따른 8가지)
  static const List<String> basicCategories = [
    '기쁨',
    '슬픔',
    '분노',
    '평온',
    '설렘',
    '걱정',
    '감사',
    '지루함',
  ];

  /// 기본 감정 데이터 (문서 명세에 따른 8가지)
  static final List<Emotion> basicEmotions = [
    const Emotion(
      id: 'joy',
      name: '기쁨',
      emoji: '😊',
      category: '기쁨',
      description: '만족스럽고 즐거운 감정',
      synonyms: ['행복', '즐거움', '만족', '희열', '환희', '신남'],
      color: Color(0xFFFFD700), // 골드
      relatedEmotions: ['감사', '설렘', '평온'],
      moodType: 'positive',
    ),
    const Emotion(
      id: 'sadness',
      name: '슬픔',
      emoji: '😢',
      category: '슬픔',
      description: '우울하고 슬픈 감정',
      synonyms: ['우울', '절망', '비통', '허전함', '외로움', '쓸쓸함'],
      color: Color(0xFF87CEEB), // 하늘색
      relatedEmotions: ['걱정', '지루함'],
      moodType: 'negative',
    ),
    const Emotion(
      id: 'anger',
      name: '분노',
      emoji: '😠',
      category: '분노',
      description: '화가 나고 격분한 감정',
      synonyms: ['화남', '격분', '짜증', '열받음', '분통함'],
      color: Color(0xFFFF4500), // 오렌지 레드
      relatedEmotions: ['걱정', '슬픔'],
      moodType: 'negative',
    ),
    const Emotion(
      id: 'calm',
      name: '평온',
      emoji: '😌',
      category: '평온',
      description: '차분하고 평화로운 감정',
      synonyms: ['평화', '차분', '고요', '안정', '편안함'],
      color: Color(0xFF98FB98), // 연한 초록
      relatedEmotions: ['감사', '기쁨'],
      moodType: 'positive',
    ),
    const Emotion(
      id: 'excitement',
      name: '설렘',
      emoji: '🤩',
      category: '설렘',
      description: '기대와 설렘으로 가득한 감정',
      synonyms: ['기대', '설렘', '두근거림', '열정', '의욕'],
      color: Color(0xFFFF69B4), // 핑크
      relatedEmotions: ['기쁨', '감사'],
      moodType: 'positive',
    ),
    const Emotion(
      id: 'worry',
      name: '걱정',
      emoji: '😰',
      category: '걱정',
      description: '불안하고 걱정스러운 감정',
      synonyms: ['불안', '걱정', '긴장', '두려움', '초조함'],
      color: Color(0xFFFFA500), // 오렌지
      relatedEmotions: ['슬픔', '지루함'],
      moodType: 'negative',
    ),
    const Emotion(
      id: 'gratitude',
      name: '감사',
      emoji: '🙏',
      category: '감사',
      description: '고마움과 감사를 느끼는 감정',
      synonyms: ['고마움', '감사', '은혜', '축복', '행운'],
      color: Color(0xFF32CD32), // 라임 그린
      relatedEmotions: ['기쁨', '평온'],
      moodType: 'positive',
    ),
    const Emotion(
      id: 'boredom',
      name: '지루함',
      emoji: '😐',
      category: '지루함',
      description: '재미없고 지루한 감정',
      synonyms: ['지루함', '따분함', '재미없음', '무료함', '중립'],
      color: Color(0xFF808080), // 그레이
      relatedEmotions: ['슬픔', '걱정'],
      moodType: 'neutral',
    ),
  ];

  /// ID로 감정 찾기
  static Emotion? findById(String id) {
    try {
      return basicEmotions.firstWhere((emotion) => emotion.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 카테고리로 감정들 찾기
  static List<Emotion> findByCategory(String category) {
    return basicEmotions.where((emotion) => emotion.category == category).toList();
  }

  /// 이름으로 감정 찾기
  static Emotion? findByName(String name) {
    try {
      return basicEmotions.firstWhere((emotion) => 
        emotion.name == name || emotion.synonyms.contains(name)
      );
    } catch (e) {
      return null;
    }
  }

  /// 감정 타입별로 감정들 찾기
  static List<Emotion> findByMoodType(String moodType) {
    return basicEmotions.where((emotion) => emotion.moodType == moodType).toList();
  }

  /// 연관된 감정들 찾기
  List<Emotion> getRelatedEmotions() {
    return basicEmotions.where((emotion) => 
      relatedEmotions.contains(emotion.name)
    ).toList();
  }

  /// 감정 강도에 따른 색상 반환
  Color getColorWithIntensity(int intensity) {
    final alpha = (intensity / 10.0).clamp(0.3, 1.0);
    return color.withOpacity(alpha);
  }

  /// 감정 강도에 따른 이모지 반환
  String getEmojiWithIntensity(int intensity) {
    if (intensity <= 3) {
      return emoji.replaceAll('😊', '😐').replaceAll('😢', '😔').replaceAll('😠', '😐');
    } else if (intensity >= 8) {
      return emoji.replaceAll('😊', '🤩').replaceAll('😢', '😭').replaceAll('😠', '🤬');
    }
    return emoji;
  }
}

