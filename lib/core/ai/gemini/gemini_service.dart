import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Gemini AI 연동 서비스
class GeminiService {
  GeminiService._();
  static final GeminiService instance = GeminiService._();

  // API 키를 가져올 때 따옴표와 공백을 확실히 제거
  String get _apiKey => (dotenv.env['GEMINI_API_KEY'] ?? '')
      .trim()
      .replaceAll('"', '')
      .replaceAll("'", "");

  // v1beta에서 지원되는 텍스트 모델로 기본값 설정 (최신 모델 우선)
  String get _model => dotenv.env['GEMINI_MODEL']?.trim().isNotEmpty == true
      ? dotenv.env['GEMINI_MODEL']!.trim()
      : 'gemini-2.5-flash';

  String _buildEndpoint(String model) =>
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent';

  bool get _hasKey => _apiKey.isNotEmpty;

  /// 현재 API 키로 사용 가능한 모델 리스트를 조회하여 로그에 출력 (디버깅용)
  Future<void> listAvailableModels() async {
    if (!_hasKey) {
      print('❌ API 키가 설정되지 않아 모델 리스트를 조회할 수 없습니다.');
      return;
    }

    final url =
        'https://generativelanguage.googleapis.com/v1beta/models?key=$_apiKey';
    try {
      print('🔍 지원 모델 리스트 조회 중...');
      final response = await http.get(Uri.parse(url));
      print('📡 ListModels 응답 코드: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final models = data['models'] as List?;
        print('✅ 사용 가능한 모델 목록:');
        models?.forEach((m) => print(
            '  - ${m['name']} (지원 기능: ${m['supportedGenerationMethods']})'));
      } else {
        print('❌ 모델 리스트 조회 실패: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ 모델 리스트 조회 중 오류: $e');
    }
  }

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
사용자가 오늘 하루를 기록하기 위해 들어왔습니다. 첫 인사를 간단하게 해주세요.

**규칙:**
1. 1-2문장으로 짧게 (최대 2문장)
2. 과한 표현 금지 ("소중한", "마음이 전해지는" 등)
3. 감정 선택이나 자유롭게 이야기할 수 있다고 간단히 안내
4. 이모지 사용 금지

**예시:**
- "안녕하세요. 오늘 하루는 어떠셨나요?"
- "오늘 특별히 기억에 남는 일이 있었나요?"

한국어로 답변해주세요.
''';

      final response = await _callGeminiAPI(prompt);
      print(
          '📡 API 응답: ${response?.substring(0, response.length.clamp(0, 50)) ?? "null"}...');
      return response ?? _getFallbackEmotionPrompt();
    } catch (e) {
      print('❌ 초기 프롬프트 생성 실패: $e');
      return _getFallbackEmotionPrompt();
    }
  }

  /// 자연스러운 상담 대화를 위한 질문 생성
  Future<String> generateEmotionBasedQuestion(String selectedEmotion,
      String userResponse, List<String> conversationHistory) async {
    if (!_hasKey) {
      print('⚠️ GEMINI_API_KEY가 없어 Fallback 질문을 사용합니다.');
      return _getFallbackEmotionQuestion(
          selectedEmotion, userResponse, conversationHistory);
    }

    // 입력 검증: 의미 없는 답변 감지
    if (_isInvalidUserResponse(userResponse)) {
      print('⚠️ 이해할 수 없는 사용자 답변 감지: "$userResponse"');
      return _getInvalidResponseMessage();
    }

    try {
      final lastAiMessage = conversationHistory.reversed
          .firstWhere((m) => m.startsWith('AI:'), orElse: () => '')
          .replaceFirst('AI:', '')
          .trim();
      final userOnlyHistory = conversationHistory
          .where((m) => m.startsWith('사용자:'))
          .take(8)
          .map((m) => m.replaceFirst('사용자:', '').trim())
          .toList();

      final prompt = '''
당신은 사용자의 감정을 진심으로 이해하고 함께하는 대화 상대입니다.

**상황:**
- 사용자 감정: $selectedEmotion
- 사용자가 방금 말한 내용: "$userResponse"
- 이전 대화 맥락: ${userOnlyHistory.join(' | ')}
- 방금 전 당신이 한 말 (반복 금지): "$lastAiMessage"

**대화 원칙:**
1. **진짜 공감**: 감정을 중요하게 받아들이세요. "그렇군요" 같은 무미건조한 반응 금지.
2. **자연스러운 반응**: 상황에 맞게 반응하세요.
   - 슬픔/힘듦 → 공감 + 위로 (때로는 응원)
   - 기쁨/설렘 → 함께 기뻐하기
   - 분노/답답함 → 공감 + (필요시) 해결 방향 제안
3. **적당한 길이**: 3-4문장 (너무 짧거나 길지 않게)
4. **스마트한 질문**: 
   - 너무 세세한 건 묻지 마세요 (예: "어떤 면접이었나요?" → 어색함)
   - 감정이나 느낌 중심으로 질문하세요 (예: "그때 어떤 기분이 드셨어요?")
5. **다양한 반응**: 공감/위로/궁금증/응원/해결방법을 상황에 맞게 섞으세요.

**좋은 예시 (면접 탈락 - 슬픔):**
많이 실망스러우셨겠어요. 준비한 만큼 기대도 컸을 텐데 정말 속상하셨을 것 같아요.
지금은 힘들겠지만, 이 경험이 다음 기회에는 분명 도움이 될 거예요. 지금 기분이 어떠세요?

**좋은 예시 (친구와 싸움 - 분노):**
정말 화가 나셨겠어요. 친한 사이일수록 더 서운하고 답답하죠.
조금 시간을 두고 마음을 정리한 다음, 솔직하게 이야기해 보는 건 어떨까요? 지금 가장 힘든 부분은 뭐예요?

**좋은 예시 (좋은 소식 - 기쁨):**
와, 정말 축하드려요! 그 순간이 정말 특별했을 것 같아요.
얼마나 기뻤을지 상상이 가네요. 그때 어떤 생각이 드셨어요?

**나쁜 예시 (너무 세세한 질문):**
면접에서 떨어지셨군요. 어떤 회사 면접이었나요? 몇 차 면접이었어요?

**나쁜 예시 (딱딱함):**
그렇군요. 어떤 일이 있었나요?

**출력:**
3-4문장의 자연스러운 대화 (상황에 맞는 공감/위로/응원/해결방법 포함)

한국어로 답변해주세요.
''';

      final response = await _callGeminiAPI(prompt);
      if (response == null || response.trim().isEmpty) {
        print('⚠️ Gemini 응답이 비어있어 Fallback 질문을 사용합니다.');
        return _getFallbackEmotionQuestion(
            selectedEmotion, userResponse, conversationHistory);
      }
      return response;
    } catch (e) {
      print('상담 질문 생성 실패: $e');
      return _getFallbackEmotionQuestion(
          selectedEmotion, userResponse, conversationHistory);
    }
  }

  /// 감정 분석 및 위로 메시지 생성
  Future<String> analyzeEmotionAndComfort(
      String diaryText, String selectedEmotion) async {
    if (!_hasKey) {
      return _getFallbackAnalysis(diaryText, selectedEmotion);
    }

    try {
      final prompt = '''
사용자의 일기를 읽고, 감정에 공감하며 자연스럽게 반응해주세요.

**일기 내용:**
- 감정: $selectedEmotion
- 내용: "$diaryText"

**출력 구조:**
1. **공감 (1-2문장)**: 감정을 진심으로 인정하고 공감
   ↓ 줄바꿈
2. **이해/반영 (1-2문장)**: 일기 핵심 내용 반영 (과장 금지)
   ↓ 줄바꿈
3. **응원/제안 (0-2문장)**: 상황에 맞게 선택
   - 힘든 상황 → 응원이나 작은 위로
   - 좋은 상황 → 함께 기뻐하기
   - 고민 상황 → (필요시) 가벼운 해결 방향 제안
   - 평범한 상황 → 생략 가능

**필수 규칙:**
- **총 3-5문장** (너무 짧거나 길지 않게)
- **줄바꿈 필수**: 문단마다 빈 줄 넣기
- **과한 표현 금지**: "아릿한", "포근한", "온기" 등 시적 표현 사용 금지
- **자연스러운 존댓말**: 편안하고 따뜻하게

**좋은 예시 (면접 탈락 - 슬픔):**
많이 실망스러우셨겠어요. 준비한 만큼 더 속상하셨을 것 같아요.

면접 결과는 아쉽지만, 이 경험이 다음엔 분명 도움이 될 거예요.

지금은 조금 쉬면서 마음을 추스르시길 바라요.

**좋은 예시 (좋은 일 - 기쁨):**
정말 좋은 소식이네요! 그동안 노력한 게 결실을 맺은 것 같아요.

이런 순간이 오래 기억에 남을 것 같네요.

**나쁜 예시 (너무 시적):**
오늘 당신의 마음에 아릿한 슬픔이 깃들었군요. 그 눈물 한 방울 한 방울이 저에게까지 포근하게 전해지는 것 같아요...

**나쁜 예시 (줄바꿈 없음):**
많이 힘드셨겠어요. 그런 상황이라면 누구라도 속상할 것 같아요. 조금 쉬면서 마음을 추스르시길 바라요.

**출력:**
3-5문장의 자연스러운 메시지 (문단마다 빈 줄로 구분)

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
  Future<String?> generateImage(String diarySummary, String? selectedEmotion,
      List<String> conversationHistory) async {
    try {
      // 채팅 내용과 감정을 바탕으로 상세한 프롬프트 생성
      final detailedPrompt = _createDetailedImagePrompt(
          diarySummary, selectedEmotion, conversationHistory);

      // Gemini Pro Vision API 호출
      final response = await _callGeminiImageAPI(detailedPrompt);
      return response;
    } catch (e) {
      print('AI 이미지 생성 실패: $e');
      return null;
    }
  }

  /// 상세한 이미지 생성 프롬프트 생성
  String _createDetailedImagePrompt(String diarySummary,
      String? selectedEmotion, List<String> conversationHistory) {
    final emotionDescription =
        selectedEmotion != null ? '감정: $selectedEmotion' : '감정: 자연스러운';

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
  List<String> _extractKeywordsFromConversation(
      List<String> conversationHistory) {
    final keywords = <String>{};

    for (final message in conversationHistory) {
      // 감정 관련 키워드
      if (message.contains('기쁨') ||
          message.contains('행복') ||
          message.contains('즐거')) keywords.add('기쁨');
      if (message.contains('슬픔') ||
          message.contains('우울') ||
          message.contains('속상')) keywords.add('슬픔');
      if (message.contains('화남') ||
          message.contains('짜증') ||
          message.contains('열받')) keywords.add('화남');
      if (message.contains('평온') ||
          message.contains('차분') ||
          message.contains('편안')) keywords.add('평온');
      if (message.contains('설렘') ||
          message.contains('기대') ||
          message.contains('떨리')) keywords.add('설렘');
      if (message.contains('피곤함') ||
          message.contains('지쳐') ||
          message.contains('힘들')) keywords.add('피곤함');
      if (message.contains('놀람') ||
          message.contains('깜짝') ||
          message.contains('어이없')) keywords.add('놀람');
      if (message.contains('걱정') ||
          message.contains('불안') ||
          message.contains('초조')) keywords.add('걱정');

      // 활동 관련 키워드
      if (message.contains('산책') || message.contains('걷기')) keywords.add('산책');
      if (message.contains('음식') ||
          message.contains('밥') ||
          message.contains('먹')) keywords.add('음식');
      if (message.contains('친구') ||
          message.contains('사람') ||
          message.contains('만남')) keywords.add('사람');
      if (message.contains('일') ||
          message.contains('업무') ||
          message.contains('공부')) keywords.add('일/공부');
      if (message.contains('음악') || message.contains('노래')) keywords.add('음악');
      if (message.contains('영화') || message.contains('드라마'))
        keywords.add('영화/드라마');
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

    return await _callGeminiWithFallbackModels(prompt);
  }

  /// 일기 완성 및 요약 생성
  Future<String> generateDiarySummary(
      List<String> conversationHistory, String selectedEmotion) async {
    if (!_hasKey) {
      return _getFallbackSummary(conversationHistory, selectedEmotion);
    }

    try {
      // 대화량 계산
      final conversationCount =
          conversationHistory.where((m) => m.startsWith('사용자:')).length;
      final isShortConversation = conversationCount < 5;

      final prompt = '''
사용자와 나눈 대화를 바탕으로 일기를 완성해주세요.

**대화 내용:**
${conversationHistory.join('\n')}

**감정:** $selectedEmotion

**핵심 원칙 (반드시 지켜주세요):**
1. **사실만 기록**: 사용자가 말한 내용만 작성하세요. 추측이나 과장 금지.
2. **1인칭 시점**: "나는", "내가" 등 사용자가 직접 쓴 것처럼.
3. **자연스러운 일기체**: 진솔하고 편안한 말투로.
4. **가독성**: 2-3문장마다 줄바꿈을 넣어주세요.

**길이 (대화량에 비례):**
${isShortConversation ? '- 짧은 대화 → 4-6문장 (간결하게)\n- 무리하게 늘리지 마세요.' : '- 충분한 대화 → 6-10문장\n- 대화 내용을 충실히 반영하세요.'}

**금지사항:**
- "아릿한", "포근한", "온기가 전해지는" 등 시적 표현 사용 금지
- 사용자가 말하지 않은 내용 추가 금지
- "제목:", "내용:" 같은 라벨 금지

**출력 형식:**
일기 본문만 출력하세요.
2-3문장마다 줄바꿈을 넣어 가독성을 높이세요.

한국어로 작성해주세요.
''';

      final response = await _callGeminiAPI(prompt);
      return response ??
          _getFallbackSummary(conversationHistory, selectedEmotion);
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

      return await _callGeminiWithFallbackModels(prompt);
    } catch (e) {
      print('❌ Gemini API 호출 중 오류: $e');
      return null;
    }
  }

  Future<String?> _callGeminiWithFallbackModels(String prompt) async {
    // ListModels 결과에서 확인된 실제 사용 가능한 모델들
    final models = <String>[
      _model,
      'gemini-3-flash-preview',
      'gemini-2.5-flash',
      'gemini-2.0-flash',
      'gemini-flash-latest',
      'gemini-pro-latest',
    ].toSet().where((m) => m.isNotEmpty).toList();

    for (final model in models) {
      final endpoint = _buildEndpoint(model);
      print('🧪 모델 시도: $model');
      final response = await http.post(
        Uri.parse('$endpoint?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
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

      print('📡 HTTP 상태 코드($model): ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            final text = parts[0]['text'] as String?;
            if (text != null && text.trim().isNotEmpty) {
              final preview = text.substring(0, text.length.clamp(0, 50));
              print('✅ API 응답 성공($model): $preview...');
              return text;
            }
          }
        }
        print('❌ 응답 데이터 구조 문제($model)');
      } else {
        print('❌ HTTP 오류($model): ${response.statusCode} - ${response.body}');
      }
    }
    return null;
  }

  // 입력 검증 메서드들

  /// 사용자 답변이 의미 없는지 검증
  bool _isInvalidUserResponse(String response) {
    final trimmed = response.trim();

    // 1. 너무 짧은 답변 (1-2글자)
    if (trimmed.length <= 2) {
      return true;
    }

    // 2. 의미 없는 문자 반복 (예: "ㅋㅋㅋㅋ", "....", "ㅠㅠㅠ")
    if (RegExp(r'^(.)\1{3,}$').hasMatch(trimmed)) {
      return true;
    }

    // 3. 랜덤 키 입력처럼 보이는 경우 (예: "asdf", "qwer", "zxcv")
    final randomKeyPatterns = [
      'asdf',
      'qwer',
      'zxcv',
      'asdfg',
      'qwert',
      'dfgh',
      'fghj',
      'ghjk',
      'hjkl'
    ];
    if (randomKeyPatterns.any((pattern) =>
        trimmed.toLowerCase().contains(pattern) && trimmed.length < 10)) {
      return true;
    }

    // 4. 대부분이 특수문자인 경우
    final specialCharCount =
        RegExp(r'[^\wㄱ-ㅎㅏ-ㅣ가-힣\s]', unicode: true).allMatches(trimmed).length;
    if (specialCharCount > trimmed.length * 0.7) {
      return true;
    }

    // 5. 숫자만 입력한 경우 (날짜가 아닌)
    if (RegExp(r'^\d+$').hasMatch(trimmed) && trimmed.length < 5) {
      return true;
    }

    return false;
  }

  /// 이해할 수 없는 답변에 대한 응답
  String _getInvalidResponseMessage() {
    final messages = [
      '죄송해요, 제가 잘 이해하지 못했어요. 조금 더 자세히 말씀해 주실 수 있을까요?',
      '음... 무슨 말씀이신지 잘 모르겠어요. 어떤 일이 있었는지 이야기해 주시겠어요?',
      '잘 이해가 안 돼요. 지금 기분이 어떤지, 무슨 일이 있었는지 편하게 이야기해 주세요.',
      '조금 더 구체적으로 말씀해 주실 수 있나요? 오늘 어떤 하루였는지 궁금해요.',
    ];
    return messages[DateTime.now().millisecond % messages.length];
  }

  // Fallback 응답들
  String _getFallbackEmotionPrompt() {
    return '안녕하세요. 오늘 하루는 어떠셨나요?';
  }

  String _getFallbackEmotionQuestion(
      String emotion, String userResponse, List<String> conversationHistory) {
    final normalizedEmotion = emotion.trim().isEmpty ? '평온' : emotion;
    final lastUser = userResponse.trim();

    final seed = (conversationHistory.join('|') + lastUser + normalizedEmotion)
        .hashCode
        .abs();

    if (_looksGibberish(lastUser)) {
      return '조금 더 자세히 말씀해 주실 수 있을까요? 어떤 상황이었는지 궁금해요.';
    }

    // 감정별 자연스러운 응답 (3-4문장)
    final emotionResponses = {
      '기쁨': [
        '좋은 일이 있었나 봐요! 그런 순간이 있으면 정말 기분이 좋죠. 어떤 일이 있었는지 더 들려주실 수 있을까요?',
        '오늘 기분 좋은 일이 있으셨군요. 그 순간이 특별했을 것 같아요. 구체적으로 어떤 일이었나요?',
        '와, 정말 좋았겠어요. 그런 기분은 오래 기억에 남죠. 어떤 일이 있었는지 자세히 들려주세요!',
      ],
      '슬픔': [
        '오늘 많이 힘드셨나 봐요. 그런 감정을 느끼는 건 정말 쉽지 않죠. 무슨 일이 있었는지 편하게 말씀해 주세요. 이야기하는 것만으로도 조금은 나아질 수 있어요.',
        '힘든 하루를 보내신 것 같네요. 혼자 그 감정을 안고 계시기 쉽지 않았을 것 같아요. 어떤 일이 있었는지 들려주실래요?',
        '많이 속상하셨겠어요. 그런 일을 겪으면 누구나 힘들 거예요. 지금은 힘들겠지만, 조금씩 나아질 거예요. 무슨 일이 있었나요?',
      ],
      '분노': [
        '정말 화가 나셨나 봐요. 그럴 만한 이유가 있으셨을 것 같아요. 어떤 일 때문에 그렇게 화가 나셨나요? 이야기하면 조금 풀릴 수도 있어요.',
        '많이 답답하고 화가 나셨을 것 같아요. 그런 감정을 느끼는 건 당연해요. 무슨 일이 있었는지 말씀해 주세요.',
        '화가 나는 일이 있으셨군요. 그 순간에는 정말 힘들었을 것 같아요. 조금 시간을 두고 마음을 정리하는 것도 도움이 될 수 있어요. 어떤 상황이었나요?',
      ],
      '불안': [
        '불안한 마음이 드셨군요. 그런 감정은 정말 불편하죠. 무엇 때문에 불안하셨는지 말씀해 주실 수 있을까요? 함께 이야기하면 조금 나아질 거예요.',
        '마음이 편치 않으셨나 봐요. 불안한 건 혼자 견디기 힘들죠. 어떤 일 때문에 그러셨어요?',
        '불안하셨다니, 많이 힘드셨겠어요. 깊게 숨을 쉬고 천천히 생각해 보는 것도 도움이 될 수 있어요. 그 불안이 어디서 온 건지 조금 더 이야기해 주실래요?',
      ],
      '평온': [
        '평온한 시간을 보내셨나 봐요. 그런 순간이 있다는 게 참 좋은 것 같아요. 오늘 어떤 일이 있었나요?',
        '마음이 편안하셨군요. 그런 평온함을 느낄 수 있다는 게 좋네요. 어떤 순간이 그랬는지 들려주세요.',
      ],
      '설렘': [
        '설레는 일이 있으셨나 봐요! 그런 기분은 정말 특별하죠. 무엇 때문에 그렇게 설레셨어요?',
        '오늘 설레는 순간이 있으셨군요. 그 느낌이 정말 좋았을 것 같아요. 어떤 일이 있었나요?',
      ],
      '걱정': [
        '걱정되는 일이 있으시군요. 그런 마음을 안고 있기 쉽지 않으셨을 것 같아요. 무엇이 걱정되시나요?',
        '마음에 걱정이 있으신가 봐요. 그 걱정을 혼자 안고 계시기 힘들었을 것 같아요. 어떤 부분이 걱정되세요?',
      ],
    };

    // 감정별 응답에서 선택
    final responses = emotionResponses[normalizedEmotion];
    if (responses != null && responses.isNotEmpty) {
      return responses[seed % responses.length];
    }

    // 기본 응답 (감정 정보가 없을 때)
    final defaultResponses = [
      '오늘 어떤 일이 있으셨나요? 편하게 말씀해 주세요.',
      '무슨 일이 있었는지 들려주실래요? 궁금해요.',
      '어떤 하루를 보내셨는지 이야기해 주시겠어요?',
    ];
    return defaultResponses[seed % defaultResponses.length];
  }

  String _shorten(String text) {
    if (text.length <= 24) return text;
    return '${text.substring(0, 24)}...';
  }

  bool _looksGibberish(String text) {
    if (text.isEmpty) return true;
    if (text.length <= 2) return true;
    final hasKorean = RegExp(r'[가-힣]').hasMatch(text);
    final hasAlnum = RegExp(r'[a-zA-Z0-9]').hasMatch(text);
    return !hasKorean && hasAlnum && text.length <= 4;
  }

  String _pickNextQuestion(
      List<String> candidates, List<String> history, int seed) {
    final lastAi = history.reversed.firstWhere(
      (msg) => msg.startsWith('AI:'),
      orElse: () => '',
    );
    final filtered = candidates.where((q) => !lastAi.contains(q)).toList();
    final pool = filtered.isNotEmpty ? filtered : candidates;
    return pool[seed % pool.length];
  }

  String _getFallbackAnalysis(String diaryText, String emotion) {
    return '오늘 하루를 정리해주셔서 감사합니다. 일기를 통해 감정을 정리하는 것은 정말 좋은 습관입니다. 앞으로도 꾸준히 기록하며 자신을 돌아보는 시간을 가져보세요.';
  }

  String _getFallbackSummary(List<String> conversationHistory, String emotion) {
    return '오늘 하루도 수고하셨습니다. 다양한 경험과 감정을 느끼며 하루를 보내셨군요. 대화를 통해 하루를 정리하는 시간을 가질 수 있어서 좋았습니다. 일기를 통해 하루를 정리하고, 내일은 더 나은 하루가 되길 바랍니다.';
  }
}
