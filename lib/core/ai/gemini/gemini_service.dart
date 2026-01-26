import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../features/diary/domain/entities/diary_entry.dart';

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

  /// 일기 요약 생성 (상세 분석용)
  Future<String> generateDetailedDiarySummary(DiaryEntry entry) async {
    if (!_hasKey) {
      return _getFallbackDetailedSummary(entry);
    }

    try {
      final emotionInfo = entry.emotions.isNotEmpty
          ? entry.emotions.join(', ')
          : '감정 없음';

      final prompt = '''
당신은 전문적인 심리 상담가이자 일기 분석 전문가입니다. 다음 일기를 깊이 있게 분석하여 정확하고 의미 있는 요약을 작성해주세요.

**일기 정보:**
- 제목: ${entry.title.isNotEmpty ? entry.title : '제목 없음'}
- 내용: ${entry.content}
- 감정: $emotionInfo
- 작성일: ${entry.createdAt.toString().substring(0, 10)}
${entry.diaryType == DiaryType.aiChat && entry.chatHistory.isNotEmpty ? '- 대화 내역: ${entry.chatHistory.length}개의 메시지가 있었습니다.\n' : ''}

**요약 작성 원칙:**

1. **핵심 내용 정확히 파악**
   - 일기에서 언급된 구체적인 사건, 상황, 사람, 장소를 정확히 파악
   - 작성자가 느낀 감정의 변화와 그 원인을 이해
   - 일기에서 드러난 작성자의 생각, 고민, 관점을 파악

2. **구조화된 요약 작성**
   - **첫 문장**: 일기의 핵심 주제를 한 문장으로 명확히 제시
     예: "오늘은 [주요 사건]으로 인해 [주요 감정]을 느꼈다."
   - **두 번째 문단 (2-3문장)**: 주요 사건과 감정을 구체적으로 설명
     - 언제, 어디서, 무엇이 일어났는지
     - 그로 인해 어떤 감정을 느꼈는지
     - 감정의 강도와 변화 과정
   - **세 번째 문단 (1-2문장)**: 일기에서 드러난 생각이나 느낌
     - 작성자의 관점이나 태도
     - 일기를 통해 표현하고 싶었던 핵심 메시지

3. **감정 반영**
   - 감정과 강도를 요약에 자연스럽게 포함
   - 감정의 변화 과정이 있다면 그 흐름을 설명
   - 복합적인 감정이라면 각 감정의 관계를 설명

4. **톤과 스타일**
   - 객관적이면서도 공감적인 톤
   - 사실을 바탕으로 하되, 작성자의 감정을 이해하는 방식
   - 과장 없이 정확하게, 하지만 따뜻하게

5. **길이와 구조**
   - 총 4-6문장으로 간결하게
   - 각 문장은 명확하고 구체적
   - 불필요한 수식어나 장식적 표현 지양

**금지사항 (반드시 지켜주세요):**
- ❌ 과장된 표현 사용 금지 ("엄청난", "대단한", "놀라운" 등)
- ❌ 일기에 없는 내용 추가 금지 (추측이나 일반화 금지)
- ❌ 일반적인 조언이나 격려 문구 포함 금지 (요약만 작성)
- ❌ "~한 것 같다", "~할 수도 있다" 같은 추측 표현 금지
- ❌ 시적이거나 문학적인 표현 지양 ("아릿한", "포근한" 등)

**출력 형식:**
요약만 작성하세요. 제목이나 라벨 없이 바로 요약 내용만 출력해주세요.

한국어로 작성해주세요.
''';

      final response = await _callGeminiAPI(prompt);
      return response ?? _getFallbackDetailedSummary(entry);
    } catch (e) {
      print('일기 요약 생성 실패: $e');
      return _getFallbackDetailedSummary(entry);
    }
  }

  /// 일기 상세 조언 생성 (상세 분석용)
  Future<String> generateDetailedAdvice(DiaryEntry entry) async {
    if (!_hasKey) {
      return _getFallbackDetailedAdvice(entry);
    }

    try {
      final primaryEmotion =
          entry.emotions.isNotEmpty ? entry.emotions.first : '평온';
      final emotionIntensity = entry.emotionIntensities[primaryEmotion] ?? 5;
      final allEmotions = entry.emotions.isNotEmpty
          ? entry.emotions.join(', ')
          : '감정 없음';

      final prompt = '''
당신은 전문적인 심리 상담가이자 감정 코치입니다. 다음 일기를 깊이 있게 분석하여 구체적이고 실용적인 조언을 제공해주세요.

**일기 정보:**
- 제목: ${entry.title.isNotEmpty ? entry.title : '제목 없음'}
- 내용: ${entry.content}
- 주요 감정: $primaryEmotion
${entry.emotions.length > 1 ? '- 전체 감정: ${entry.emotions.join(', ')}\n' : ''}
- 작성일: ${entry.createdAt.toString().substring(0, 10)}
${entry.diaryType == DiaryType.aiChat && entry.chatHistory.isNotEmpty ? '- 대화 맥락: AI와 나눈 대화를 통해 작성된 일기입니다.\n' : ''}

**조언 작성 원칙:**

1. **깊이 있는 맥락 이해**
   - 일기의 내용을 단순히 읽는 것이 아니라, 작성자의 상황과 감정을 깊이 이해
   - 감정의 원인과 배경을 파악
   - 작성자가 표현하지 못한 부분까지 고려하여 종합적으로 분석

2. **구체적이고 실행 가능한 조언**
   - 추상적인 조언("긍정적으로 생각하세요") 지양
   - 구체적인 행동 제안 포함 ("오늘 저녁에 10분간 산책을 해보세요")
   - 실현 가능한 단계별 제안
   - 일기 내용과 직접적으로 연관된 조언

3. **감정에 맞는 톤과 접근**
   - **긍정적 감정 (기쁨, 사랑, 설렘 등)**: 
     * 축하와 함께 이 감정을 더 오래 유지하거나 깊게 경험할 수 있는 방법 제시
     * 긍정적 경험을 성장의 기회로 활용하는 방법
   - **부정적 감정 (슬픔, 분노, 걱정 등)**:
     * 먼저 공감과 이해를 표현
     * 감정을 건강하게 처리하는 방법 제시
     * 구체적인 해결책이나 대처 방안 제시
     * 필요시 전문가 상담 권유 (심각한 경우)
   - **중립적 감정 (평온, 지루함 등)**:
     * 현재 상태를 인정하면서도 성장 기회 제시
     * 새로운 경험이나 도전을 제안

4. **구조화된 조언 작성**
   - **첫 문단 (2-3문장)**: 일기 내용에 대한 공감과 이해
     * 작성자가 경험한 상황과 감정을 정확히 파악했음을 보여줌
     * "~하신 것 같습니다", "~하셨군요" 같은 공감 표현
   - **두 번째 문단 (2-3문장)**: 구체적인 조언 1-2가지
     * 일기 내용과 직접 연관된 실용적인 조언
     * 구체적인 행동 제안 포함
     * 예: "이런 상황에서는 ~하는 것이 도움이 될 수 있습니다"
   - **세 번째 문단 (1-2문장)**: 장기적인 관점에서의 제안
     * 단기적 해결책을 넘어서는 성장 방향 제시
     * 감정 관리나 자기 이해를 위한 장기적 관점

5. **길이와 깊이**
   - 총 5-8문장으로 충분히 상세하게
   - 각 문장은 의미 있고 구체적
   - 표면적인 조언이 아닌 깊이 있는 인사이트 제공

**금지사항 (반드시 지켜주세요):**
- ❌ 일반적인 격려 문구만 나열 금지 ("힘내세요", "좋아질 거예요" 등)
- ❌ 일기 내용과 무관한 일반적인 조언 금지
- ❌ 과도하게 긍정적이거나 부정적인 톤 금지 (현실적이고 균형잡힌 접근)
- ❌ 추상적이고 실행 불가능한 조언 금지
- ❌ 일기에 없는 내용을 가정한 조언 금지
- ❌ 의학적 진단이나 처방 금지 (전문가 상담 권유는 가능)

**조언 스타일:**
- 따뜻하고 공감적이면서도 현실적
- 전문적이지만 친근하고 이해하기 쉬운 톤
- 구체적인 행동 제안과 실용적인 해결책 포함
- 작성자의 상황에 맞춘 맞춤형 조언

**출력 형식:**
조언만 작성하세요. 제목이나 라벨 없이 바로 조언 내용만 출력해주세요.

한국어로 작성해주세요.
''';

      final response = await _callGeminiAPI(prompt);
      return response ?? _getFallbackDetailedAdvice(entry);
    } catch (e) {
      print('상세 조언 생성 실패: $e');
      return _getFallbackDetailedAdvice(entry);
    }
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

    // 2. 같은 문자 반복 (예: "fff", "ㅋㅋㅋ", "....", "ㅠㅠㅠ")
    // 같은 문자가 2번 이상 반복되고 전체 길이가 5글자 이하면 무효
    if (RegExp(r'^(.)\1{2,}$').hasMatch(trimmed) && trimmed.length <= 5) {
      return true;
    }
    // 같은 문자가 4번 이상 반복되면 무조건 무효
    if (RegExp(r'^(.)\1{3,}$').hasMatch(trimmed)) {
      return true;
    }

    // 3. 랜덤 키 입력처럼 보이는 경우 (예: "asdf", "qwer", "zxcv", "fff")
    final randomKeyPatterns = [
      'asdf', 'qwer', 'zxcv', 'asdfg', 'qwert',
      'dfgh', 'fghj', 'ghjk', 'hjkl',
      'fff', 'ddd', 'sss', 'aaa', 'kkk', 'lll', 'jjj', // 같은 알파벳 반복
    ];
    if (randomKeyPatterns.any((pattern) =>
        trimmed.toLowerCase().contains(pattern) && trimmed.length < 10)) {
      return true;
    }

    // 4. 영문자만 있고 짧은 경우 (3-5글자) - 의미 있는 영단어가 아닌 경우
    if (RegExp(r'^[a-zA-Z]{3,5}$').hasMatch(trimmed)) {
      // 의미 있는 영단어 예외 처리
      final validWords = ['yes', 'no', 'ok', 'bye', 'good', 'bad', 'help'];
      if (!validWords.contains(trimmed.toLowerCase())) {
        // 모음이 없으면 무효 (예: "fff", "ddd")
        if (!RegExp(r'[aeiouAEIOU]').hasMatch(trimmed)) {
          return true;
        }
      }
    }

    // 5. 한글 자음/모음만 있는 경우 (예: "ㅋㅋㅋ", "ㅠㅠ")
    if (RegExp(r'^[ㄱ-ㅎㅏ-ㅣ]+$').hasMatch(trimmed)) {
      return true;
    }

    // 6. 대부분이 특수문자인 경우
    final specialCharCount =
        RegExp(r'[^\wㄱ-ㅎㅏ-ㅣ가-힣\s]', unicode: true).allMatches(trimmed).length;
    if (specialCharCount > trimmed.length * 0.7) {
      return true;
    }

    // 7. 숫자만 입력한 경우 (날짜가 아닌)
    if (RegExp(r'^\d+$').hasMatch(trimmed) && trimmed.length < 5) {
      return true;
    }

    // 8. 의미 없는 문자 조합 (예: "ggg", "hhh" 등)
    // 같은 문자가 전체의 80% 이상이면 무효
    if (trimmed.length >= 3) {
      final charCounts = <String, int>{};
      for (var char in trimmed.toLowerCase().split('')) {
        charCounts[char] = (charCounts[char] ?? 0) + 1;
      }
      final maxCount = charCounts.values.reduce((a, b) => a > b ? a : b);
      if (maxCount / trimmed.length > 0.8) {
        return true;
      }
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

  String _getFallbackDetailedSummary(DiaryEntry entry) {
    final emotion = entry.emotions.isNotEmpty ? entry.emotions.first : '평온';
    return '${entry.title.isNotEmpty ? entry.title : '이 일기'}는 $emotion 감정을 담고 있습니다. ${entry.content.length > 100 ? entry.content.substring(0, 100) + '...' : entry.content}';
  }

  String _getFallbackDetailedAdvice(DiaryEntry entry) {
    final emotion = entry.emotions.isNotEmpty ? entry.emotions.first : '평온';
    switch (emotion) {
      case '기쁨':
        return '오늘 기쁜 하루를 보내셨군요. 이런 긍정적인 감정을 오래 유지하기 위해 감사한 일들을 더 기록해보세요. 주변 사람들과 기쁨을 나누는 것도 좋은 방법입니다.';
      case '슬픔':
        return '힘든 시간을 보내고 계시는군요. 자신에게 친절하게 대하고 충분한 휴식을 취하세요. 감정을 인정하고 받아들이는 것도 중요합니다. 시간이 지나면 조금씩 나아질 거예요.';
      case '분노':
        return '화가 나는 일이 있었나요? 깊은 호흡을 통해 감정을 진정시키고, 산책이나 운동으로 스트레스를 해소해보세요. 상황을 객관적으로 바라보는 것도 도움이 될 수 있습니다.';
      default:
        return '오늘 하루를 기록해주셔서 감사합니다. 일기를 통해 자신의 감정을 정리하고 돌아보는 시간을 가지는 것은 매우 소중한 일입니다. 앞으로도 꾸준히 기록하며 자신을 이해하는 시간을 가져보세요.';
    }
  }

  /// 간단한 AI 조언 생성 (일기 상세 페이지용)
  Future<String> generateSimpleAdvice(DiaryEntry entry) async {
    if (!_hasKey) {
      return _getFallbackSimpleAdvice(entry);
    }

    try {
      final primaryEmotion =
          entry.emotions.isNotEmpty ? entry.emotions.first : '평온';
      final emotionIntensity = entry.emotionIntensities[primaryEmotion] ?? 5;

      final prompt = '''
다음 일기를 바탕으로 간단하고 따뜻한 조언을 한 문장으로 제공해주세요.

**일기 정보:**
- 내용: ${entry.content.length > 200 ? entry.content.substring(0, 200) + '...' : entry.content}
- 주요 감정: $primaryEmotion

**조언 작성 규칙:**
1. **간결함**: 한 문장으로 핵심만 전달 (최대 2문장)
2. **공감적**: 작성자의 감정을 이해하고 공감하는 톤
3. **실용적**: 구체적이고 실행 가능한 작은 제안 포함
4. **긍정적이지만 현실적**: 과도한 격려보다는 따뜻하고 현실적인 조언

**금지사항:**
- 일반적인 격려 문구만 사용 금지
- 일기 내용과 무관한 조언 금지
- 과도하게 긴 문장 금지

**예시:**
- "오늘 기쁜 하루를 보내셨군요. 이런 긍정적인 감정을 오래 유지하기 위해 감사한 일들을 더 기록해보세요."
- "힘든 시간을 보내고 계시는군요. 자신에게 친절하게 대하고 충분한 휴식을 취하세요."

한국어로 한 문장으로 작성해주세요.
''';

      final response = await _callGeminiAPI(prompt);
      return response ?? _getFallbackSimpleAdvice(entry);
    } catch (e) {
      print('간단 조언 생성 실패: $e');
      return _getFallbackSimpleAdvice(entry);
    }
  }

  String _getFallbackSimpleAdvice(DiaryEntry entry) {
    final emotion = entry.emotions.isNotEmpty ? entry.emotions.first : '평온';
    switch (emotion) {
      case '기쁨':
        return '정말 기쁜 하루였네요! 이런 긍정적인 감정을 오래 유지하기 위해 감사한 일들을 더 기록해보세요.';
      case '사랑':
        return '사랑이 가득한 하루였군요. 주변 사람들에게 더 많은 관심과 사랑을 나누어보세요.';
      case '평온':
        return '차분하고 평온한 마음으로 하루를 마무리했네요. 이 평온함을 기록하고 감사해보세요.';
      case '슬픔':
        return '힘든 시간을 보내고 계시는군요. 자신에게 친절하게 대하고 충분한 휴식을 취하세요.';
      case '분노':
        return '화가 나는 일이 있었나요? 깊은 호흡을 통해 감정을 진정시키고, 산책이나 운동으로 스트레스를 해소해보세요.';
      case '걱정':
        return '불안하고 걱정되는 마음이 드시나요? 현재에 집중하는 명상이나 요가를 시도해보세요.';
      case '놀람':
        return '예상치 못한 일이 있었나요? 새로운 경험을 긍정적으로 받아들이고 성장의 기회로 삼아보세요.';
      default:
        return '오늘 하루도 수고하셨습니다. 내일은 더 좋은 하루가 될 거예요!';
    }
  }
}
