# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# RevenueCat
-keep class com.revenuecat.** { *; }

# Home Widget
-keep class es.antonborri.home_widget.** { *; }

# Keep annotations
-keepattributes *Annotation*

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}
