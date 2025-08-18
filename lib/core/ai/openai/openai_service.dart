import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../features/diary/models/diary_entry.dart';

class OpenAIAnalysisResult {
  final String title;
  final String content;
  final List<String> emotions;
  final Map<String, int> emotionIntensities;
  final AIAnalysis aiAnalysis;

  OpenAIAnalysisResult({
    required this.title,
    required this.content,
    required this.emotions,
    required this.emotionIntensities,
    required this.aiAnalysis,
  });
}

/// 간단한 OpenAI 연동 서비스
class OpenAIService {
  OpenAIService._();
  static final OpenAIService instance = OpenAIService._();

  // flutter run/build 시 --dart-define=OPENAI_API_KEY=... 로 전달 가능
  static const String _apiKey = String.fromEnvironment('OPENAI_API_KEY');
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _model = 'gpt-4o-mini';

  bool get _hasKey => _apiKey.isNotEmpty;

  Future<String?> generateChatReply({
    required List<ChatMessage> history,
    required String userMessage,
  }) async {
    // 실제 OpenAI API 호출 시도
    if (_hasKey) {
      try {
        final response = await _callOpenAI(userMessage, history);
        if (response != null) return response;
      } catch (e) {
        print('OpenAI API 호출 실패: $e');
      }
    }
    
    // API 키가 없거나 호출 실패 시 자연스러운 규칙 기반 답변 반환
    return _generateNaturalReply(userMessage, history);
  }

  /// 실제 OpenAI API 호출
  Future<String?> _callOpenAI(String userMessage, List<ChatMessage> history) async {
    try {
      final messages = [
        {
          'role': 'system',
          'content': '''너는 친근하고 공감적인 AI 친구야. 사용자와 자연스럽게 대화하면서 감정을 이해하고 위로해줘.

규칙:
1. 항상 친근하고 따뜻하게 대화해
2. 사용자의 감정에 공감하고 이해해줘  
3. 구체적이고 도움이 되는 조언을 해줘
4. 너무 길지 않게, 2-3문장으로 답해
5. 질문할 때는 하나씩만 물어봐
6. 사용자가 이상한 말을 해도 자연스럽게 대화를 이어가'''
        },
        ...history.map((m) => {
              'role': m.isFromAI ? 'assistant' : 'user',
              'content': m.content,
            }),
        {'role': 'user', 'content': userMessage},
      ];

      final resp = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 256,
        }),
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final content = data['choices']?[0]?['message']?['content'];
        if (content is String) return content.trim();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 자연스러운 규칙 기반 답변 생성
  String _generateNaturalReply(String userMessage, List<ChatMessage> history) {
    final message = userMessage.toLowerCase();
    
    // 아무 의미 없는 문자나 이상한 입력 처리
    if (message.length < 2 || 
        RegExp(r'^[ㅁㄴㅇㄹㅎㅋㅠㅜㅗㅓㅏㅣ\s]+$').hasMatch(message) ||
        message.replaceAll(RegExp(r'[가-힣a-zA-Z0-9\s]'), '').length > message.length * 0.5) {
      final responses = [
        '무엇을 말씀하고 싶으신지 잘 모르겠어요. 다시 말씀해주실 수 있나요?',
        '잘 이해하지 못했어요. 조금 더 자세히 설명해주시겠어요?',
        '어떤 이야기를 하고 싶으신지 궁금해요. 편하게 말씀해주세요.',
      ];
      return responses[DateTime.now().millisecond % responses.length];
    }
    
    // 위로 요청
    if (message.contains('위로') || message.contains('위안') || message.contains('힘들어')) {
      return '정말 힘드셨겠어요. 저도 마음이 아파요. 어떤 일이 있었는지 들어볼게요.';
    }
    
    // 감정별 자연스러운 응답
    if (message.contains('기쁘') || message.contains('행복') || message.contains('좋아')) {
      return '와, 정말 좋은 일이 있었나 보네요! 어떤 일이 그렇게 기분 좋게 만들었나요?';
    }
    
    if (message.contains('슬프') || message.contains('우울') || message.contains('힘들')) {
      return '마음이 많이 힘드시겠어요. 무슨 일이 있었는지 이야기해주시면 들어볼게요.';
    }
    
    if (message.contains('화나') || message.contains('분노') || message.contains('짜증')) {
      return '정말 화가 나셨겠어요. 어떤 상황이 그렇게 만들었나요? 이야기해보세요.';
    }
    
    if (message.contains('걱정') || message.contains('불안')) {
      return '걱정이 많으시군요. 어떤 것 때문에 불안하신지 말씀해주시면 같이 생각해볼게요.';
    }
    
    // 일반적인 응답
    if (message.contains('오늘') || message.contains('하루')) {
      return '오늘 하루는 어떠셨어요? 특별한 일이 있었나요?';
    }
    
    if (message.contains('일') || message.contains('직장') || message.contains('회사')) {
      return '일과 관련된 이야기군요. 어떤 일이 있었는지 더 자세히 들려주세요.';
    }
    
    if (message.contains('사람') || message.contains('친구') || message.contains('가족')) {
      return '인간관계에 관한 이야기인가요? 어떤 상황인지 말씀해주세요.';
    }
    
    // 기본 자연스러운 응답들
    final naturalResponses = [
      '그렇군요! 더 자세히 이야기해주시겠어요?',
      '흥미로운 이야기네요. 어떤 기분이셨나요?',
      '아, 그런 일이 있었군요. 그때 어떤 생각이 드셨어요?',
      '정말요? 더 들어보고 싶어요.',
      '그 상황에서 어떤 감정을 느끼셨나요?',
    ];
    
    return naturalResponses[DateTime.now().millisecond % naturalResponses.length];
  }

