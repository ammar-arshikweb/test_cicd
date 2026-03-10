import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:panamera_app/features/employee/attendance/model/break_in_model/break_in_req.dart';
import 'package:panamera_app/features/employee/attendance/model/break_out_model/break_out_req.dart';
import 'package:panamera_app/features/employee/attendance/model/clock_in_model/clock_in_req.dart';
import 'package:panamera_app/features/employee/attendance/model/clock_out_model/clock_out_req.dart';
import 'package:panamera_app/features/employee/attendance/model/early_leave_model/early_leave_req.dart';
import 'package:panamera_app/features/employee/attendance/repository/attendance_repo.dart';
import 'package:panamera_app/services/database_constants.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/log_utils.dart';
import 'package:panamera_app/utils/time_utils.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static late Database _database;

  static Future<void> initialize() async {
    _database = await _initDatabase();
  }

  static Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();

    final path = join(databasePath, DbConstants.DATA_BASE);

    return await openDatabase(
      path,
      onCreate: _onCreate,
      version: DbConstants.DB_VERSION,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
      onUpgrade: (db, oldVersion, newVersion) async {
        Log.i('Database upgraded from version $oldVersion to $newVersion');
        if (oldVersion < newVersion) {
          try {
            await db.execute(DbConstants.CREATE_EMERGENCY_CLOCK_IN_TABLE_QRY);
            await db.execute(DbConstants.CREATE_EMERGENCY_CLOCK_OUT_TABLE_QRY);
            await db.execute(DbConstants.CREATE_EMERGENCY_MEDIA_TABLE_QRY);
            Log.i('Emergency tables created successfully during upgrade');
          } catch (e) {
            Log.e('Error creating emergency tables during upgrade: $e');
          }
        }
      },
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Run the CREATE {projects} TABLE statement on the database.
    try {
      await db.execute(DbConstants.CREATE_CLOCK_IN_TABLE_QRY);
      await db.execute(DbConstants.CREATE_CLOCK_OUT_TABLE_QRY);
      await db.execute(DbConstants.CREATE_BREAK_IN_TABLE_QRY);
      await db.execute(DbConstants.CREATE_BREAK_OUT_TABLE_QRY);
      await db.execute(DbConstants.CREATE_OVERTIME_TABLE_QRY);
      await db.execute(DbConstants.CREATE_EARLY_REASON_TABLE_QRY);
      await db.execute(DbConstants.CREATE_EMERGENCY_CLOCK_IN_TABLE_QRY);
      await db.execute(DbConstants.CREATE_EMERGENCY_CLOCK_OUT_TABLE_QRY);
      await db.execute(DbConstants.CREATE_EMERGENCY_MEDIA_TABLE_QRY);
    } catch (e) {
      Log.e('Error creating table : $e');
    }
  }

  static Future<void> addClockIn(ClockInReq clockInReq, bool isSynced) async {
    final data = clockInReq.toMap();
    data[Constant.isSynced] = isSynced ? 1 : 0; // Added isSynced field to the data map
    await _database.insert(DbConstants.CLOCK_IN, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> addClockOut(ClockOutReq clockOutReq, bool isSynced) async {
    final data = clockOutReq.toMap();
    data[Constant.isSynced] = isSynced ? 1 : 0; // Added isSynced field to the data map
    return await _database.insert(DbConstants.CLOCK_OUT, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> addEmergencyClockIn(ClockInReq clockInReq, bool isSynced) async {
    final data = clockInReq.toMap();
    data[Constant.isSynced] = isSynced ? 1 : 0; // Added isSynced field to the data map
    await _database.insert(DbConstants.EMERGENCY_CLOCK_IN, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> addEmergencyClockOut(ClockOutReq clockOutReq, bool isSynced) async {
    final data = clockOutReq.toMap();
    data[Constant.isSynced] = isSynced ? 1 : 0; // Added isSynced field to the data map
    return await _database.insert(DbConstants.EMERGENCY_CLOCK_OUT, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> addBreakIn(BreakInReq breakIn, bool isSynced) async {
    final data = breakIn.toMap();
    data[Constant.isSynced] = isSynced ? 1 : 0; // Added isSynced field to the data map
    await _database.insert(DbConstants.BREAK_IN, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> addBreakOut(BreakOutReq breakOutReq, bool isSynced) async {
    final data = breakOutReq.toMap();
    data[Constant.isSynced] = isSynced ? 1 : 0; // Added isSynced field to the data map
    await _database.insert(DbConstants.BREAK_OUT, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> addOvertimeData({
    required int clockOutId,
    required String reasonText,
    required List<String> photoFiles,
    required List<String> voiceFiles,
  }) async {
    try {
      final data = {
        Constant.clockOutId: clockOutId,
        Constant.reasonText: reasonText,
        Constant.photoFiles: photoFiles.join(','),
        // Store paths as comma-separated string
        Constant.voiceFiles: voiceFiles.join(','),
        // Store paths as comma-separated string
        Constant.isSynced: 0,
      };

      await _database.insert(DbConstants.OVERTIME, data, conflictAlgorithm: ConflictAlgorithm.replace);
      Log.i('Overtime data added to local database');
    } catch (e) {
      Log.e('Error adding overtime data: $e');
    }
  }

  static Future<void> addEmergencyMediaData({
    required int clockOutId,
    required String reasonText,
    required List<String> photoFiles,
    required List<String> voiceFiles,
  }) async {
    try {
      final data = {
        Constant.clockOutId: clockOutId,
        Constant.reasonText: reasonText,
        Constant.photoFiles: photoFiles.join(','),
        // Store paths as comma-separated string
        Constant.voiceFiles: voiceFiles.join(','),
        // Store paths as comma-separated string
        Constant.isSynced: 0,
      };

      final existing = await _database.query(DbConstants.EMERGENCY_MEDIA, where: '${Constant.clockOutId} = ?', whereArgs: [clockOutId], limit: 1);

      if (existing.isNotEmpty) {
        await _database.update(DbConstants.EMERGENCY_MEDIA, data, where: '${Constant.clockOutId} = ?', whereArgs: [clockOutId]);
        Log.i('Emergency media data updated for clockOutId: $clockOutId');
      } else {
        await _database.insert(DbConstants.EMERGENCY_MEDIA, data, conflictAlgorithm: ConflictAlgorithm.replace);
        Log.i('Emergency media data added to local database');
      }
    } catch (e) {
      Log.e('Error adding Emergency media data: $e');
    }
  }

  static Future<void> addEarlyReason({required int clockOutId, required String earlyReason}) async {
    final data = {
      Constant.clockOutId: clockOutId, Constant.earlyReason: earlyReason, Constant.isSynced: 0, // Added isSynced field to the data map
    };
    await _database.insert(DbConstants.EARLY_REASON, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<Map<String, dynamic>> getTodayClockInOutTimes() async {
    final todayDate = DateFormat(Constant.yyyy_MM_dd).format(TimeUtils.getCurrentDateTime());

    // Clock In
    final List<Map<String, dynamic>> clockInMaps = await _database.query(
      DbConstants.CLOCK_IN,
      where: "${Constant.dateTime} LIKE ?",
      whereArgs: ['%$todayDate%'],
      orderBy: Constant.dateTime + " ASC",
      limit: 1,
    );
    DateTime? clockInTime;
    if (clockInMaps.isNotEmpty) {
      clockInTime = DateTime.tryParse(clockInMaps.first[Constant.dateTime]);
    }

    // Clock Out
    final List<Map<String, dynamic>> clockOutMaps = await _database.query(
      DbConstants.CLOCK_OUT,
      where: "${Constant.dateTime} LIKE ?",
      whereArgs: ['%$todayDate%'],
      orderBy: Constant.dateTime + " DESC",
      limit: 1,
    );
    DateTime? clockOutTime;
    if (clockOutMaps.isNotEmpty) {
      clockOutTime = DateTime.tryParse(clockOutMaps.first[Constant.dateTime]);
    }

    // Break In
    final List<Map<String, dynamic>> breakInMaps = await _database.query(
      DbConstants.BREAK_IN,
      where: "${Constant.dateTime} LIKE ?",
      whereArgs: ['%$todayDate%'],
      orderBy: Constant.dateTime + " ASC",
      limit: 1,
    );
    DateTime? breakInTime;
    if (breakInMaps.isNotEmpty) {
      breakInTime = DateTime.tryParse(breakInMaps.first[Constant.dateTime]);
    }

    // Break Out
    final List<Map<String, dynamic>> breakOutMaps = await _database.query(
      DbConstants.BREAK_OUT,
      where: "${Constant.dateTime} LIKE?",
      whereArgs: ['%$todayDate%'],
      orderBy: Constant.dateTime + " DESC",
      limit: 1,
    );
    DateTime? breakOutTime;
    if (breakOutMaps.isNotEmpty) {
      breakOutTime = DateTime.tryParse(breakOutMaps.first[Constant.dateTime]);
    }

    return {
      Constant.clockInTime: clockInTime,
      Constant.clockOutTime: clockOutTime,
      Constant.breakInTime: breakInTime,
      Constant.breakOutTime: breakOutTime,
    };
  }

  static Future<Map<String, dynamic>> getTodayEmergencyClockInOutTimes() async {
    final todayDate = DateFormat(Constant.yyyy_MM_dd).format(TimeUtils.getCurrentDateTime());

    // Clock In
    final List<Map<String, dynamic>> emergencyClockInMaps = await _database.query(
      DbConstants.EMERGENCY_CLOCK_IN,
      where: "${Constant.dateTime} LIKE ?",
      whereArgs: ['%$todayDate%'],
      orderBy: Constant.dateTime + " ASC",
      limit: 1,
    );
    DateTime? clockInTime;
    if (emergencyClockInMaps.isNotEmpty) {
      clockInTime = DateTime.tryParse(emergencyClockInMaps.first[Constant.dateTime]);
    }

    // Clock Out
    final List<Map<String, dynamic>> emergencyClockOutMaps = await _database.query(
      DbConstants.EMERGENCY_CLOCK_OUT,
      where: "${Constant.dateTime} LIKE ?",
      whereArgs: ['%$todayDate%'],
      orderBy: Constant.dateTime + " DESC",
      limit: 1,
    );
    DateTime? clockOutTime;
    int? clockOutId;
    String? reasonText;
    List<String>? photoFiles;
    List<String>? voiceFiles;
    if (emergencyClockOutMaps.isNotEmpty) {
      clockOutTime = DateTime.tryParse(emergencyClockOutMaps.first[Constant.dateTime]);
      clockOutId = emergencyClockOutMaps.first[Constant.id];
      final emergencyMedia = await getEmergencyMediaData(emergencyClockOutMaps.first[Constant.id]);
      if (emergencyMedia != null) {
        reasonText = emergencyMedia[Constant.reasonText];
        photoFiles = emergencyMedia[Constant.photoFiles];
        voiceFiles = emergencyMedia[Constant.voiceFiles];
      }
    }

    return {
      Constant.clockInTime: clockInTime,
      Constant.clockOutTime: clockOutTime,
      Constant.clockOutId: clockOutId,
      Constant.reasonText: reasonText,
      Constant.photoFiles: photoFiles,
      Constant.voiceFiles: voiceFiles,
    };
  }

  static Future<void> syncClockInData() async {
    try {
      final List<Map<String, dynamic>> unSyncedMaps = await _database.query(DbConstants.CLOCK_IN, where: '${Constant.isSynced} = ?', whereArgs: [0]);

      for (final map in unSyncedMaps) {
        final clockIn = ClockInReq.fromMap(map);

        // Call your API
        final apiRes = await AttendanceRepo().clockIn(clockInReq: clockIn, isOfflineData: true);

        if (apiRes.successMessage != null) {
          final id = map[Constant.id];

          // Update this entry as synced
          await _database.update(DbConstants.CLOCK_IN, {Constant.isSynced: 1}, where: '${Constant.id} = ?', whereArgs: [id]);

          Log.i('Successfully synced clock-in ID $id');
        } else {
          Log.e('Failed to sync clock-in ID ${map[Constant.id]}: ${apiRes.errorMessage}');
        }
      }
    } catch (e) {
      Log.e('Error syncing clock-in data: $e');
    }
  }

  static Future<void> syncClockOutData() async {
    try {
      final List<Map<String, dynamic>> unSyncedMaps = await _database.query(DbConstants.CLOCK_OUT, where: '${Constant.isSynced} = ?', whereArgs: [0]);

      for (final map in unSyncedMaps) {
        final clockOut = ClockOutReq.fromMap(map);

        // Call your API
        final apiRes = await AttendanceRepo().clockOut(clockOutReq: clockOut, isOfflineData: true);

        if (apiRes.successMessage != null) {
          final id = map[Constant.id];
          final clockOutId = map[Constant.id];
          if (apiRes.data!.attendanceStatus == Constant.OVERTIME) {
            await syncOvertimeData(apiRes.data!.attendanceId, clockOutId);
          }
          if (apiRes.data!.attendanceStatus == Constant.HALFDAY) {
            await syncEarlyReasonData(apiRes.data!.attendanceId, clockOutId);
          }

          // Update this entry as synced
          await _database.update(DbConstants.CLOCK_OUT, {Constant.isSynced: 1}, where: '${Constant.id} = ?', whereArgs: [id]);

          Log.i('Successfully synced clock-out ID $id');
        } else {
          Log.e('Failed to sync clock-out ID ${map[Constant.id]}: ${apiRes.errorMessage}');
        }
      }
    } catch (e) {
      Log.e('Error syncing clock-out data: $e');
    }
  }

  static Future<void> syncEmergencyClockInData() async {
    try {
      final List<Map<String, dynamic>> unSyncedMaps = await _database.query(
        DbConstants.EMERGENCY_CLOCK_IN,
        where: '${Constant.isSynced} = ?',
        whereArgs: [0],
      );

      for (final map in unSyncedMaps) {
        final clockIn = ClockInReq.fromMap(map);

        // Call your API
        final apiRes = await AttendanceRepo().emergencyClockIn(clockInReq: clockIn, isOfflineData: true);

        if (apiRes.successMessage != null) {
          final id = map[Constant.id];

          // Update this entry as synced
          await _database.update(DbConstants.EMERGENCY_CLOCK_IN, {Constant.isSynced: 1}, where: '${Constant.id} = ?', whereArgs: [id]);

          Log.i('Successfully synced emergency clock-in ID $id');
        } else {
          Log.e('Failed to sync emergency clock-in ID ${map[Constant.id]}: ${apiRes.errorMessage}');
        }
      }
    } catch (e) {
      Log.e('Error syncing emergency clock-in data: $e');
    }
  }

  static Future<void> syncEmergencyClockOutData() async {
    try {
      final List<Map<String, dynamic>> unSyncedMaps = await _database.query(
        DbConstants.EMERGENCY_CLOCK_OUT,
        where: '${Constant.isSynced} = ?',
        whereArgs: [0],
      );

      for (final map in unSyncedMaps) {
        final clockOut = ClockOutReq.fromMap(map);

        // Call your API
        final apiRes = await AttendanceRepo().emergencyClockOut(clockOutReq: clockOut, isOfflineData: true);

        if (apiRes.successMessage != null) {
          final id = map[Constant.id];
          final clockOutId = map[Constant.id];
          await syncEmergencyMediaData(apiRes.data!.attendanceId!, clockOutId);

          // Update this entry as synced
          await _database.update(DbConstants.EMERGENCY_CLOCK_OUT, {Constant.isSynced: 1}, where: '${Constant.id} = ?', whereArgs: [id]);

          Log.i('Successfully synced emergency clock-out ID $id');
        } else {
          Log.e('Failed to sync emergency clock-out ID ${map[Constant.id]}: ${apiRes.errorMessage}');
        }
      }
    } catch (e) {
      Log.e('Error syncing emergency clock-out data: $e');
    }
  }

  static Future<void> syncBreakInData() async {
    try {
      final List<Map<String, dynamic>> unSyncedMaps = await _database.query(DbConstants.BREAK_IN, where: '${Constant.isSynced} = ?', whereArgs: [0]);

      for (final map in unSyncedMaps) {
        final breakIn = BreakInReq.fromMap(map);

        // Call your API
        final apiRes = await AttendanceRepo().breakIn(breakInReq: breakIn);

        if (apiRes.successMessage != null) {
          final id = map[Constant.id];

          // Update this entry as synced
          await _database.update(DbConstants.BREAK_IN, {Constant.isSynced: 1}, where: '${Constant.id} = ?', whereArgs: [id]);

          Log.i('Successfully synced break-in ID $id');
        } else {
          Log.e('Failed to sync break-in ID ${map[Constant.id]}: ${apiRes.errorMessage}');
        }
      }
    } catch (e) {
      Log.e('Error syncing break-in data: $e');
    }
  }

  static Future<void> syncBreakOutData() async {
    try {
      final List<Map<String, dynamic>> unSyncedMaps = await _database.query(DbConstants.BREAK_OUT, where: '${Constant.isSynced} = ?', whereArgs: [0]);

      for (final map in unSyncedMaps) {
        final breakOut = BreakOutReq.fromMap(map);

        // Call your API
        final apiRes = await AttendanceRepo().breakOut(breakOutReq: breakOut);

        if (apiRes.successMessage != null) {
          final id = map[Constant.id];

          // Update this entry as synced
          await _database.update(DbConstants.BREAK_OUT, {Constant.isSynced: 1}, where: '${Constant.id} = ?', whereArgs: [id]);

          Log.i('Successfully synced break-out ID $id');
        } else {
          Log.e('Failed to sync break-out ID ${map[Constant.id]}: ${apiRes.errorMessage}');
        }
      }
    } catch (e) {
      Log.e('Error syncing break-out data: $e');
    }
  }

  static Future<Map<String, dynamic>?> getEmergencyMediaData(int clockOutId) async {
    try {
      final List<Map<String, dynamic>> unSyncedMaps = await _database.query(
        DbConstants.EMERGENCY_MEDIA,
        where: '${Constant.clockOutId} = ?',
        whereArgs: [clockOutId],
      );
      for (final map in unSyncedMaps) {
        // Convert photoFiles and voiceFiles back to lists
        final photoFiles = (map[Constant.photoFiles] as String?)?.split(',') ?? [];
        final voiceFiles = (map[Constant.voiceFiles] as String?)?.split(',') ?? [];

        // Create FormData for API call
        return {Constant.reasonText: map[Constant.reasonText], Constant.photoFiles: photoFiles, Constant.voiceFiles: voiceFiles};
      }
    } catch (e) {
      Log.e('Error syncing overtime data: $e');
    }
    return null;
  }

  static Future<void> syncEmergencyMediaData(int attendanceId, int clockOutId) async {
    try {
      final List<Map<String, dynamic>> unSyncedMaps = await _database.query(
        DbConstants.EMERGENCY_MEDIA,
        where: '${Constant.isSynced} = ? AND ${Constant.clockOutId} = ?',
        whereArgs: [0, clockOutId],
      );
      for (final map in unSyncedMaps) {
        // Convert photoFiles and voiceFiles back to lists
        final photoFiles = (map[Constant.photoFiles] as String?)?.split(',') ?? [];
        final voiceFiles = (map[Constant.voiceFiles] as String?)?.split(',') ?? [];

        // Convert file paths to MultipartFile
        final photoMultipartFiles = await Future.wait(
          photoFiles.where((path) => path.isNotEmpty).map((path) async {
            return await MultipartFile.fromFile(path, filename: path.split('/').last);
          }),
        );

        final voiceMultipartFiles = await Future.wait(
          voiceFiles.where((path) => path.isNotEmpty).map((path) async {
            return await MultipartFile.fromFile(path, filename: path.split('/').last);
          }),
        );

        // Create FormData for API call
        final overtimeDetailsReq = FormData.fromMap({
          Constant.attendanceId: attendanceId,
          Constant.emergencyReason: map[Constant.reasonText],
          Constant.images: photoMultipartFiles,
          Constant.audio: voiceMultipartFiles,
          Constant.isOfflineData: true,
        });

        // Call API
        final apiRes = await AttendanceRepo().uploadEmergencyDetails(emergencyDetailsReq: overtimeDetailsReq);

        if (apiRes.successMessage != null) {
          final id = map['id'];
          await _database.delete(DbConstants.EMERGENCY_MEDIA, where: 'id = ?', whereArgs: [id]);
          Log.i('Successfully synced emergency media ID $id');
        } else {
          Log.e('Failed to sync emergency media ID ${map['id']}: ${apiRes.errorMessage}');
        }
      }
    } catch (e) {
      Log.e('Error syncing emergency media data: $e');
    }
  }

  static Future<void> syncOvertimeData(int attendanceId, int clockOutId) async {
    try {
      final List<Map<String, dynamic>> unSyncedMaps = await _database.query(
        DbConstants.OVERTIME,
        where: '${Constant.isSynced} = ? AND ${Constant.clockOutId} = ?',
        whereArgs: [0, clockOutId],
      );
      for (final map in unSyncedMaps) {
        // Convert photoFiles and voiceFiles back to lists
        final photoFiles = (map[Constant.photoFiles] as String?)?.split(',') ?? [];
        final voiceFiles = (map[Constant.voiceFiles] as String?)?.split(',') ?? [];

        // Convert file paths to MultipartFile
        final photoMultipartFiles = await Future.wait(
          photoFiles.where((path) => path.isNotEmpty).map((path) async {
            return await MultipartFile.fromFile(path, filename: path.split('/').last);
          }),
        );

        final voiceMultipartFiles = await Future.wait(
          voiceFiles.where((path) => path.isNotEmpty).map((path) async {
            return await MultipartFile.fromFile(path, filename: path.split('/').last);
          }),
        );

        // Create FormData for API call
        final overtimeDetailsReq = FormData.fromMap({
          Constant.attendanceRecordId: attendanceId,
          Constant.reasonText: map[Constant.reasonText],
          Constant.photoFiles: photoMultipartFiles,
          Constant.voiceFiles: voiceMultipartFiles,
          Constant.isOfflineData: true,
        });

        // Call API
        final apiRes = await AttendanceRepo().uploadOvertimeDetails(overtimeDetailsReq: overtimeDetailsReq);

        if (apiRes.successMessage != null) {
          final id = map['id'];
          await _database.delete(DbConstants.OVERTIME, where: 'id = ?', whereArgs: [id]);
          Log.i('Successfully synced overtime ID $id');
        } else {
          Log.e('Failed to sync overtime ID ${map['id']}: ${apiRes.errorMessage}');
        }
      }
    } catch (e) {
      Log.e('Error syncing overtime data: $e');
    }
  }

  static Future<void> syncEarlyReasonData(int attendanceId, int clockOutId) async {
    try {
      final List<Map<String, dynamic>> unSyncedMaps = await _database.query(
        DbConstants.EARLY_REASON,
        where: '${Constant.isSynced} = ? AND ${Constant.clockOutId} = ?',
        whereArgs: [0, clockOutId],
      );
      for (final map in unSyncedMaps) {
        EarlyLeaveReq earlyReason = EarlyLeaveReq(attendanceRecordId: attendanceId, earlyReason: map[Constant.earlyReason]);

        // Call your API
        final apiRes = await AttendanceRepo().earlyLeaveReason(earlyLeaveReq: earlyReason);

        if (apiRes.successMessage != null) {
          final id = map[Constant.id];

          // Update this entry as synced
          await _database.delete(DbConstants.EARLY_REASON, where: '${Constant.id} = ?', whereArgs: [id]);

          Log.i('Successfully synced early reason ID $id');
        } else {
          Log.e('Failed to sync early reason ID ${map[Constant.id]}: ${apiRes.errorMessage}');
        }
      }
    } catch (e) {
      Log.e('Error syncing early reason data: $e');
    }
  }

  static Future<bool> hasUnsyncedData() async {
    try {
      final tables = [DbConstants.CLOCK_IN, DbConstants.CLOCK_OUT, DbConstants.BREAK_IN, DbConstants.BREAK_OUT];

      for (final table in tables) {
        final List<Map<String, dynamic>> unSyncedMaps = await _database.query(table, where: '${Constant.isSynced} = ?', whereArgs: [0], limit: 1);
        if (unSyncedMaps.isNotEmpty) {
          Log.i('Found unsynced data in table $table');
          return true;
        }
      }
      Log.i('No unsynced data found');
      return false;
    } catch (e) {
      Log.e('Error checking for unsynced data: $e');
      return false;
    }
  }

  static Future<void> deleteEntriesOlderThanTwoDays() async {
    try {
      final twoDaysAgo = TimeUtils.getCurrentDateTime().subtract(Duration(days: 2));
      final formattedDate = DateFormat(Constant.yyyy_MM_dd).format(twoDaysAgo);

      final tables = [
        DbConstants.CLOCK_IN,
        DbConstants.CLOCK_OUT,
        DbConstants.BREAK_IN,
        DbConstants.BREAK_OUT,
        DbConstants.EMERGENCY_CLOCK_IN,
        DbConstants.EMERGENCY_CLOCK_OUT,
      ];

      final deletionCounts = <String, int>{};

      for (final table in tables) {
        final deletedRows = await _database.delete(table, where: "${Constant.dateTime} LIKE ?", whereArgs: ['%$formattedDate%']);
        deletionCounts[table] = deletedRows;
      }

      Log.i('Deleted entries older than 2 days: $deletionCounts');
    } catch (e) {
      Log.e('Error deleting entries older than 2 days: $e');
    }
  }

  static Future<void> clearAllDatabaseEntries() async {
    try {
      final tables = [
        DbConstants.CLOCK_IN,
        DbConstants.CLOCK_OUT,
        DbConstants.BREAK_IN,
        DbConstants.BREAK_OUT,
        DbConstants.OVERTIME,
        DbConstants.EARLY_REASON,
        DbConstants.EMERGENCY_CLOCK_IN,
        DbConstants.EMERGENCY_CLOCK_OUT,
        DbConstants.EMERGENCY_MEDIA,
      ];
      final deletionCounts = <String, int>{};
      for (final table in tables) {
        final deletedRows = await _database.delete(table);
        deletionCounts[table] = deletedRows;
      }
      Log.i('Cleared all database entries: $deletionCounts');
    } catch (e) {
      Log.e('Error clearing all database entries: $e');
    }
  }
}
