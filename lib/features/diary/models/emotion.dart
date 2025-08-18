import 'package:flutter/material.dart';

/// 감정 모델
class Emotion {
  final String id;
  final String name;
  final String emoji;
  final String category; // 기본 감정 카테고리 (기쁨, 슬픔, 분노, 두려움, 놀람, 혐오, 중립)
  final String description;
  final List<String> synonyms; // 유사한 감정 표현들
  final Color color; // 감정을 나타내는 색상

  const Emotion({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    required this.description,
    required this.synonyms,
    required this.color,
  });

  /// 기본 감정 카테고리들
  static const List<String> basicCategories = [
    '기쁨',
    '슬픔',
    '분노',
    '두려움',
    '놀람',
    '혐오',
    '중립',
  ];

  /// 기본 감정 데이터
  static final List<Emotion> basicEmotions = [
    Emotion(
      id: 'joy',
      name: '기쁨',
      emoji: '😊',
      category: '기쁨',
      description: '만족스럽고 즐거운 감정',
      synonyms: ['행복', '즐거움', '만족', '희열', '환희'],
      color: Color(0xFFFFD700), // 골드
    ),
    Emotion(
      id: 'sadness',
      name: '슬픔',
      emoji: '😢',
      category: '슬픔',
      description: '우울하고 슬픈 감정',
      synonyms: ['우울', '절망', '비통', '허전함', '외로움'],
      color: Color(0xFF87CEEB), // 하늘색
    ),
    Emotion(
      id: 'anger',
      name: '분노',
      emoji: '😠',
      category: '분노',
      description: '화가 나고 격분한 감정',
      synonyms: ['화남', '격분', '분노', '짜증', '열받음'],
      color: Color(0xFFFF4500), // 오렌지 레드
    ),
    Emotion(
      id: 'fear',
      name: '두려움',
      emoji: '😨',
      category: '두려움',
      description: '무서우고 불안한 감정',
      synonyms: ['무서움', '불안', '공포', '긴장', '걱정'],
      color: Color(0xFF800080), // 보라
    ),
    Emotion(
      id: 'surprise',
      name: '놀람',
      emoji: '😲',
      category: '놀람',
      description: '예상치 못한 상황에 놀란 감정',
      synonyms: ['놀람', '충격', '당황', '경악', '기절'],
      color: Color(0xFFFF69B4), // 핑크
    ),
    Emotion(
      id: 'disgust',
      name: '혐오',
      emoji: '🤢',
      category: '혐오',
      description: '싫고 역겨운 감정',
      synonyms: ['싫음', '역겨움', '혐오', '지겨움', '짜증'],
      color: Color(0xFF32CD32), // 라임 그린
    ),
    Emotion(
      id: 'neutral',
      name: '중립',
      emoji: '😐',
      category: '중립',
      description: '특별한 감정이 없는 상태',
      synonyms: ['평온', '차분', '무감정', '평범', '보통'],
      color: Color(0xFF808080), // 그레이
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
}
