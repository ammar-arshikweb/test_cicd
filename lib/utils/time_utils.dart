import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeUtils {
  // Get current date and time in local in a specified format
  static String getCurrentDateTimeInLocal(String outputFormat) {
    final now = DateTime.now().toLocal();
    return DateFormat(outputFormat).format(now);
  }

  static String convertDateTimeTo(String? input, String outputFormat) {
    if (input != null && input.isNotEmpty) {
      DateTime dateTime = DateTime.parse(input).toLocal();
      String formattedDateTime = DateFormat(outputFormat, Platform.localeName).format(dateTime);
      return formattedDateTime.toString();
    } else {
      return '';
    }
  }

  static String formatTimeOfToAMPM(TimeOfDay time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12; // Adjust hour for 12-hour format
    final period = time.period == DayPeriod.am ? "AM" : "PM"; // Determine AM/PM

    // Format the time as a string with leading zeros if needed
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  static String formatDateTimeToOutput(DateTime input, String outputFormat) {
    try {
      DateTime localDateTime = input.toLocal();
      String formatted = DateFormat(outputFormat, Platform.localeName).format(localDateTime);
      return formatted;
    } catch (e) {
      return '';
    }
  }

  static DateTime? formatStringToDateTime(String input) {
    try {
      DateTime dateTime = DateTime.parse(input);
      return dateTime;
    } catch (e) {
      return null;
    }
  }

  static DateTime getCurrentDateTime() {
    return DateTime.now();
  }
}
