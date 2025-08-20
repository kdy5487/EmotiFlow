import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Gemini AI 연동 서비스
class GeminiService {
  GeminiService._();
  static final GeminiService instance = GeminiService._();

  // 환경 변수에서 API 키 가져오기
  String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent';

  bool get _hasKey => _apiKey.isNotEmpty;

  /// 자연스러운 대화 시작을 위한 초기 질문 생성
  Future<String> generateEmotionSelectionPrompt() async {
    print('🔑 Gemini API 키 확인: ${_apiKey.isNotEmpty ? "있음" : "없음"}');
    print('🔑 API 키 길이: ${_apiKey.length}');
    print('🔑 API 키 앞부분: ${_apiKey.isNotEmpty ? _apiKey.substring(0, 10) : "없음"}...');
    print('🔑 전체 API 키: $_apiKey');
    
    if (!_hasKey) {
      print('❌ API 키가 없어서 fallback 응답 사용');
      return _getFallbackEmotionPrompt();
    }

    try {
      print('🚀 Gemini API 호출 시작...');
      const prompt = '''
당신은 따뜻하고 공감적인 AI 상담사입니다.

사용자가 일기를 작성하려고 합니다. 감정을 선택하거나 자유롭게 이야기할 수 있다고 간단하게 안내해주세요.

**응답 스타일:**
- 2-3문장으로 간결하게 작성
- 친근하고 따뜻한 톤
- 감정 선택과 자유로운 대화 모두 가능함을 간단히 안내

**주의사항:**
- 마크다운 표시나 과도한 이모지 사용하지 말기
- 사용자가 편안하게 이야기할 수 있도록 안내

한국어로 친근하고 따뜻한 톤으로 답변해주세요.
''';

      final response = await _callGeminiAPI(prompt);
      print('📡 API 응답: ${response?.substring(0, 50) ?? "null"}...');
      return response ?? _getFallbackEmotionPrompt();
    } catch (e) {
      print('❌ 초기 프롬프트 생성 실패: $e');
      return _getFallbackEmotionPrompt();
    }
  }

  /// 자연스러운 상담 대화를 위한 질문 생성
  Future<String> generateEmotionBasedQuestion(String selectedEmotion, String userResponse, List<String> conversationHistory) async {
    if (!_hasKey) {
      return _getFallbackEmotionQuestion(selectedEmotion);
    }

    try {
      // 대화 기록이 있는지 확인하여 맞춤형 프롬프트 생성
      final hasHistory = conversationHistory.isNotEmpty;
      
      final prompt = '''
당신은 따뜻한 AI 상담사입니다.

사용자 응답: $userResponse
대화 히스토리: ${conversationHistory.join(', ')}

${hasHistory ? '''
**지속적 대화 상황입니다. 이전 대화를 참고하여 맞춤형으로 응답해주세요:**

- 이전 대화 내용을 참고하여 자연스럽게 연결
- 사용자의 감정 변화나 패턴을 고려하여 적절한 위로나 격려 제공
- 반복적인 내용이나 비슷한 말을 하지 않기
''' : '''
**첫 대화 상황입니다. 사용자와 편안하게 대화를 시작해주세요:**
'''}

**응답 스타일:**
- 공감과 위로를 자연스럽게 하나로 통합
- 3-4문장으로 간결하게 작성
- 사용자의 이야기에 대한 진심 어린 공감
- **후속 질문은 반드시 1개만** (여러 개 질문하지 말기)
- 친근하고 따뜻한 톤

**주의사항:**
- 마크다운 표시나 과도한 이모지 사용하지 말기
- **비슷한 내용의 반복적인 답변 절대 금지**
- 자연스럽게 하나의 흐름으로 연결
- **"힘내세요", "화이팅" 같은 마무리 표현 사용하지 말기**
- 대신 "더 이야기해주세요", "계속 들려주세요" 같은 표현으로 대화 계속 유도

한국어로 자연스럽게 답변해주세요.
''';

      final response = await _callGeminiAPI(prompt);
      return response ?? _getFallbackEmotionQuestion(selectedEmotion);
    } catch (e) {
      print('상담 질문 생성 실패: $e');
      return _getFallbackEmotionQuestion(selectedEmotion);
    }
  }

