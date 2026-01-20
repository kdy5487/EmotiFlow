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
                        // 대표 캐릭터 이미지 (적응형 크기)
                        Center(
                          child: Container(
                            width: screenWidth * 0.25,
                            height: screenWidth * 0.25,
                            constraints: const BoxConstraints(
                              minWidth: 80,
                              maxWidth: 140,
                              minHeight: 80,
                              maxHeight: 140,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(26),
                                child: Image.asset(
                                  EmotionCharacterMap.getCharacterAsset(
                                      _selectedEmotion),
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.psychology,
                                        size: 60);
                                  },
                                ),
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

                        // 감정 선택 그리드 (3x4 - 3열, 4행) - 적응형
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // 3열
                            crossAxisSpacing: screenWidth * 0.03,
                            mainAxisSpacing: screenHeight * 0.015,
                            childAspectRatio: 0.85,
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
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: itemSize * 0.75,
              height: itemSize * 0.75,
              constraints: const BoxConstraints(
                minWidth: 50,
                maxWidth: 80,
                minHeight: 50,
                maxHeight: 80,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                border: Border.all(
                  color: isSelected ? AppTheme.primary : Colors.transparent,
                  width: isSelected ? 3.5 : 0,
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
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    characterAsset,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppTheme.primary.withOpacity(0.1),
                        child: Icon(
                          Icons.psychology,
                          color: AppTheme.primary,
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AppTypography.bodySmall.copyWith(
                color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: screenWidth * 0.03,
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
