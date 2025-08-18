import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/diary_entry.dart';
import '../models/emotion.dart';

/// 일기 데이터의 상태를 관리하는 클래스
class DiaryState {
  final List<DiaryEntry> diaryEntries;
  final bool isLoading;
  final String? errorMessage;
  final DiaryEntry? currentEntry;

  const DiaryState({
    this.diaryEntries = const [],
    this.isLoading = false,
    this.errorMessage,
    this.currentEntry,
  });

  DiaryState copyWith({
    List<DiaryEntry>? diaryEntries,
    bool? isLoading,
    String? errorMessage,
    DiaryEntry? currentEntry,
  }) {
    return DiaryState(
      diaryEntries: diaryEntries ?? this.diaryEntries,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      currentEntry: currentEntry ?? this.currentEntry,
    );
  }
}

/// 일기 데이터를 관리하는 프로바이더
class DiaryProvider extends StateNotifier<DiaryState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  DiaryProvider() : super(const DiaryState());

  // Getters
  List<DiaryEntry> get diaryEntries => state.diaryEntries;
  bool get isLoading => state.isLoading;
  String? get errorMessage => state.errorMessage;
  DiaryEntry? get currentEntry => state.currentEntry;

  /// 사용자의 일기 목록을 가져오기
  Future<void> fetchDiaryEntries(String userId) async {
    _setLoading(true);
    _clearError();
    
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('diaries')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final diaryEntries = snapshot.docs
          .map((doc) => DiaryEntry.fromFirestore(doc))
          .toList();
          
      state = state.copyWith(diaryEntries: diaryEntries);
    } catch (e) {
      _setError('일기 목록을 가져오는데 실패했습니다: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 새로운 일기 작성
  Future<bool> createDiaryEntry(DiaryEntry entry) async {
    _setLoading(true);
    _clearError();
    
    try {
      final DocumentReference docRef = await _firestore
          .collection('diaries')
          .add(entry.toFirestore());
      
      // 생성된 ID로 업데이트된 엔트리 생성
      final newEntry = entry.copyWith(id: docRef.id);
      final newEntries = List<DiaryEntry>.from(state.diaryEntries)..insert(0, newEntry);
      state = state.copyWith(diaryEntries: newEntries);
      
      return true;
    } catch (e) {
      _setError('일기 작성에 실패했습니다: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 일기 수정
  Future<bool> updateDiaryEntry(DiaryEntry entry) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _firestore
          .collection('diaries')
          .doc(entry.id)
          .update(entry.toFirestore());
      
      // 로컬 목록에서 해당 엔트리 찾아 업데이트
      final index = state.diaryEntries.indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        final newEntries = List<DiaryEntry>.from(state.diaryEntries);
        newEntries[index] = entry;
        state = state.copyWith(diaryEntries: newEntries);
      }
      
      return true;
    } catch (e) {
      _setError('일기 수정에 실패했습니다: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 일기 삭제
  Future<bool> deleteDiaryEntry(String entryId) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _firestore
          .collection('diaries')
          .doc(entryId)
          .delete();
      
      // 로컬 목록에서 해당 엔트리 제거
      final newEntries = List<DiaryEntry>.from(state.diaryEntries)
        ..removeWhere((e) => e.id == entryId);
      state = state.copyWith(diaryEntries: newEntries);
      
      return true;
    } catch (e) {
      _setError('일기 삭제에 실패했습니다: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 특정 일기 가져오기
  Future<DiaryEntry?> getDiaryEntry(String entryId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection('diaries')
          .doc(entryId)
          .get();
      
      if (doc.exists) {
        return DiaryEntry.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      _setError('일기를 가져오는데 실패했습니다: $e');
      return null;
    }
  }

  /// 감정별 일기 필터링
  List<DiaryEntry> getDiaryEntriesByEmotion(String emotion) {
    return state.diaryEntries.where((entry) => 
      entry.emotions.contains(emotion)
    ).toList();
  }

  /// 날짜별 일기 필터링
  List<DiaryEntry> getDiaryEntriesByDate(DateTime date) {
    return state.diaryEntries.where((entry) {
      final entryDate = DateTime(
        entry.createdAt.year,
        entry.createdAt.month,
        entry.createdAt.day,
      );
      final targetDate = DateTime(date.year, date.month, date.day);
      return entryDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  /// 현재 편집 중인 일기 설정
  void setCurrentEntry(DiaryEntry? entry) {
    state = state.copyWith(currentEntry: entry);
  }

  /// 로딩 상태 설정
  void _setLoading(bool value) {
    state = state.copyWith(isLoading: value);
  }

  /// 에러 메시지 설정
  void _setError(String message) {
    state = state.copyWith(errorMessage: message);
  }

  /// 에러 메시지 초기화
  void _clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// 에러 메시지 수동 초기화 (UI에서 호출)
  void clearError() {
    _clearError();
  }
}

/// DiaryProvider를 위한 Riverpod provider
final diaryProvider = StateNotifierProvider<DiaryProvider, DiaryState>((ref) {
  return DiaryProvider();
});