  Future<OpenAIAnalysisResult?> analyzeDiaryFromChat({
    required List<ChatMessage> history,
  }) async {
    final fallback = _fallbackAnalysis(history);
    if (!_hasKey) return fallback;

    try {
      final messages = [
        {
          'role': 'system',
          'content': '너는 감정 일기 요약가야. 사용자의 대화 기록을 바탕으로 JSON만 반환해. '
              '필드: title(string), content(string), emotions(array[string, 1~3]), emotionIntensities(object: emotion->1..10), '
              'analysis(object: {summary, keywords(array), emotionScores(object: emotion->0..1), advice, actionItems(array), moodTrend})'
        },
        {
          'role': 'user',
          'content': '다음은 사용자와의 대화 기록입니다. 이를 바탕으로 지정한 JSON을 만들어줘. 대화:\n' +
              history.map((m) => (m.isFromAI ? 'AI: ' : 'USER: ') + m.content).join('\n')
        }
      ];

      final resp = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'temperature': 0.4,
          'max_tokens': 600,
          'response_format': {'type': 'json_object'}
        }),
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final content = data['choices']?[0]?['message']?['content'];
        if (content is String) {
          final parsed = jsonDecode(content) as Map<String, dynamic>;
          return _mapParsedToResult(parsed);
        }
      }
      return fallback;
    } catch (_) {
      return fallback;
    }
  }

  OpenAIAnalysisResult _fallbackAnalysis(List<ChatMessage> history) {
    final text = history.map((m) => m.content).join('\n');
    final firstUser = history.firstWhere((m) => !m.isFromAI, orElse: () => ChatMessage(id: '0', content: '하루에 대해 이야기했어요', isFromAI: false, timestamp: DateTime.now())).content;
    final emotions = _keywordEmotions(text);
    final intensities = {for (final e in emotions) e: 5};

    final analysis = AIAnalysis(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      summary: firstUser.length > 80 ? firstUser.substring(0, 80) + '...' : firstUser,
      keywords: emotions,
      emotionScores: {for (final e in emotions) e: 0.6},
      advice: '스스로에게 친절하게 대해주세요. 감정을 솔직하게 기록하는 것만으로도 큰 도움이 됩니다.',
      actionItems: ['오늘 있었던 사건을 3줄로 요약하기', '가장 컸던 감정 1개를 1~10으로 점수 매기기'],
      moodTrend: '안정적',
      analyzedAt: DateTime.now(),
    );
    return OpenAIAnalysisResult(
      title: firstUser.length > 16 ? firstUser.substring(0, 16) + '...' : firstUser,
      content: text.length > 500 ? text.substring(0, 500) + '...' : text,
      emotions: emotions.isEmpty ? ['평온'] : emotions,
      emotionIntensities: intensities,
      aiAnalysis: analysis,
    );
  }

  List<String> _keywordEmotions(String text) {
    final t = text.toLowerCase();
    final out = <String>[];
    if (t.contains('기쁘') || t.contains('행복') || t.contains('좋아')) out.add('기쁨');
    if (t.contains('슬프') || t.contains('우울') || t.contains('힘들')) out.add('슬픔');
    if (t.contains('화나') || t.contains('분노') || t.contains('짜증')) out.add('분노');
    if (t.contains('평온') || t.contains('차분') || t.contains('편안')) out.add('평온');
    if (t.contains('설렘') || t.contains('기대') || t.contains('떨림')) out.add('설렘');
    if (t.contains('걱정') || t.contains('불안') || t.contains('긴장')) out.add('걱정');
    if (t.contains('감사') || t.contains('고마워') || t.contains('축복')) out.add('감사');
    if (t.contains('지루') || t.contains('따분') || t.contains('재미없')) out.add('지루함');
    if (out.isEmpty) out.add('평온');
    return out.take(3).toList();
  }

  OpenAIAnalysisResult _mapParsedToResult(Map<String, dynamic> parsed) {
    final title = (parsed['title'] ?? '오늘의 일기').toString();
    final content = (parsed['content'] ?? '').toString();
    final emotions = (parsed['emotions'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
    final ei = <String, int>{};
    final rawEi = parsed['emotionIntensities'] as Map<String, dynamic>? ?? {};
    rawEi.forEach((k, v) {
      final n = (v is num) ? v.toInt() : int.tryParse(v.toString()) ?? 5;
      ei[k] = n.clamp(1, 10);
    });
    final analysisRaw = parsed['analysis'] as Map<String, dynamic>? ?? {};
    final emotionScores = <String, double>{};
    (analysisRaw['emotionScores'] as Map<String, dynamic>? ?? {}).forEach((k, v) {
      emotionScores[k] = (v is num) ? v.toDouble() : double.tryParse(v.toString()) ?? 0.5;
    });
    final analysis = AIAnalysis(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      summary: (analysisRaw['summary'] ?? '').toString(),
      keywords: (analysisRaw['keywords'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      emotionScores: emotionScores,
      advice: (analysisRaw['advice'] ?? '').toString(),
      actionItems: (analysisRaw['actionItems'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      moodTrend: (analysisRaw['moodTrend'] ?? '').toString(),
      analyzedAt: DateTime.now(),
    );
    return OpenAIAnalysisResult(
      title: title,
      content: content,
      emotions: emotions.isEmpty ? ['평온'] : emotions,
      emotionIntensities: ei.isEmpty ? {for (final e in emotions) e: 5} : ei,
      aiAnalysis: analysis,
    );
  }
}