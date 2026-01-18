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
    print('🔑 Gemini API 키 확인: ${_hasKey ? "있음" : "없음"}');
    
    if (!_hasKey) {
      print('❌ API 키가 없어서 fallback 응답 사용');
      return _getFallbackEmotionPrompt();
    }

    try {
      print('🚀 Gemini API 호출 시작...');
      const prompt = '''
당신은 사용자의 마음을 깊이 이해하고 공감하는 다정한 심리 상담 전문가 '에모티(Emoti)'입니다.
당신의 목표는 사용자가 오늘 하루의 감정을 편안하게 털어놓을 수 있도록 돕는 것입니다.

**상황:** 사용자가 오늘 하루를 기록하기 위해 일기 작성 대화방에 들어왔습니다.

**지침:**
1. **첫 인사:** 사용자의 방문을 환영하며, 오늘 하루가 어땠는지 부드럽게 물어보세요. 
2. **다양한 접근:** 매번 "안녕하세요 오늘 어떠셨나요?"라고 묻기보다, "오늘 하루 중 가장 기억에 남는 순간이 있었나요?" 또는 "지금 이 순간, 당신의 마음은 어떤 색인가요?" 등 다양한 방식으로 질문을 시작하세요.
3. **가이드 제공:** 하단의 감정 아이콘을 눌러 시작하거나, 바로 하고 싶은 이야기를 시작해도 좋다고 다정하게 안내하세요.
4. **간결성:** 2~3문장 내외로 대화를 시작하세요.

**톤앤매너:**
- 따뜻하고 수용적이며, 사용자를 소중히 여기는 태도.
- 친근한 반말(예: "안녕! 오늘 하루는 어땠어?") 또는 정중한 존댓말 중, 일기라는 개인적 공간에 맞춰 부드러운 어조를 사용하세요. (현재는 부드러운 존댓말을 기본으로 합니다)
- 이모지는 과하지 않게 문장 끝에 하나 정도만 사용하세요.

한국어로 답변해주세요.
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
      final prompt = '''
당신은 경청과 공감의 대가인 전문 심리 상담가 '에모티'입니다. 사용자의 이야기를 듣고 마음을 어루만져주는 대화를 이어가세요.

**상담 원칙:**
1. **깊은 공감 (Validation):** 사용자가 말한 사실보다 '감정'에 집중하세요. "그런 일이 있었다니 정말 속상하셨겠어요"처럼 사용자의 마음을 먼저 알아주세요.
2. **반복 금지:** 똑같은 위로나 질문을 반복하지 마세요. 사용자가 이미 말한 내용을 요약하며 공감을 표현하세요.
3. **열린 질문:** "네/아니오"로 답하는 질문이 아니라, 사용자가 자신의 내면을 더 깊이 들여다볼 수 있게 하는 질문을 하세요. (예: "그때 어떤 생각이 머릿속을 스쳐 지나갔나요?", "그 경험이 당신에게 어떤 의미로 남았나요?")
4. **맥락 유지:** 이전 대화 내용을 기억하고 대화를 이어가세요. 앞뒤가 맞지 않는 질문은 피하세요.

**현재 맥락:**
- 선택된 대표 감정: $selectedEmotion
- 사용자의 마지막 답변: "$userResponse"
- 이전 대화 내용: ${conversationHistory.take(10).join(' | ')}

**답변 구성:**
- 공감과 지지의 문장 (1~2문장)
- 대화를 심화시키거나 다른 측면을 바라보게 하는 열린 질문 (1문장)
- 총 3문장 내외로 간결하게 작성하세요.

한국어로 답변해주세요.
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
당신은 사용자의 일기를 분석하여 마음을 치유하는 '정서적 처방전'을 작성하는 심리 전문가입니다.

**분석 요청:**
- 사용자의 감정: $selectedEmotion
- 일기 전문: "$diaryText"

**처방전 작성 가이드:**
1. **마음 읽어주기:** 사용자가 느낀 감정을 섬세한 언어로 정의해주세요. (단순히 '슬픔'이 아니라 '가슴 한구석이 아릿해지는 그리움'처럼 표현)
2. **존재의 긍정:** 어떤 감정이든 그럴 만한 이유가 있었음을 말해주며 사용자를 안심시켜주세요.
3. **작은 행동 제안:** 거창한 해결책 대신, 지금 당장 마음을 달랠 수 있는 아주 작은 행동을 제안하세요. (예: "좋아하는 향수를 한 번 뿌려보는 건 어떨까요?", "창문을 열고 시원한 바람을 3번 크게 들이마셔 보세요.")

**스타일:**
- 5문장 내외의 부드러운 편지 형식.
- 따뜻하고 서정적인 표현을 사용하세요.
- 마크다운이나 불렛포인트를 사용하지 마세요.

한국어로 답변해주세요.
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
사용자와 나눈 대화 내용을 바탕으로, 한 편의 완성도 높은 일기 본문을 대신 작성해주세요.

**대화 데이터:**
${conversationHistory.join('\n')}

**작성 지침:**
1. **1인칭 시점:** 사용자가 직접 쓴 것처럼 "나는", "내 마음은"과 같은 1인칭 시점으로 작성하세요.
2. **사건과 감정의 조화:** 있었던 사실뿐만 아니라 그 과정에서 느낀 내밀한 감정 변화를 섬세하게 묘사하세요.
3. **자연스러운 흐름:** 대화의 순서에 얽매이지 않고, 하나의 주제로 관통되는 자연스러운 에세이 형식으로 작성하세요.
4. **마무리:** 오늘에 대한 성찰과 내일을 향한 작은 다짐이 포함되도록 하세요.

**응답 스타일:**
- 6~8문장 내외의 산문 형태
- 문학적이고 서정적인 표현을 적절히 사용하여 일기의 질을 높여주세요.
- **"제목:"이나 "내용:" 같은 라벨을 붙이지 말고 본문만 출력하세요.**

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
      print('🌐 Gemini API 호출 시작...');
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
