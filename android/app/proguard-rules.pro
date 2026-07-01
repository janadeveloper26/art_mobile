# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep data models used by json_serializable / freezed
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.tasks.** { *; }

# Keep Razorpay
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keep class com.razorpay.** {*;}
-dontwarn com.razorpay.**
