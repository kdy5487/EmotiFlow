import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/diary_remote_data_source.dart';
import '../data/repositories/diary_repository_impl.dart';
import '../domain/repositories/diary_repository.dart';
import '../domain/usecases/get_diaries_usecase.dart';
import '../domain/usecases/create_diary_usecase.dart';
import '../domain/usecases/delete_diary_usecase.dart';
import '../domain/usecases/delete_diaries_usecase.dart';

// 1. DataSource Provider
final diaryRemoteDataSourceProvider = Provider((ref) {
  return DiaryRemoteDataSource(FirebaseFirestore.instance);
});

// 2. Repository Provider
final diaryRepositoryProvider = Provider<IDiaryRepository>((ref) {
  final dataSource = ref.watch(diaryRemoteDataSourceProvider);
  return DiaryRepositoryImpl(dataSource);
});

// 3. UseCase Providers
final getDiariesUseCaseProvider = Provider((ref) {
  final repository = ref.watch(diaryRepositoryProvider);
  return GetDiariesUseCase(repository);
});

final createDiaryUseCaseProvider = Provider((ref) {
  final repository = ref.watch(diaryRepositoryProvider);
  return CreateDiaryUseCase(repository);
});

final deleteDiaryUseCaseProvider = Provider((ref) {
  final repository = ref.watch(diaryRepositoryProvider);
  return DeleteDiaryUseCase(repository);
});

final deleteDiariesUseCaseProvider = Provider((ref) {
  final repository = ref.watch(diaryRepositoryProvider);
  return DeleteDiariesUseCase(repository);
});

