import 'dart:async';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:panamera_app/main.dart';

/// Global loader manager with automatic delay and minimum display time
class LoaderManager {
  static Timer? _delayTimer;
  static bool _isLoaderVisible = false;
  static DateTime? _loaderShownTime;
  static bool _hideRequested = false;

  /// Show loader with 1 second delay
  static void show() {
    // Cancel any existing timer
    _delayTimer?.cancel();
    _hideRequested = false;

    // Start new delay timer (1 second)
    _delayTimer = Timer(const Duration(seconds: 1), () {
      final context = navigatorKey.currentContext;
      if (context != null && !_isLoaderVisible) {
        context.loaderOverlay.show();
        _isLoaderVisible = true;
        _loaderShownTime = DateTime.now();

        // If hide was already requested, schedule it after minimum duration
        if (_hideRequested) {
          _scheduleHide();
        }
      }
    });
  }

  /// Hide loader (will wait for minimum 2 seconds if loader is visible)
  static void hide() {
    _hideRequested = true;

    // Cancel the delay timer if still waiting to show
    if (!_isLoaderVisible) {
      _delayTimer?.cancel();
      return;
    }

    // If loader is visible, check minimum display time
    _scheduleHide();
  }

  /// Schedule hide after ensuring minimum 2 seconds display time
  static void _scheduleHide() {
    if (_loaderShownTime == null) return;

    final elapsedTime = DateTime.now().difference(_loaderShownTime!);
    const minDisplayDuration = Duration(seconds: 2);

    if (elapsedTime >= minDisplayDuration) {
      // Minimum time has passed, hide immediately
      _hideImmediately();
    } else {
      // Wait for remaining time before hiding
      final remainingTime = minDisplayDuration - elapsedTime;
      Timer(remainingTime, () {
        // if (context.mounted) {
        _hideImmediately();
        // }
      });
    }
  }

  /// Hide the loader immediately
  static void _hideImmediately() {
    final context = navigatorKey.currentContext;

    if (context != null && _isLoaderVisible) {
      context.loaderOverlay.hide();
      _isLoaderVisible = false;
      _loaderShownTime = null;
      _hideRequested = false;
    }
  }
}

/// Extension for easier access
extension LoaderManagerExtension on BuildContext {
  void showLoader() => LoaderManager.show();
  void hideLoader() => LoaderManager.hide();
}