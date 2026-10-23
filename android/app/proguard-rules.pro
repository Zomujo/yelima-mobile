# Scheduled reminders are stored with Gson; keep its generic type info.
-keep class com.dexterous.** { *; }
-keepattributes Signature
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken

# Crashlytics needs line numbers to map stack traces.
-keepattributes SourceFile,LineNumberTable
