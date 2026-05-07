# Variance ProGuard rules
# Keep Flutter and Dart essentials (Flutter plugin handles the rest)

# flutter_secure_storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# WorkManager
-keep class androidx.work.** { *; }
-keep class * extends androidx.work.Worker
-keep class * extends androidx.work.ListenableWorker {
    public <init>(android.content.Context,androidx.work.WorkerParameters);
}

# local_auth — biometric
-keep class androidx.biometric.** { *; }

# flutter_local_notifications
-keep class com.dexterous.** { *; }

# Keep Kotlin coroutines
-keepclassmembernames class kotlinx.** {
    volatile <fields>;
}
