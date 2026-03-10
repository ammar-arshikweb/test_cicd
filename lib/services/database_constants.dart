// ignore_for_file: constant_identifier_names

import 'package:panamera_app/utils/constant.dart';

class DbConstants {
  static const String DATA_BASE = 'panamera.db';
  static const int DB_VERSION = 3;

  // Table names
  static const String CLOCK_IN = 'ClockIn';
  static const String CLOCK_OUT = 'ClockOut';
  static const String BREAK_IN = 'BreakIn';
  static const String BREAK_OUT = 'BreakOut';
  static const String OVERTIME = 'Overtime';
  static const String EARLY_REASON = 'EarlyReason';
  static const String EMERGENCY_CLOCK_IN = 'EmergencyClockIn';
  static const String EMERGENCY_CLOCK_OUT = 'EmergencyClockOut';
  static const String EMERGENCY_MEDIA = 'EmergencyMedia';

  // Table creation queries
  static const String CREATE_CLOCK_IN_TABLE_QRY = '''CREATE TABLE IF NOT EXISTS $CLOCK_IN(
            ${Constant.id} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${Constant.dateTime} TEXT,
            ${Constant.checkInDeviceId} TEXT,
            ${Constant.latitude} FLOAT,
            ${Constant.longitude} FLOAT,
            ${Constant.isSynced} INTEGER
          )''';

  static const String CREATE_CLOCK_OUT_TABLE_QRY = '''CREATE TABLE IF NOT EXISTS $CLOCK_OUT(
             ${Constant.id} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${Constant.dateTime} TEXT,
            ${Constant.checkOutDeviceId} TEXT,
            ${Constant.latitude} FLOAT,
            ${Constant.longitude} FLOAT,
            ${Constant.isSynced} INTEGER
          )''';

  static const String CREATE_BREAK_IN_TABLE_QRY = '''CREATE TABLE IF NOT EXISTS $BREAK_IN(
             ${Constant.id} INTEGER PRIMARY KEY AUTOINCREMENT,
             ${Constant.dateTime} TEXT,
             ${Constant.isSynced} INTEGER
          )''';

  static const String CREATE_BREAK_OUT_TABLE_QRY = '''CREATE TABLE IF NOT EXISTS $BREAK_OUT(
             ${Constant.id} INTEGER PRIMARY KEY AUTOINCREMENT,
             ${Constant.dateTime} TEXT,
             ${Constant.isSynced} INTEGER
          )''';

  static const String CREATE_OVERTIME_TABLE_QRY = '''CREATE TABLE IF NOT EXISTS $OVERTIME (
            ${Constant.id} INTEGER PRIMARY KEY AUTOINCREMENT,
             ${Constant.clockOutId} INTEGER,
            ${Constant.reasonText} TEXT,
            ${Constant.photoFiles} TEXT, -- Store as comma-separated paths
            ${Constant.voiceFiles} TEXT, -- Store as comma-separated paths
            ${Constant.isSynced} INTEGER
            )''';

  static const String CREATE_EMERGENCY_MEDIA_TABLE_QRY = '''CREATE TABLE IF NOT EXISTS $EMERGENCY_MEDIA (
            ${Constant.id} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${Constant.clockOutId} INTEGER,
            ${Constant.reasonText} TEXT,
            ${Constant.photoFiles} TEXT, -- Store as comma-separated paths
            ${Constant.voiceFiles} TEXT, -- Store as comma-separated paths
            ${Constant.isSynced} INTEGER
            )''';

  static const String CREATE_EARLY_REASON_TABLE_QRY = '''CREATE TABLE IF NOT EXISTS $EARLY_REASON (
            ${Constant.id} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${Constant.clockOutId} INTEGER,
            ${Constant.earlyReason} TEXT,
            ${Constant.isSynced} INTEGER
            )''';

  static const String CREATE_EMERGENCY_CLOCK_IN_TABLE_QRY = '''CREATE TABLE IF NOT EXISTS $EMERGENCY_CLOCK_IN(
            ${Constant.id} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${Constant.dateTime} TEXT,
            ${Constant.checkInDeviceId} TEXT,
            ${Constant.latitude} FLOAT,
            ${Constant.longitude} FLOAT,
            ${Constant.isSynced} INTEGER
          )''';

  static const String CREATE_EMERGENCY_CLOCK_OUT_TABLE_QRY = '''CREATE TABLE IF NOT EXISTS $EMERGENCY_CLOCK_OUT(
             ${Constant.id} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${Constant.dateTime} TEXT,
            ${Constant.checkOutDeviceId} TEXT,
            ${Constant.latitude} FLOAT,
            ${Constant.longitude} FLOAT,
            ${Constant.isSynced} INTEGER
          )''';
}
