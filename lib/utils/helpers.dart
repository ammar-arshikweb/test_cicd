import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:panamera_app/l10n/app_localizations.dart';
import 'package:panamera_app/main.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/values/colors.dart';

class Helper {
  static String getCurrentLanguage() {
    return ui.window.locale.languageCode;
  }

  // To get the app-localization.
  static AppLocalizations? getLocalization() {
    return AppLocalizations.of(navigatorKey.currentState!.context);
  }

  static StatusData? convertStatus({required String module, int? number, String? text}) {
    final strings = AppLocalizations.of(navigatorKey.currentState!.context)!;

    List<StatusData> statuses = switch (module) {
      Constant.amcJobs => [
        StatusData(key: 0, label: strings.not_started, color: MColors.red),
        StatusData(key: 1, label: strings.in_progress, color: MColors.blue),
        StatusData(key: 2, label: strings.completed, color: MColors.primaryGreen),
      ],
      Constant.taskManager => [
        StatusData(key: 0, label: strings.open, color: MColors.primaryGreen),
        StatusData(key: 1, label: strings.closed, color: MColors.grey),
        StatusData(key: 2, label: strings.on_hold, color: MColors.red),
        StatusData(key: 3, label: strings.in_progress, color: MColors.green),
        StatusData(key: 4, label: strings.awaiting_gate_pass, color: MColors.red),
      ],

      Constant.taskManagerPriority => [
        StatusData(key: 0, label: strings.low, color: MColors.green),
        StatusData(key: 1, label: strings.medium, color: MColors.orange),
        StatusData(key: 2, label: strings.high, color: MColors.red),
      ],
      _ => [],
    };

    if (number != null) {
      return statuses.firstWhere(
            (status) => status.key == number,
        orElse: () => const StatusData(key: -1, label: '', color: Colors.transparent),
      );
    }

    if (text != null) {
      return statuses.firstWhere(
            (status) => status.label == text,
        orElse: () => const StatusData(key: -1, label: '', color: Colors.transparent),
      );
    }

    return null;
  }
}

class StatusData {
  final int key;
  final String label;
  final Color color;

  const StatusData({required this.key, required this.label, required this.color});
}
