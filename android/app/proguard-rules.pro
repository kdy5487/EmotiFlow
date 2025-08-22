# Flutter 앱을 위한 ProGuard 규칙

# Flutter 관련 규칙
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase 관련 규칙
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Play Core 관련 규칙 (R8 오류 해결)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Flutter Play Store 관련 규칙
-keep class io.flutter.app.FlutterPlayStoreSplitApplication { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }

# Riverpod 관련 규칙
-keep class ** extends riverpod.** { *; }
-keepclassmembers class * {
    @riverpod.** *;
}

# JSON 직렬화 관련 규칙
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# 네이티브 메서드 보존
-keepclasseswithmembernames class * {
    native <methods>;
}

# 열거형 보존
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Parcelable 구현체 보존
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Serializable 구현체 보존
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# 웹뷰 관련 규칙
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# 일반적인 안전 규칙
-dontwarn android.support.**
-dontwarn androidx.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**

# 로그 제거 (릴리즈 빌드에서)
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}
