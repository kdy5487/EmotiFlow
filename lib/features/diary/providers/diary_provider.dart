import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/diary_entry.dart';

/// 일기 상태 관리 클래스
class DiaryState {
  final List<DiaryEntry> diaryEntries;
  final List<DiaryEntry> filteredEntries;
  final bool isLoading;
  final String? errorMessage;
  final DiaryEntry? currentEntry;
  final bool isOffline;

  const DiaryState({
    this.diaryEntries = const [],
    this.filteredEntries = const [],
    this.isLoading = false,
    this.errorMessage,
    this.currentEntry,
    this.isOffline = false,
  });

  DiaryState copyWith({
    List<DiaryEntry>? diaryEntries,
    List<DiaryEntry>? filteredEntries,
    bool? isLoading,
    String? errorMessage,
    DiaryEntry? currentEntry,
    bool? isOffline,
  }) {
    return DiaryState(
      diaryEntries: diaryEntries ?? this.diaryEntries,
      filteredEntries: filteredEntries ?? this.filteredEntries,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentEntry: currentEntry ?? this.currentEntry,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}

/// 일기 데이터 관리 Provider
class DiaryProvider extends StateNotifier<DiaryState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DiaryProvider() : super(const DiaryState()) {
    print('=== DiaryProvider 초기화 ===');
    // 즉시 더미 데이터 로드
    _loadDummyData();
  }

  /// 더미 데이터 즉시 로드
  void _loadDummyData() {
    final dummyEntries = _createDummyData('demo_user');
    state = state.copyWith(
      diaryEntries: dummyEntries,
      filteredEntries: dummyEntries,
      isLoading: false,
    );
    print('더미 데이터 ${dummyEntries.length}개 로드 완료');
  }

  /// 더미 데이터 생성
  List<DiaryEntry> _createDummyData(String userId) {
    final now = DateTime.now();
    return [
      DiaryEntry(
        id: 'dummy_1',
        title: 'AI와 함께한 하루',
        content: 'AI와 대화하며 오늘 하루를 정리했습니다. 생각보다 많은 감정들을 느꼈네요.',
        emotions: ['기쁨', '평온'],
        emotionIntensities: {'기쁨': 8, '평온': 7},
        userId: userId,
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        diaryType: DiaryType.aiChat,
      ),
      DiaryEntry(
        id: 'dummy_2',
        title: '조금 힘들었던 하루',
        content: '일이 많아서 조금 스트레스를 받았지만, 그래도 잘 버텨냈어요. 내일은 더 좋을 거예요.',
        emotions: ['걱정', '희망'],
        emotionIntensities: {'걱정': 6, '희망': 7},
        userId: userId,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        diaryType: DiaryType.free,
      ),
      DiaryEntry(
        id: 'dummy_3',
        title: '새로운 도전',
        content: '새로운 프로젝트를 시작하게 되어 설레고 기대됩니다. 열심히 해보겠어요!',
        emotions: ['설렘', '기대'],
        emotionIntensities: {'설렘': 9, '기대': 8},
        userId: userId,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
        diaryType: DiaryType.free,
      ),
      DiaryEntry(
        id: 'dummy_4',
        title: '감사한 마음',
        content: '가족과 친구들이 있어서 감사해요. 오늘도 좋은 하루였습니다.',
        emotions: ['감사', '기쁨'],
        emotionIntensities: {'감사': 9, '기쁨': 8},
        userId: userId,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
        diaryType: DiaryType.free,
      ),
      DiaryEntry(
        id: 'dummy_5',
        title: '평온한 저녁',
        content: '오늘은 특별한 일은 없었지만 마음이 평온했어요. 이런 날들도 소중해요.',
        emotions: ['평온', '안도'],
        emotionIntensities: {'평온': 8, '안도': 7},
        userId: userId,
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(days: 4)),
        diaryType: DiaryType.aiChat,
      ),
    ];
  }

