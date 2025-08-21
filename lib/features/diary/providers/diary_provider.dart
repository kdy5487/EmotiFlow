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
    // 더미 데이터 로딩 제거 - 실제 DB 데이터만 사용
  }

  /// 일기 목록 새로고침
  Future<void> refreshDiaryEntries(String userId) async {
    print('=== refreshDiaryEntries 시작 ===');
    state = state.copyWith(isLoading: true);
    
    try {
      print('Firebase에서 데이터 가져오기 시도...');
      final snapshot = await _firestore
          .collection('diaries')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      final dbEntries = snapshot.docs.map((doc) => DiaryEntry.fromFirestore(doc)).toList();
      print('Firebase에서 ${dbEntries.length}개 일기 가져옴');
      
      // 날짜순 정렬 (최신순)
      dbEntries.sort((a, b) {
        final aDate = a.createdAt is DateTime ? a.createdAt : (a.createdAt as dynamic).toDate();
        final bDate = b.createdAt is DateTime ? b.createdAt : (b.createdAt as dynamic).toDate();
        return bDate.compareTo(aDate);
      });
      
      // 상태 업데이트
      state = state.copyWith(
        diaryEntries: dbEntries,
        filteredEntries: dbEntries,
        isLoading: false,
        errorMessage: null,
        isOffline: false,
      );
      
      print('총 ${dbEntries.length}개 일기 로드 완료');
      
    } catch (e) {
      print('Firebase 오류: $e');
      state = state.copyWith(
        diaryEntries: [],
        filteredEntries: [],
        isLoading: false,
        errorMessage: '데이터를 불러오는 중 오류가 발생했습니다: $e',
        isOffline: true,
      );
    }
  }

  /// 일기 생성
  Future<void> createDiaryEntry(DiaryEntry entry) async {
    try {
      final collection = _firestore.collection('diaries');
      final docRef = entry.id.isEmpty ? collection.doc() : collection.doc(entry.id);
      final data = {
        ...entry.toFirestore(),
        'id': docRef.id,
        'createdAt': Timestamp.fromDate(entry.createdAt),
      };
      await docRef.set(data);

      // 새로 생성된 일기를 목록에 추가
      final newEntry = entry.copyWith(id: docRef.id);
      final updatedEntries = [newEntry, ...state.diaryEntries];
      
      // 날짜순 정렬 (최신순)
      updatedEntries.sort((a, b) {
        final aDate = a.createdAt is DateTime ? a.createdAt : (a.createdAt as dynamic).toDate();
        final bDate = b.createdAt is DateTime ? b.createdAt : (b.createdAt as dynamic).toDate();
        return bDate.compareTo(aDate);
      });
      
      state = state.copyWith(
        diaryEntries: updatedEntries,
        filteredEntries: updatedEntries,
      );
      
      print('새 일기 생성 완료: ${newEntry.id}');
    } catch (e) {
      print('일기 생성 오류: $e');
      throw Exception('일기 생성에 실패했습니다: $e');
    }
  }

  /// 일기 수정
  Future<void> updateDiaryEntry(DiaryEntry entry) async {
    try {
      await _firestore
          .collection('diaries')
          .doc(entry.id)
          .update(entry.toFirestore());

      // 목록에서 해당 일기 업데이트
      final updatedEntries = state.diaryEntries.map((e) {
        return e.id == entry.id ? entry : e;
      }).toList();
      
      // 날짜순 정렬 (최신순)
      updatedEntries.sort((a, b) {
        final aDate = a.createdAt is DateTime ? a.createdAt : (a.createdAt as dynamic).toDate();
        final bDate = b.createdAt is DateTime ? b.createdAt : (b.createdAt as dynamic).toDate();
        return bDate.compareTo(aDate);
      });
      
      state = state.copyWith(
        diaryEntries: updatedEntries,
        filteredEntries: updatedEntries,
      );
      
      print('일기 수정 완료: ${entry.id}');
    } catch (e) {
      print('일기 수정 오류: $e');
      throw Exception('일기 수정에 실패했습니다: $e');
    }
  }

  /// 일기 삭제
  Future<void> deleteDiaryEntry(String entryId) async {
    try {
      await _firestore
          .collection('diaries')
          .doc(entryId)
          .delete();

      // 목록에서 해당 일기 제거
      final updatedEntries = state.diaryEntries.where((e) => e.id != entryId).toList();
      
      state = state.copyWith(
        diaryEntries: updatedEntries,
        filteredEntries: updatedEntries,
      );
      
      print('일기 삭제 완료: $entryId');
    } catch (e) {
      print('일기 삭제 오류: $e');
      throw Exception('일기 삭제에 실패했습니다: $e');
    }
  }

  /// 여러 일기 삭제
  Future<void> deleteDiaryEntries(List<String> entryIds) async {
    try {
      final batch = _firestore.batch();
      
      for (final entryId in entryIds) {
        final docRef = _firestore.collection('diaries').doc(entryId);
        batch.delete(docRef);
      }
      
      await batch.commit();

      // 목록에서 해당 일기들 제거
      final updatedEntries = state.diaryEntries.where((e) => !entryIds.contains(e.id)).toList();
      
      state = state.copyWith(
        diaryEntries: updatedEntries,
        filteredEntries: updatedEntries,
      );
      
      print('${entryIds.length}개 일기 삭제 완료');
    } catch (e) {
      print('일기 일괄 삭제 오류: $e');
      throw Exception('일기 삭제에 실패했습니다: $e');
    }
  }

  /// 검색 및 필터링
  void searchAndFilter({
    String? searchQuery,
    Map<String, dynamic>? filters,
    String? sortBy,
  }) {
    print('=== searchAndFilter 시작 ===');
    print('검색어: $searchQuery');
    print('필터: $filters');
    print('정렬: $sortBy');
    
    List<DiaryEntry> filteredEntries = List.from(state.diaryEntries);
    
    // 1. 검색어 필터링
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filteredEntries = filteredEntries.where((entry) {
        return entry.title.toLowerCase().contains(query) ||
               entry.content.toLowerCase().contains(query) ||
               entry.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
      print('검색어 필터링 후: ${filteredEntries.length}개');
    }
    
    // 2. 필터 적용
    if (filters != null && filters.isNotEmpty) {
      // 일기 타입 필터
      if (filters.containsKey('diaryType')) {
        final diaryType = filters['diaryType'];
        if (diaryType == 'free') {
          filteredEntries = filteredEntries.where((e) => e.diaryType == DiaryType.free).toList();
        } else if (diaryType == 'aiChat') {
          filteredEntries = filteredEntries.where((e) => e.diaryType == DiaryType.aiChat).toList();
        }
      }
      
      // 감정 필터
      if (filters.containsKey('emotion')) {
        final emotion = filters['emotion'];
        filteredEntries = filteredEntries.where((e) => e.emotions.contains(emotion)).toList();
      }
      
      // 미디어 필터
      if (filters.containsKey('hasMedia')) {
        final hasMedia = filters['hasMedia'];
        if (hasMedia == true) {
          filteredEntries = filteredEntries.where((e) => e.mediaCount > 0).toList();
        } else if (hasMedia == false) {
          filteredEntries = filteredEntries.where((e) => e.mediaCount == 0).toList();
        }
      }
      
      // AI 분석 필터
      if (filters.containsKey('hasAIAnalysis')) {
        final hasAIAnalysis = filters['hasAIAnalysis'];
        if (hasAIAnalysis == true) {
          filteredEntries = filteredEntries.where((e) => e.aiAnalysis != null).toList();
        } else if (hasAIAnalysis == false) {
          filteredEntries = filteredEntries.where((e) => e.aiAnalysis == null).toList();
        }
      }
      
      print('필터 적용 후: ${filteredEntries.length}개');
    }
    
    // 3. 정렬 적용 (기본값: 최신순)
    final sortType = sortBy ?? 'date';
    switch (sortType) {
      case 'date':
        // 최신순 (최신이 위로)
        filteredEntries.sort((a, b) {
          final aDate = a.createdAt is DateTime ? a.createdAt : (a.createdAt as dynamic).toDate();
          final bDate = b.createdAt is DateTime ? b.createdAt : (b.createdAt as dynamic).toDate();
          return bDate.compareTo(aDate); // 최신이 위로
        });
        break;
      case 'dateOldest':
        // 오래된순 (오래된 것이 위로)
        filteredEntries.sort((a, b) {
          final aDate = a.createdAt is DateTime ? a.createdAt : (a.createdAt as dynamic).toDate();
          final bDate = b.createdAt is DateTime ? b.createdAt : (b.createdAt as dynamic).toDate();
          return aDate.compareTo(bDate); // 오래된 것이 위로
        });
        break;
      case 'emotion':
        filteredEntries.sort((a, b) {
          if (a.emotions.isEmpty && b.emotions.isEmpty) return 0;
          if (a.emotions.isEmpty) return 1;
          if (b.emotions.isEmpty) return -1;
          return a.emotions.first.compareTo(b.emotions.first);
        });
        break;
      case 'moodType':
        // 감정 타입별 정렬 (긍정/부정)
        filteredEntries.sort((a, b) {
          final aMood = _getMoodType(a.emotions);
          final bMood = _getMoodType(b.emotions);
          return aMood.compareTo(bMood);
        });
        break;
    }
    
    print('정렬 후: ${filteredEntries.length}개');
    
    // 4. 상태 업데이트
    state = state.copyWith(filteredEntries: filteredEntries);
  }

  /// 감정 타입 판별 (긍정/부정)
  String _getMoodType(List<String> emotions) {
    const positiveEmotions = ['기쁨', '설렘', '감사', '희망', '평온', '안도'];
    const negativeEmotions = ['슬픔', '걱정', '분노', '불안', '실망', '스트레스'];
    
    int positiveCount = 0;
    int negativeCount = 0;
    
    for (final emotion in emotions) {
      if (positiveEmotions.contains(emotion)) {
        positiveCount++;
      } else if (negativeEmotions.contains(emotion)) {
        negativeCount++;
      }
    }
    
    if (positiveCount > negativeCount) return 'positive';
    if (negativeCount > positiveCount) return 'negative';
    return 'neutral';
  }

  /// 특정 일기 가져오기
  DiaryEntry? getDiaryEntry(String entryId) {
    try {
      return state.diaryEntries.firstWhere((entry) => entry.id == entryId);
    } catch (e) {
      return null;
    }
  }

  /// 현재 필터링된 일기 목록 가져오기
  List<DiaryEntry> get filteredEntries => state.filteredEntries;
  
  /// 전체 일기 목록 가져오기
  List<DiaryEntry> get diaryEntries => state.diaryEntries;
  
  /// 로딩 상태
  bool get isLoading => state.isLoading;
  
  /// 오류 메시지
  String? get errorMessage => state.errorMessage;
  
  /// 오프라인 상태
  bool get isOffline => state.isOffline;
}

/// DiaryProvider 인스턴스
final diaryProvider = StateNotifierProvider<DiaryProvider, DiaryState>((ref) {
  return DiaryProvider();
});