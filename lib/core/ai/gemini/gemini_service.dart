import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Gemini AI 연동 서비스
class GeminiService {
  GeminiService._();
  static final GeminiService instance = GeminiService._();

  // 환경 변수에서 API 키 가져오기
  String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  bool get _hasKey => _apiKey.isNotEmpty;

  /// 감정 선택을 위한 초기 질문 생성
  Future<String> generateEmotionSelectionPrompt() async {
    if (!_hasKey) {
      return _getFallbackEmotionPrompt();
    }

    try {
      final prompt = '''
당신은 따뜻하고 공감적인 AI 친구입니다.

사용자가 일기를 작성하려고 합니다. 먼저 오늘 하루의 감정 상태를 파악하기 위해 
자연스럽고 친근하게 감정을 물어보는 질문을 해주세요.

예시:
- "안녕하세요! 오늘 하루는 어뭇셨나요? 어떤 감정을 느끼고 계신지 궁금해요."
- "오늘 하루도 수고하셨네요. 지금 마음 상태는 어떠신가요?"

한국어로 친근하고 따뜻한 톤으로 답변해주세요. 질문은 하나만 하고, 너무 길지 않게 해주세요.
''';

      final response = await _callGeminiAPI(prompt);
      return response ?? _getFallbackEmotionPrompt();
    } catch (e) {
      print('감정 선택 프롬프트 생성 실패: $e');
      return _getFallbackEmotionPrompt();
    }
  }

  /// 감정에 따른 맞춤형 질문 생성
  Future<String> generateEmotionBasedQuestion(String selectedEmotion, String userResponse, List<String> conversationHistory) async {
    if (!_hasKey) {
      return _getFallbackEmotionQuestion(selectedEmotion);
    }

    try {
      final prompt = '''
당신은 감정 일기 작성을 도와주는 AI 친구입니다.

선택된 감정: $selectedEmotion
사용자 응답: $userResponse
대화 히스토리: ${conversationHistory.join(', ')}

사용자의 감정을 더 깊이 이해할 수 있도록 자연스러운 다음 질문을 생성해주세요.

감정별 질문 예시:
- 기쁨: "정말 기쁜 일이 있었군요! 어떤 일이었는지 더 자세히 들려주세요."
- 슬픔: "힘든 시간을 보내고 계시는군요. 언제부터 그런 감정을 느끼게 되었나요?"
- 분노: "화가 나는 일이 있었군요. 어떤 상황이었는지 말씀해주세요."
- 평온: "차분한 마음으로 하루를 보내고 계시는군요. 어떤 생각을 하고 계셨나요?"

한국어로 친근하고 따뜻한 톤으로 질문해주세요. 질문은 하나만 하고, 너무 길지 않게 해주세요.
''';

      final response = await _callGeminiAPI(prompt);
      return response ?? _getFallbackEmotionQuestion(selectedEmotion);
    } catch (e) {
      print('감정 기반 질문 생성 실패: $e');
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

다음 형식으로 답변해주세요:

1. 감정 분석 (어떤 감정을 느끼고 있는지, 왜 그런 감정을 느끼는지)
2. 공감과 이해 (상황에 대한 공감과 이해)
3. 따뜻한 위로 (구체적이고 따뜻한 위로 메시지)
4. 조언 (실행 가능한 구체적인 조언)

한국어로 친근하고 따뜻한 톤으로 답변해주세요. 
사용자가 실제로 도움을 받을 수 있도록 구체적이고 실용적인 내용으로 작성해주세요.
''';

      final response = await _callGeminiAPI(prompt);
      return response ?? _getFallbackAnalysis(diaryText, selectedEmotion);
    } catch (e) {
      print('감정 분석 및 위로 생성 실패: $e');
      return _getFallbackAnalysis(diaryText, selectedEmotion);
    }
  }

  /// 일기 완성 및 요약 생성
  Future<String> generateDiarySummary(List<String> conversationHistory, String selectedEmotion) async {
    if (!_hasKey) {
      return _getFallbackSummary(conversationHistory, selectedEmotion);
    }

    try {
      final prompt = '''
당신은 감정 일기 작성을 도와주는 AI 친구입니다.

사용자와의 대화를 바탕으로 오늘 하루의 일기를 요약하고 정리해주세요.

선택된 감정: $selectedEmotion
대화 내용: ${conversationHistory.join('\n')}

다음 형식으로 일기를 요약해주세요:

1. 오늘 하루 요약 (사용자가 경험한 일들을 자연스럽게 연결)
2. 감정 상태 (선택된 감정과 실제 느낀 감정을 종합)
3. 인사이트 (하루를 돌아보며 얻은 깨달음이나 생각)

한국어로 자연스럽고 따뜻한 톤으로 작성해주세요. 
사용자의 말투와 감정을 반영하여 개인화된 일기가 되도록 해주세요.
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
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            return parts[0]['text'] as String?;
          }
        }
      }
      return null;
    } catch (e) {
      print('Gemini API 호출 중 오류: $e');
      return null;
    }
  }

  // Fallback 응답들
  String _getFallbackEmotionPrompt() {
    return '안녕하세요! 오늘 하루는 어뭇셨나요? 어떤 감정을 느끼고 계신지 궁금해요. 😊';
  }

  String _getFallbackEmotionQuestion(String emotion) {
    switch (emotion) {
      case '기쁨':
        return '정말 기쁜 일이 있었군요! 어떤 일이었는지 더 자세히 들려주세요.';
      case '슬픔':
        return '힘든 시간을 보내고 계시는군요. 언제부터 그런 감정을 느끼게 되었나요?';
      case '분노':
        return '화가 나는 일이 있었군요. 어떤 상황이었는지 말씀해주세요.';
      case '평온':
        return '차분한 마음으로 하루를 보내고 계시는군요. 어떤 생각을 하고 계셨나요?';
      case '설렘':
        return '설레는 일이 있으신가요? 어떤 일이 기대되시나요?';
      case '걱정':
        return '걱정되는 일이 있으신가요? 어떤 부분이 가장 걱정되시나요?';
      case '감사':
        return '감사한 마음을 느끼고 계시는군요. 어떤 일에 감사하시나요?';
      case '지루함':
        return '지루한 하루를 보내고 계시는군요. 어떤 일을 하고 싶으신가요?';
      default:
        return '오늘 하루는 어떠셨나요? 더 자세히 들려주세요.';
    }
  }

  String _getFallbackAnalysis(String diaryText, String emotion) {
    return '오늘 하루를 정리해주셔서 감사합니다. $emotion을 느끼며 하루를 보내셨군요. '
           '일기를 통해 감정을 정리하는 것은 정말 좋은 습관입니다. '
           '앞으로도 꾸준히 기록하며 자신을 돌아보는 시간을 가져보세요. 💪';
  }

  String _getFallbackSummary(List<String> conversationHistory, String emotion) {
    return '오늘 하루도 수고하셨습니다. $emotion을 느끼며 다양한 경험을 하셨군요. '
           '일기를 통해 하루를 정리하고, 내일은 더 나은 하루가 되길 바랍니다. 🌟';
  }
}