  /// 감정 분석 및 위로 메시지 생성
  Future<String> analyzeEmotionAndComfort(String diaryText, String selectedEmotion) async {
    if (!_hasKey) {
      return _getFallbackAnalysis(diaryText, selectedEmotion);
    }

    try {
      final prompt = '''
당신은 따뜻하고 공감적인 감정 전문 상담사입니다.

사용자가 작성한 일기와 선택한 감정을 분석하고, 따뜻한 위로와 조언을 제공해주세요.

선택된 감정: $selectedEmotion
일기 내용: $diaryText

**응답 스타일:**
- 감정 분석, 공감, 위로, 조언을 자연스럽게 하나로 통합
- 5-6문장을 넘지 않도록 간결하게 작성
- 사용자의 감정에 대한 이해와 공감을 바탕으로 한 따뜻한 위로
- 구체적이고 실용적인 조언 1-2개
- 자연스럽고 따뜻한 톤

**주의사항:**
- 마크다운 표시나 과도한 이모지 사용하지 말기
- 각 섹션을 명확히 구분하지 말고 자연스럽게 연결
- 비슷한 내용의 반복적인 답변 피하기

한국어로 작성해주세요.
''';

      final response = await _callGeminiAPI(prompt);
      return response ?? _getFallbackAnalysis(diaryText, selectedEmotion);
    } catch (e) {
      print('감정 분석 및 위로 생성 실패: $e');
      return _getFallbackAnalysis(diaryText, selectedEmotion);
    }
  }

  /// AI 이미지 생성 (채팅 내용과 감정 기반 맞춤형 그림)
  Future<String?> generateImage(String diarySummary, String? selectedEmotion, List<String> conversationHistory) async {
    try {
      // 채팅 내용과 감정을 바탕으로 상세한 프롬프트 생성
      final detailedPrompt = _createDetailedImagePrompt(diarySummary, selectedEmotion, conversationHistory);
      
      // Gemini Pro Vision API 호출
      final response = await _callGeminiImageAPI(detailedPrompt);
      return response;
    } catch (e) {
      print('AI 이미지 생성 실패: $e');
      return null;
    }
  }

  /// 상세한 이미지 생성 프롬프트 생성
  String _createDetailedImagePrompt(String diarySummary, String? selectedEmotion, List<String> conversationHistory) {
    final emotionDescription = selectedEmotion != null ? '감정: $selectedEmotion' : '감정: 자연스러운';
    
    // 대화 내용에서 핵심 키워드 추출
    final keywords = _extractKeywordsFromConversation(conversationHistory);
    
    return '''
다음 내용을 바탕으로 감정적이고 아름다운 일기 그림을 그려주세요:

$emotionDescription
일기 내용: $diarySummary
핵심 키워드: ${keywords.join(', ')}

스타일: 
- 감정에 맞는 색감과 분위기
- 일기 내용을 상징적으로 표현
- 따뜻하고 아름다운 일러스트레이션
- 한국적인 감성과 현대적인 디자인

이 그림은 사용자의 개인적인 감정과 경험을 표현하는 일기용 이미지입니다.
''';
  }

  /// 대화 내용에서 핵심 키워드 추출
  List<String> _extractKeywordsFromConversation(List<String> conversationHistory) {
    final keywords = <String>{};
    
    for (final message in conversationHistory) {
      // 감정 관련 키워드
      if (message.contains('기쁨') || message.contains('행복') || message.contains('즐거')) keywords.add('기쁨');
      if (message.contains('슬픔') || message.contains('우울') || message.contains('속상')) keywords.add('슬픔');
      if (message.contains('화남') || message.contains('짜증') || message.contains('열받')) keywords.add('화남');
      if (message.contains('평온') || message.contains('차분') || message.contains('편안')) keywords.add('평온');
      if (message.contains('설렘') || message.contains('기대') || message.contains('떨리')) keywords.add('설렘');
      if (message.contains('피곤함') || message.contains('지쳐') || message.contains('힘들')) keywords.add('피곤함');
      if (message.contains('놀람') || message.contains('깜짝') || message.contains('어이없')) keywords.add('놀람');
      if (message.contains('걱정') || message.contains('불안') || message.contains('초조')) keywords.add('걱정');
      
      // 활동 관련 키워드
      if (message.contains('산책') || message.contains('걷기')) keywords.add('산책');
      if (message.contains('음식') || message.contains('밥') || message.contains('먹')) keywords.add('음식');
      if (message.contains('친구') || message.contains('사람') || message.contains('만남')) keywords.add('사람');
      if (message.contains('일') || message.contains('업무') || message.contains('공부')) keywords.add('일/공부');
      if (message.contains('음악') || message.contains('노래')) keywords.add('음악');
      if (message.contains('영화') || message.contains('드라마')) keywords.add('영화/드라마');
    }
    
    return keywords.take(5).toList(); // 최대 5개 키워드
  }

