# Add missing rules from missing_rules.txt
-keep class com.razorpay.AnalyticsEvent { *; }
-keep class com.razorpay.** { *; }
-keep class com.google.android.apps.nbu.paisa.inapp.client.** { *; }
-keep class proguard.annotation.** { *; }