  /// 일기 목록 새로고침
  Future<void> refreshDiaryEntries(String userId) async {
    print('=== refreshDiaryEntries 시작 ===');
    state = state.copyWith(isLoading: true);
    
    try {
      // 1. 먼저 더미 데이터 로드 (즉시 표시용)
      final dummyEntries = _createDummyData(userId);
      
      // 2. Firebase에서 실제 데이터 시도
      List<DiaryEntry> dbEntries = [];
      try {
        print('Firebase에서 데이터 가져오기 시도...');
        final snapshot = await _firestore
            .collection('diaries')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .get();
        
        dbEntries = snapshot.docs.map((doc) => DiaryEntry.fromFirestore(doc)).toList();
        print('Firebase에서 ${dbEntries.length}개 일기 가져옴');
      } catch (dbError) {
        print('Firebase 오류: $dbError');
        // DB 실패해도 더미 데이터는 표시
      }
      
      // 3. 병합 (DB 데이터 + 중복되지 않는 더미 데이터)
      final allEntries = <DiaryEntry>[
        ...dbEntries,
        ...dummyEntries.where((dummy) => !dbEntries.any((db) => db.id == dummy.id)),
      ];
      
      // 4. 날짜순 정렬
      allEntries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      // 5. 상태 업데이트
      state = state.copyWith(
        diaryEntries: allEntries,
        filteredEntries: allEntries,
        isLoading: false,
        errorMessage: null,
        isOffline: dbEntries.isEmpty && dummyEntries.isNotEmpty,
      );
      
      print('총 ${allEntries.length}개 일기 로드 완료');
      
    } catch (e) {
      print('예상치 못한 오류: $e');
      // 오류 발생 시에도 더미 데이터는 표시
      final dummyEntries = _createDummyData(userId);
      state = state.copyWith(
        diaryEntries: dummyEntries,
        filteredEntries: dummyEntries,
        isLoading: false,
        errorMessage: null,
        isOffline: true,
      );
    }
  }

  /// 일기 생성
  Future<void> createDiaryEntry(DiaryEntry entry) async {
    try {
      await _firestore.collection('diaries').doc(entry.id).set(entry.toFirestore());
      
      // 로컬 상태 업데이트
      final updatedEntries = [entry, ...state.diaryEntries];
      updatedEntries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      state = state.copyWith(
        diaryEntries: updatedEntries,
        filteredEntries: updatedEntries,
      );
      
      print('일기 생성 완료: ${entry.id}');
    } catch (e) {
      print('일기 생성 실패: $e');
      throw e;
    }
  }

  /// 검색 및 필터링
  void searchAndFilter({
    String? searchQuery,
    Map<String, dynamic>? filters,
    String? sortBy,
  }) {
    var filteredEntries = List<DiaryEntry>.from(state.diaryEntries);
    
    // 검색 적용
    if (searchQuery != null && searchQuery.isNotEmpty) {
      filteredEntries = filteredEntries.where((entry) =>
          entry.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          entry.content.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }
    
    // 감정 필터 적용
    if (filters != null && filters['emotions'] != null) {
      final emotionFilters = filters['emotions'] as List<String>;
      if (emotionFilters.isNotEmpty) {
        filteredEntries = filteredEntries.where((entry) =>
            entry.emotions.any((emotion) => emotionFilters.contains(emotion))).toList();
      }
    }
    
    // 정렬 적용
    if (sortBy != null) {
      switch (sortBy) {
        case 'date':
          filteredEntries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
        case 'emotion':
          filteredEntries.sort((a, b) => a.emotions.first.compareTo(b.emotions.first));
          break;
      }
    }
    
    state = state.copyWith(filteredEntries: filteredEntries);
  }

  /// 일기 삭제
  Future<void> deleteDiaryEntry(String entryId) async {
    try {
      await _firestore.collection('diaries').doc(entryId).delete();
      
      final updatedEntries = state.diaryEntries.where((entry) => entry.id != entryId).toList();
      
      state = state.copyWith(
        diaryEntries: updatedEntries,
        filteredEntries: updatedEntries,
      );
      
      print('일기 삭제 완료: $entryId');
    } catch (e) {
      print('일기 삭제 실패: $e');
      throw e;
    }
  }

  /// 일기 조회
  DiaryEntry? getDiaryEntry(String entryId) {
    return state.diaryEntries.firstWhere(
      (entry) => entry.id == entryId,
      orElse: () => throw Exception('일기를 찾을 수 없습니다: $entryId'),
    );
  }
}

/// DiaryProvider 인스턴스
final diaryProvider = StateNotifierProvider<DiaryProvider, DiaryState>((ref) {
  return DiaryProvider();
});