  /// Gemini Pro Vision API 호출
  Future<String?> _callGeminiImageAPI(String prompt) async {
    final apiKey = _apiKey;
    if (apiKey.isEmpty) {
      print('❌ Gemini API 키가 없습니다.');
      return null;
    }

    final url = 'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=$apiKey';
    
    final requestBody = {
      'contents': [
        {
          'parts': [
            {
              'text': prompt
            }
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.8,
        'maxOutputTokens': 2048,
      },
    };
    
    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(requestBody),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // 실제 이미지 생성 API 응답 처리
        return data['candidates']?[0]?['content']?['parts']?[0]?['text'];
      } else {
        print('❌ 이미지 생성 API 오류: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ 이미지 생성 API 호출 실패: $e');
      return null;
    }
  }

  /// 일기 완성 및 요약 생성
  Future<String> generateDiarySummary(List<String> conversationHistory, String selectedEmotion) async {
    if (!_hasKey) {
      return _getFallbackSummary(conversationHistory, selectedEmotion);
    }

    try {
      final prompt = '''
사용자와의 대화를 바탕으로 일기를 작성해주세요.

대화 내용: ${conversationHistory.join('\n')}

**응답 스타일:**
- 제목, 내용, 마무리를 자연스럽게 하나로 통합
- 6-7문장을 넘지 않도록 간결하게 작성
- 대화 내용을 바탕으로 자연스러운 일기 본문 작성
- 사용자의 감정과 경험을 중심으로 하루를 정리
- 오늘 하루에 대한 소감과 내일에 대한 생각을 자연스럽게 연결


**주의사항:**
- 마크다운 표시나 과도한 이모지 사용하지 말기
- 각 섹션을 명확히 구분하지 말고 자연스럽게 연결
- 자연스럽고 따뜻한 톤으로 작성

한국어로 작성해주세요.
''';

      final response = await _callGeminiAPI(prompt);
      return response ?? _getFallbackSummary(conversationHistory, selectedEmotion);
    } catch (e) {
      print('일기 요약 생성 실패: $e');
      return _getFallbackSummary(conversationHistory, selectedEmotion);
    }
  }

  /// Gemini API 실제 호출
  Future<String?> _callGeminiAPI(String prompt) async {
    try {
      print('🌐 API URL: $_baseUrl?key=${_apiKey.substring(0, 10)}...');
      print('🌐 전체 URL: $_baseUrl?key=$_apiKey');
      print('📝 프롬프트 길이: ${prompt.length}');
      
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': prompt,
                },
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.8,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 2048,
          },
        }),
      );

      print('📡 HTTP 상태 코드: ${response.statusCode}');
      print('📡 응답 본문 길이: ${response.body.length}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print('📡 응답 데이터 키: ${data.keys.toList()}');
        
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            final text = parts[0]['text'] as String?;
            print('✅ API 응답 성공: ${text?.substring(0, 50)}...');
            return text;
          }
        }
        print('❌ 응답 데이터 구조 문제');
      } else {
        print('❌ HTTP 오류: ${response.statusCode} - ${response.body}');
      }
      return null;
    } catch (e) {
      print('❌ Gemini API 호출 중 오류: $e');
      return null;
    }
  }

  // Fallback 응답들
  String _getFallbackEmotionPrompt() {
    return '안녕하세요! 오늘 하루는 어떠셨나요? 특별히 기억에 남는 일이나 마음에 남는 순간이 있었나요? 다른 하고 싶은 말이 있으시면 언제든 말씀해주세요.';
  }

  String _getFallbackEmotionQuestion(String emotion) {
    return '그렇군요. 더 자세히 들려주세요. 어떤 생각을 하고 계신지 궁금해요. 편하게 이야기해주세요.';
  }

  String _getFallbackAnalysis(String diaryText, String emotion) {
    return '오늘 하루를 정리해주셔서 감사합니다. 일기를 통해 감정을 정리하는 것은 정말 좋은 습관입니다. 앞으로도 꾸준히 기록하며 자신을 돌아보는 시간을 가져보세요.';
  }

  String _getFallbackSummary(List<String> conversationHistory, String emotion) {
    return '오늘 하루도 수고하셨습니다. 다양한 경험과 감정을 느끼며 하루를 보내셨군요. 대화를 통해 하루를 정리하는 시간을 가질 수 있어서 좋았습니다. 일기를 통해 하루를 정리하고, 내일은 더 나은 하루가 되길 바랍니다.';
  }
}
