# Keep all TensorFlow Lite classes
-keep class org.tensorflow.** { *; }
-keepclassmembers class org.tensorflow.** { *; }
-dontwarn org.tensorflow.**

# Suppress warnings for TensorFlow Lite GPU Delegate
-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options
