import 'package:cloud_firestore/cloud_firestore.dart';

/// 사용자 프로필 모델
class UserProfile {
  final String id;
  final String email;
  final String nickname;
  final DateTime? birthDate;
  final String? profileImageUrl;
  final String? bio;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.email,
    required this.nickname,
    this.birthDate,
    this.profileImageUrl,
    this.bio,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Firestore에서 UserProfile 생성
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return UserProfile(
      id: doc.id,
      email: data['email'] ?? '',
      nickname: data['nickname'] ?? '',
      birthDate: data['birthDate'] != null 
          ? (data['birthDate'] as Timestamp).toDate() 
          : null,
      profileImageUrl: data['profileImageUrl'],
      bio: data['bio'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nickname': nickname,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// 프로필 복사본 생성
  UserProfile copyWith({
    String? id,
    String? email,
    String? nickname,
    DateTime? birthDate,
    String? profileImageUrl,
    String? bio,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      birthDate: birthDate ?? this.birthDate,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 나이 계산
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month || 
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  /// 기본 프로필 생성
  factory UserProfile.createDefault({
    required String id,
    required String email,
    String? nickname,
  }) {
    final now = DateTime.now();
    return UserProfile(
      id: id,
      email: email,
      nickname: nickname ?? '사용자',
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 빈 프로필 생성
  factory UserProfile.empty() {
    final now = DateTime.now();
    return UserProfile(
      id: '',
      email: '',
      nickname: '',
      createdAt: now,
      updatedAt: now,
    );
  }
}
