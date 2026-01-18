import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:emoti_flow/features/diary/domain/entities/diary_entry.dart';
import 'package:emoti_flow/features/diary/providers/diary_provider.dart';
import 'package:emoti_flow/core/ai/gemini/gemini_service.dart';
import 'package:emoti_flow/shared/widgets/cards/emoti_card.dart';
import 'package:emoti_flow/theme/app_theme.dart';
import 'package:emoti_flow/theme/app_typography.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdviceCardSelectionPage extends ConsumerStatefulWidget {
  const AdviceCardSelectionPage({super.key});

  @override
  ConsumerState<AdviceCardSelectionPage> createState() =>
      _AdviceCardSelectionPageState();
}

class _AdviceCardSelectionPageState
    extends ConsumerState<AdviceCardSelectionPage> {
  Map<String, dynamic>? _selectedCard;
  String? _selectedAdvice;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _adviceCards = [
    {
      'id': 'nature',
      'title': '자연과 힐링',
      'icon': Icons.nature,
      'color': Colors.green,
      'category': 'nature',
      'description': '자연을 통한 마음의 평화와 휴식',
    },
    {
      'id': 'gratitude',
      'title': '감사와 성찰',
      'icon': Icons.favorite,
      'color': Colors.red,
      'category': 'gratitude',
      'description': '감사한 일들을 생각하고 마음을 정리',
    },
    {
      'id': 'growth',
      'title': '새로운 시작',
      'icon': Icons.trending_up,
      'color': Colors.blue,
      'category': 'growth',
      'description': '새로운 경험과 도전을 통한 성장',
    },
    {
      'id': 'relationship',
      'title': '관계와 소통',
      'icon': Icons.people,
      'color': Colors.purple,
      'category': 'relationship',
      'description': '주변 사람들과의 연결과 대화',
    },
    {
      'id': 'selfcare',
      'title': '자기 돌봄',
      'icon': Icons.spa,
      'color': Colors.orange,
      'category': 'selfcare',
      'description': '자신을 위한 특별한 시간과 활동',
    },
    {
      'id': 'creativity',
      'title': '창의적 활동',
      'icon': Icons.brush,
      'color': Colors.teal,
      'category': 'creativity',
      'description': '예술적 표현과 창의적 사고',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadTodayCard();
  }

  /// 오늘 선택된 카드 불러오기
  Future<void> _loadTodayCard() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastSelectedDate = prefs.getString('last_advice_card_date');

    if (lastSelectedDate == today) {
      final selectedCardId = prefs.getString('selected_advice_card_id');
      final selectedAdvice = prefs.getString('selected_advice_text');

      if (selectedCardId != null && selectedAdvice != null) {
        final card = _adviceCards.firstWhere(
          (card) => card['id'] == selectedCardId,
          orElse: () => _adviceCards.first,
        );
        setState(() {
          _selectedCard = card;
          _selectedAdvice = selectedAdvice;
        });
      }
    }
  }

  /// 카드 선택 및 AI 조언 생성
  Future<void> _selectCard(Map<String, dynamic> card) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final diaryState = ref.read(diaryProvider);
      final entries = diaryState.diaryEntries;
      final dominantEmotion = _getDominantEmotion(entries.take(5).toList());

      // AI 조언 생성
      final prompt = '''
사용자의 현재 감정 상태를 분석하여 간단하고 실용적인 오늘의 조언을 제공해주세요.

현재 주요 감정: $dominantEmotion
조언 카테고리: ${_getCategoryDescription(card['category'])}

다음 형식으로 간단하게 응답해주세요:
"오늘은 [감정 상태]군요. [구체적인 행동 제안] 어떨까요?"

예시:
- "오늘은 힘든 감정이군요. 빨리 자는 것 어떨까요?"
- "오늘은 기쁜 마음이군요. 좋아하는 음악을 들어보는 것 어떨까요?"
- "오늘은 평온한 마음이군요. 산책을 가보는 것 어떨까요?"

조언만 작성해주세요.
''';

      final geminiService = GeminiService.instance;
      final aiResponse =
          await geminiService.analyzeEmotionAndComfort(prompt, dominantEmotion);

      final advice = aiResponse.isNotEmpty
          ? aiResponse
          : _getFallbackAdvice(card['category'], dominantEmotion);

      // 선택된 카드와 조언 저장
      await _saveSelectedCard(card, advice);

      setState(() {
        _selectedCard = card;
        _selectedAdvice = advice;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${card['title']} 카드가 선택되었습니다!'),
          backgroundColor: card['color'],
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('조언 생성에 실패했습니다. 다시 시도해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 선택된 카드 저장
  Future<void> _saveSelectedCard(
      Map<String, dynamic> card, String advice) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];

    await prefs.setString('last_advice_card_date', today);
    await prefs.setString('selected_advice_card_id', card['id']);
    await prefs.setString('selected_advice_text', advice);
  }

  /// 카드 재선택 (하루 초기화)
  Future<void> _resetCard() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_advice_card_date');
    await prefs.remove('selected_advice_card_id');
    await prefs.remove('selected_advice_text');

    setState(() {
      _selectedCard = null;
      _selectedAdvice = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('카드가 초기화되었습니다. 새로운 카드를 선택해주세요!'),
        backgroundColor: AppTheme.info,
      ),
    );
  }

  /// 지배적인 감정 찾기
  String _getDominantEmotion(List<DiaryEntry> entries) {
    if (entries.isEmpty) return '평온';

    final emotionCounts = <String, int>{};
    for (final entry in entries) {
      for (final emotion in entry.emotions) {
        emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + 1;
      }
    }

    if (emotionCounts.isEmpty) return '평온';

    final dominant =
        emotionCounts.entries.reduce((a, b) => a.value > b.value ? a : b);

    return dominant.key;
  }

  /// 카드 카테고리 설명 가져오기
  String _getCategoryDescription(String category) {
    switch (category) {
      case 'nature':
        return '자연과 힐링 - 자연을 통한 마음의 평화와 휴식';
      case 'gratitude':
        return '감사와 성찰 - 감사한 일들을 생각하고 마음을 정리';
      case 'growth':
        return '새로운 시작 - 새로운 경험과 도전을 통한 성장';
      case 'relationship':
        return '관계와 소통 - 주변 사람들과의 연결과 대화';
      case 'selfcare':
        return '자기 돌봄 - 자신을 위한 특별한 시간과 활동';
      case 'creativity':
        return '창의적 활동 - 예술적 표현과 창의적 사고';
      default:
        return '일반적인 조언';
    }
  }

  /// 대체 조언 제공
  String _getFallbackAdvice(String category, String emotion) {
    String baseAdvice = '';
    switch (emotion) {
      case '슬픔':
        baseAdvice = '오늘은 슬픈 감정이군요.';
        break;
      case '분노':
        baseAdvice = '오늘은 화가 나는 감정이군요.';
        break;
      case '기쁨':
        baseAdvice = '오늘은 기쁜 마음이군요.';
        break;
      case '사랑':
        baseAdvice = '오늘은 사랑스러운 마음이군요.';
        break;
      case '평온':
        baseAdvice = '오늘은 평온한 마음이군요.';
        break;
      case '두려움':
        baseAdvice = '오늘은 불안한 감정이군요.';
        break;
      case '놀람':
        baseAdvice = '오늘은 놀라운 일이 있었군요.';
        break;
      default:
        baseAdvice = '오늘은 다양한 감정을 경험하고 계시군요.';
    }

    String suggestion = '';
    switch (category) {
      case 'nature':
        suggestion = '자연 속에서 시간을 보내는 것 어떨까요?';
        break;
      case 'gratitude':
        suggestion = '감사한 일들을 생각해보는 것 어떨까요?';
        break;
      case 'growth':
        suggestion = '새로운 것에 도전해보는 것 어떨까요?';
        break;
      case 'relationship':
        suggestion = '주변 사람들과 대화해보는 것 어떨까요?';
        break;
      case 'selfcare':
        suggestion = '자신을 위한 특별한 시간을 가져보는 것 어떨까요?';
        break;
      case 'creativity':
        suggestion = '창의적인 활동을 해보는 것 어떨까요?';
        break;
      default:
        suggestion = '마음에 드는 활동을 해보는 것 어떨까요?';
    }

    return '$baseAdvice $suggestion';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘의 조언 카드'),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        actions: [
          if (_selectedCard != null)
            IconButton(
              onPressed: _resetCard,
              icon: const Icon(Icons.refresh),
              tooltip: '카드 재선택',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 오늘 선택된 카드 표시
            if (_selectedCard != null && _selectedAdvice != null) ...[
              EmotiCard(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _selectedCard!['icon'],
                            color: _selectedCard!['color'],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '오늘의 조언 카드',
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _selectedCard!['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedCard!['color'].withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _selectedCard!['icon'],
                                  color: _selectedCard!['color'],
                                  size: 32,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _selectedCard!['title'],
                                    style: AppTypography.titleSmall.copyWith(
                                      color: _selectedCard!['color'],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _selectedAdvice!,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppTheme.textPrimary,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '💡 이 카드는 오늘 하루 동안 유효합니다. 내일이 되면 새로운 카드를 선택할 수 있어요!',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // 카드 선택 안내
            Text(
              _selectedCard != null
                  ? '다른 카드로 변경하고 싶다면 아래에서 선택하세요'
                  : '오늘의 조언을 받을 카드를 선택해주세요',
              style: AppTypography.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            // 카드 그리드 - 완벽한 중앙 정렬
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 350),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: _adviceCards.length,
                  itemBuilder: (context, index) {
                    final card = _adviceCards[index];
                    final isSelected = _selectedCard?['id'] == card['id'];

                    return GestureDetector(
                      onTap: _isLoading ? null : () => _selectCard(card),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? card['color'].withOpacity(0.2)
                              : card['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? card['color']
                                : card['color'].withOpacity(0.3),
                            width: isSelected ? 3 : 2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: card['color'].withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    card['icon'],
                                    size: 36,
                                    color: card['color'],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    card['title'],
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: card['color'],
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    card['description'],
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppTheme.textSecondary,
                                      fontSize: 10,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: card['color'],
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 로딩 인디케이터
            if (_isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('AI가 맞춤형 조언을 생성하고 있어요...'),
                  ],
                ),
              ),

            // 카드 선택 완료 후 확인 버튼
            if (_selectedCard != null && _selectedAdvice != null) ...[
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('선택 완료'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedCard!['color'],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    textStyle: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
