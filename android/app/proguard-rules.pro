# Flutter Local Notifications - Keep scheduled notification classes
-keep class com.dexterous.** { *; }

# Gson (used by flutter_local_notifications internally)
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }

# Keep timezone data
-keep class org.threeten.** { *; }

# Google Play Core (Fixes R8 missing class errors in Flutter)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
