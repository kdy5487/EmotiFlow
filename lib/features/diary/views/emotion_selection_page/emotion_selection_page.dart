import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/constants/emotion_character_map.dart';
import '../../../../shared/widgets/keyboard_dismissible_scaffold.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_typography.dart';
import '../diary_chat_write_page/diary_chat_write_page.dart';

/// AI 대화 시작 전 감정 선택 페이지
class EmotionSelectionPage extends ConsumerStatefulWidget {
  const EmotionSelectionPage({super.key});

  @override
  ConsumerState<EmotionSelectionPage> createState() =>
      _EmotionSelectionPageState();
}

class _EmotionSelectionPageState extends ConsumerState<EmotionSelectionPage> {
  String? _selectedEmotion;

  void _startChat() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DiaryChatWritePage(
          initialEmotion: _selectedEmotion,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final emotions = [...EmotionCharacterMap.availableEmotions];
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return KeyboardDismissibleScaffold(
      backgroundColor: const Color(0xFFFFFDF7),
      appBar: AppBar(
        title: const Text('감정 선택'),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFFDF7),
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemSize =
                (screenWidth - (screenWidth * 0.1) - (screenWidth * 0.06)) / 3;

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 대표 캐릭터 이미지 (박스 없이 이미지만)
                        Center(
                          child: Container(
                            width: screenWidth * 0.3,
                            height: screenWidth * 0.3,
                            constraints: const BoxConstraints(
                              minWidth: 100,
                              maxWidth: 150,
                              minHeight: 100,
                              maxHeight: 150,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.asset(
                                EmotionCharacterMap.getCharacterAsset(
                                    _selectedEmotion),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child:
                                        const Icon(Icons.psychology, size: 60),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),

                        // 안내 문구 (적응형)
                        Text(
                          '오늘의 감정을 선택해주세요',
                          style: AppTypography.headlineSmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                            fontSize: screenWidth * 0.05,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '감정을 선택하면 그에 맞는 에모티가 함께 대화해요',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppTheme.textSecondary,
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // 감정 선택 그리드 (3x4 - 3열, 4행) - 고정 간격
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // 3열
                            crossAxisSpacing: 12, // 가로 간격
                            mainAxisSpacing: 10, // 세로 간격 줄임
                            childAspectRatio: 0.95, // 높이를 줄여서 더 컴팩트하게
                          ),
                          itemCount: emotions.length + 1, // +1 for "선택 안함"
                          itemBuilder: (context, index) {
                            // 마지막 아이템은 "선택 안함" 옵션
                            if (index == emotions.length) {
                              final isSelected = _selectedEmotion == null;
                              return _buildEmotionItem(
                                itemSize: itemSize,
                                screenWidth: screenWidth,
                                isSelected: isSelected,
                                emotionName: '선택 안함',
                                characterAsset:
                                    EmotionCharacterMap.defaultCharacter,
                                onTap: () {
                                  setState(() {
                                    _selectedEmotion = null;
                                  });
                                },
                              );
                            }

                            final emotion = emotions[index];
                            final isSelected = _selectedEmotion == emotion;
                            final characterAsset =
                                EmotionCharacterMap.getCharacterAsset(emotion);

                            return _buildEmotionItem(
                              itemSize: itemSize,
                              screenWidth: screenWidth,
                              isSelected: isSelected,
                              emotionName: emotion,
                              characterAsset: characterAsset,
                              onTap: () {
                                setState(() {
                                  _selectedEmotion = emotion;
                                });
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // 시작하기 버튼
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _startChat,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                _selectedEmotion != null
                                    ? '$_selectedEmotion 에모티와 대화 시작'
                                    : '에모티와 대화 시작',
                                style: AppTypography.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.04,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 감정 아이템 위젯 빌더
  Widget _buildEmotionItem({
    required double itemSize,
    required double screenWidth,
    required bool isSelected,
    required String emotionName,
    required String characterAsset,
    required VoidCallback onTap,
  }) {
    // 모든 이미지를 동일한 크기로 (제일 큰 이미지 기준)
    const double fixedSize = 75.0;
    const double borderRadius = 20.0;
    const double borderWidth = 3.5;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 이미지와 바깥 사각형을 동일한 크기로
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: fixedSize,
            height: fixedSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              color: Colors.transparent, // 배경 투명
              border: Border.all(
                color: isSelected ? AppTheme.primary : Colors.transparent,
                width: isSelected ? borderWidth : 0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            // 패딩 없이 이미지가 박스를 채우되, border width만큼 안쪽으로
            child: Padding(
              padding: EdgeInsets.all(isSelected ? borderWidth : 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  isSelected ? borderRadius - borderWidth : borderRadius,
                ),
                child: Image.asset(
                  characterAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppTheme.primary.withOpacity(0.1),
                      child: Icon(
                        Icons.psychology,
                        color: AppTheme.primary,
                        size: 36,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: fixedSize,
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AppTypography.bodySmall.copyWith(
                color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 11,
              ),
              child: Text(
                emotionName,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
