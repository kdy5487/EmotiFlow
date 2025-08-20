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
  final EmotionProfile emotionProfile;
  final PrivacySettings privacySettings;

  const UserProfile({
    required this.id,
    required this.email,
    required this.nickname,
    this.birthDate,
    this.profileImageUrl,
    this.bio,
    required this.createdAt,
    required this.updatedAt,
    required this.emotionProfile,
    required this.privacySettings,
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
      emotionProfile: EmotionProfile.fromMap(data['emotionProfile'] ?? {}),
      privacySettings: PrivacySettings.fromMap(data['privacySettings'] ?? {}),
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
      'emotionProfile': emotionProfile.toMap(),
      'privacySettings': privacySettings.toMap(),
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
    EmotionProfile? emotionProfile,
    PrivacySettings? privacySettings,
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
      emotionProfile: emotionProfile ?? this.emotionProfile,
      privacySettings: privacySettings ?? this.privacySettings,
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

  @override
  String toString() {
    return 'UserProfile(id: $id, email: $email, nickname: $nickname, age: $age)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 감정 프로필 모델
class EmotionProfile {
  final List<String> preferredEmotions;
  final Map<String, int> emotionImportance;
  final List<String> expressionPreferences;
  final Map<String, dynamic> emotionPatterns;
  final DateTime lastUpdated;

  const EmotionProfile({
    required this.preferredEmotions,
    required this.emotionImportance,
    required this.expressionPreferences,
    required this.emotionPatterns,
    required this.lastUpdated,
  });

  factory EmotionProfile.fromMap(Map<String, dynamic> map) {
    return EmotionProfile(
      preferredEmotions: List<String>.from(map['preferredEmotions'] ?? []),
      emotionImportance: Map<String, int>.from(map['emotionImportance'] ?? {}),
      expressionPreferences: List<String>.from(map['expressionPreferences'] ?? []),
      emotionPatterns: Map<String, dynamic>.from(map['emotionPatterns'] ?? {}),
      lastUpdated: map['lastUpdated'] != null 
          ? (map['lastUpdated'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'preferredEmotions': preferredEmotions,
      'emotionImportance': emotionImportance,
      'expressionPreferences': expressionPreferences,
      'emotionPatterns': emotionPatterns,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  EmotionProfile copyWith({
    List<String>? preferredEmotions,
    Map<String, int>? emotionImportance,
    List<String>? expressionPreferences,
    Map<String, dynamic>? emotionPatterns,
    DateTime? lastUpdated,
  }) {
    return EmotionProfile(
      preferredEmotions: preferredEmotions ?? this.preferredEmotions,
      emotionImportance: emotionImportance ?? this.emotionImportance,
      expressionPreferences: expressionPreferences ?? this.expressionPreferences,
      emotionPatterns: emotionPatterns ?? this.emotionPatterns,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// 개인정보 설정 모델
class PrivacySettings {
  final bool isProfilePublic;
  final bool isEmotionDataShared;
  final bool isAnalyticsShared;
  final List<String> allowedViewers;
  final DateTime lastUpdated;

  const PrivacySettings({
    required this.isProfilePublic,
    required this.isEmotionDataShared,
    required this.isAnalyticsShared,
    required this.allowedViewers,
    required this.lastUpdated,
  });

  factory PrivacySettings.fromMap(Map<String, dynamic> map) {
    return PrivacySettings(
      isProfilePublic: map['isProfilePublic'] ?? false,
      isEmotionDataShared: map['isEmotionDataShared'] ?? false,
      isAnalyticsShared: map['isAnalyticsShared'] ?? false,
      allowedViewers: List<String>.from(map['allowedViewers'] ?? []),
      lastUpdated: map['lastUpdated'] != null 
          ? (map['lastUpdated'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isProfilePublic': isProfilePublic,
      'isEmotionDataShared': isEmotionDataShared,
      'isAnalyticsShared': isAnalyticsShared,
      'allowedViewers': allowedViewers,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  PrivacySettings copyWith({
    bool? isProfilePublic,
    bool? isEmotionDataShared,
    bool? isAnalyticsShared,
    List<String>? allowedViewers,
    DateTime? lastUpdated,
  }) {
    return PrivacySettings(
      isProfilePublic: isProfilePublic ?? this.isProfilePublic,
      isEmotionDataShared: isEmotionDataShared ?? this.isEmotionDataShared,
      isAnalyticsShared: isAnalyticsShared ?? this.isAnalyticsShared,
      allowedViewers: allowedViewers ?? this.allowedViewers,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
