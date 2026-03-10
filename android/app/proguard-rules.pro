# Add project-specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified in the Android SDK.

# Flutter-specific rules
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.app.** { *; }

# Preserve just_audio classes
-keep class com.ryanheise.just_audio.** { *; }
-dontwarn com.ryanheise.just_audio.**

# Preserve audio service classes (used by just_audio for background playback, if applicable)
-keep class com.ryanheise.audioservice.** { *; }
-dontwarn com.ryanheise.audioservice.**

# Preserve ExoPlayer (Media3) classes
-keep class androidx.media3.** { *; }
-dontwarn androidx.media3.**
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**

# Preserve flutter_sound classes
-keep class com.dooboolab.fluttersound.** { *; }
-dontwarn com.dooboolab.fluttersound.**

# Prevent R8 from removing Flutter JNI classes
-keep class io.flutter.embedding.engine.plugins.** { *; }
-keep class io.flutter.plugin.common.** { *; }

# Preserve annotations for reflection
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes SourceFile,LineNumberTable

# Prevent obfuscation of classes extending Flutter plugins
-keep class * extends io.flutter.plugin.common.PluginRegistry { *; }

# Prevent removal of classes used by reflection in native code
-keep class * implements io.flutter.embedding.engine.plugins.FlutterPlugin { *; }

# Preserve Parcelable classes (if used in your app)
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator CREATOR;
}

# Prevent warnings for Android-specific classes
-dontwarn android.**

# Preserve classes for serialization/deserialization (if using JSON or other serialization)
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**
-keep class * implements java.io.Serializable { *; }

# Optimize and shrink resources cautiously
-dontoptimize
-dontshrink

# Suppress warnings for missing classes
-ignorewarnings