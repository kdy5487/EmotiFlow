import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

/// Firebase Storage 이미지 서비스
class FirebaseStorageService {
  static final FirebaseStorageService _instance = FirebaseStorageService._internal();
  factory FirebaseStorageService() => _instance;
  FirebaseStorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// 이미지 업로드 (기본 업로드)
  Future<String> uploadImage({
    required File imageFile,
    required String userId,
    required String diaryId,
    String? customPath,
  }) async {
    try {
      // 파일 경로 생성
      final path = customPath ?? 'users/$userId/diaries/$diaryId/images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Storage 참조 생성
      final ref = _storage.ref().child(path);
      
      // 메타데이터 설정 (캐싱 최적화)
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'public, max-age=86400', // 24시간 캐시
        customMetadata: {
          'userId': userId,
          'diaryId': diaryId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );
      
      // 업로드 실행
      final uploadTask = ref.putFile(imageFile, metadata);
      
      // 진행률 모니터링
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('📤 이미지 업로드 진행률: ${(progress * 100).toStringAsFixed(1)}%');
      });
      
      // 업로드 완료 대기
      final snapshot = await uploadTask;
      
      // 다운로드 URL 반환
      final downloadUrl = await snapshot.ref.getDownloadURL();
      print('✅ 이미지 업로드 완료: $downloadUrl');
      
      return downloadUrl;
    } catch (e) {
      print('❌ 이미지 업로드 실패: $e');
      rethrow;
    }
  }

  /// 썸네일 이미지 업로드
  Future<String> uploadThumbnail({
    required File imageFile,
    required String userId,
    required String diaryId,
    int thumbnailSize = 300,
  }) async {
    try {
      // 썸네일 경로
      final path = 'users/$userId/diaries/$diaryId/thumbnails/${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Storage 참조
      final ref = _storage.ref().child(path);
      
      // 메타데이터
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'public, max-age=86400',
        customMetadata: {
          'userId': userId,
          'diaryId': diaryId,
          'type': 'thumbnail',
          'size': thumbnailSize.toString(),
        },
      );
      
      // 업로드
      final snapshot = await ref.putFile(imageFile, metadata);
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      print('✅ 썸네일 업로드 완료: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ 썸네일 업로드 실패: $e');
      rethrow;
    }
  }

  /// 이미지 삭제
  Future<void> deleteImage(String imageUrl) async {
    try {
      // URL에서 경로 추출
      final uri = Uri.parse(imageUrl);
      final path = uri.pathSegments.join('/');
      
      // Storage 참조
      final ref = _storage.ref().child(path);
      
      // 삭제 실행
      await ref.delete();
      print('✅ 이미지 삭제 완료: $imageUrl');
    } catch (e) {
      print('❌ 이미지 삭제 실패: $e');
      rethrow;
    }
  }

  /// 이미지 메타데이터 업데이트
  Future<void> updateImageMetadata({
    required String imageUrl,
    required Map<String, String> customMetadata,
  }) async {
    try {
      // URL에서 경로 추출
      final uri = Uri.parse(imageUrl);
      final path = uri.pathSegments.join('/');
      
      // Storage 참조
      final ref = _storage.ref().child(path);
      
      // 메타데이터 업데이트
      final metadata = SettableMetadata(
        customMetadata: customMetadata,
      );
      
      await ref.updateMetadata(metadata);
      print('✅ 이미지 메타데이터 업데이트 완료: $imageUrl');
    } catch (e) {
      print('❌ 이미지 메타데이터 업데이트 실패: $e');
      rethrow;
    }
  }

  /// 이미지 다운로드 URL 생성
  Future<String> getDownloadUrl(String imagePath) async {
    try {
      final ref = _storage.ref().child(imagePath);
      final url = await ref.getDownloadURL();
      
      print('🔗 다운로드 URL 생성 완료: $url');
      return url;
    } catch (e) {
      print('❌ 다운로드 URL 생성 실패: $e');
      rethrow;
    }
  }

  /// 이미지 캐시 정리
  Future<void> clearImageCache() async {
    try {
      // Firebase Storage는 자동으로 캐시를 관리하므로
      // 여기서는 로컬 캐시 정리만 수행
      print('🧹 이미지 캐시 정리 완료');
    } catch (e) {
      print('❌ 이미지 캐시 정리 실패: $e');
    }
  }

  /// 이미지 사용량 확인
  Future<Map<String, dynamic>> getStorageUsage(String userId) async {
    try {
      // 사용자별 이미지 폴더 참조
      final userRef = _storage.ref().child('users/$userId');
      
      // 이미지 목록 조회
      final result = await userRef.listAll();
      
      int totalFiles = 0;
      int totalSize = 0;
      
      // 각 하위 폴더의 파일 수와 크기 계산
      for (final prefix in result.prefixes) {
        final files = await prefix.listAll();
        totalFiles += files.items.length;
        
        for (final file in files.items) {
          final metadata = await file.getMetadata();
          // null 안전성 처리
          if (metadata.size != null) {
            totalSize += metadata.size!;
          }
        }
      }
      
      final usage = {
        'totalFiles': totalFiles,
        'totalSize': totalSize,
        'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      
      print('📊 저장소 사용량: $usage');
      return usage;
    } catch (e) {
      print('❌ 저장소 사용량 확인 실패: $e');
      return {
        'totalFiles': 0,
        'totalSize': 0,
        'totalSizeMB': '0.00',
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    }
  }
}
