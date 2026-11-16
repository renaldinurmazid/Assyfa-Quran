# Flutter Local Notifications - Keep scheduled notification classes
-keep class com.dexterous.** { *; }

# Pastikan BroadcastReceiver tidak di-strip R8 (penting untuk scheduled notifications)
-keep public class com.dexterous.flutterlocalnotifications.** extends android.content.BroadcastReceiver
-keepclassmembers class com.dexterous.flutterlocalnotifications.** {
    public <init>(...);
}

# Gson (used by flutter_local_notifications internally to serialize notification data)
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
# Prevent Gson TypeToken generic type erasure (penting agar deserialization jadwal notifikasi tidak gagal)
-keepattributes EnclosingMethod
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keepclassmembers,allowobfuscation class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }

# Keep timezone data (dipakai flutter_timezone & timezone package)
-keep class org.threeten.** { *; }
-keep class net.time4j.** { *; }

# Google Play Core (Fixes R8 missing class errors in Flutter)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
