import 'package:flutter/material.dart';

/// 그림 그리기 관련 상수
class DrawingConstants {
  DrawingConstants._(); // Private constructor

  /// 색상 팔레트
  static const List<Color> colorPalette = [
    Colors.black,
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  /// 브러시 크기 옵션
  static const List<double> brushSizes = [
    2.0,
    4.0,
    6.0,
    8.0,
    12.0,
    16.0,
    20.0,
    24.0,
  ];

  /// 지우개 크기 옵션
  static const Map<String, double> eraserSizes = {
    'Small': 10.0,
    'Medium': 20.0,
    'Large': 30.0,
    'Very Large': 40.0,
  };

  /// 감정 스티커
  static const List<String> emotionStickers = [
    '😊',
    '😢',
    '😡',
    '😱',
    '😍',
    '🤗',
    '😴',
    '🤔',
    '😎',
    '🥳',
    '❤️',
    '💔',
    '⭐',
    '✨',
    '🌈',
  ];

  /// 도구 이름 매핑
  static const Map<String, String> toolNames = {
    'pen': '펜',
    'eraser': '지우개',
    'circle': '원',
    'heart': '하트',
  };
}

