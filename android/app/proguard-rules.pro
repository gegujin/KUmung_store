# ===== Flutter / Embedding (안전 보존) =====
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# ===== (선택) Firebase / FCM 사용 시 보존 =====
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.messaging.FirebaseMessagingService { *; }
-keep class com.google.firebase.iid.** { *; }

# ===== (선택) Gson/Retrofit/OkHttp 등을 쓴다면 =====
-keep class com.google.gson.** { *; }
-keep class retrofit2.** { *; }
-keep class okhttp3.** { *; }
-keepattributes *Annotation*
-keep class kotlin.Metadata { *; }

# ===== (선택) WorkManager 등 백그라운드 라이브러리 사용 시 =====
-keep class androidx.work.** { *; }

# ===== (선택) 네이버/카카오 지도 SDK 등 리플렉션 쓰는 SDK가 있다면
# 해당 SDK 패키지 보존 추가 (예시는 패키지명 가정)
# -keep class com.naver.maps.** { *; }
# -keep class com.kakao.** { *; }
