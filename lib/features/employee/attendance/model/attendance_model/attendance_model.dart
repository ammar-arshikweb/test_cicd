import 'package:flutter/material.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/time_utils.dart';

class AttendanceModel {
  int? attendanceId;
  String? date;
  String? checkInTime;
  String? checkOutTime;
  double? totalHours;
  String? fullName;
  String? employeeId;
  String? checkInLat;
  String? checkInLong;
  String? checkOutLat;
  String? checkOutLong;
  String? earlyReason;
  final int earlyReasonStatus;
  String? attendanceStatus;
  OvertimeModel? overtime;
  bool emergencyStatus;
  EmergencyModel? emergency;

  String get formattedCheckInTime {
    try {
      if (checkInTime == null) return '';
      DateTime dt = DateTime.parse(checkInTime!);
      return TimeUtils.formatTimeOfToAMPM(TimeOfDay(hour: dt.hour, minute: dt.minute));
    } catch (e) {
      return '';
    }
  }

  String get formattedCheckOutTime {
    try {
      if (checkOutTime == null) return '';
      DateTime dt = DateTime.parse(checkOutTime!);
      return TimeUtils.formatTimeOfToAMPM(TimeOfDay(hour: dt.hour, minute: dt.minute));
    } catch (e) {
      return '';
    }
  }

  String get formattedOverTimeHours {
    if (overtime?.overtimeHours == null) return '';
    final hours = overtime!.overtimeHours.floor();
    final minutes = ((overtime!.overtimeHours - hours) * 60).round();
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  String get formattedEmergencyHours {
    if (emergency?.emergencyHours == null) return '';
    final hours = emergency!.emergencyHours!.floor();
    final minutes = ((emergency!.emergencyHours! - hours) * 60).round();
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  AttendanceModel({
    this.attendanceId,
    this.date,
    this.checkInTime,
    this.checkOutTime,
    this.totalHours,
    this.fullName,
    this.employeeId,
    this.checkInLat,
    this.checkInLong,
    this.checkOutLat,
    this.checkOutLong,
    this.earlyReason,
    this.earlyReasonStatus = 0,
    this.attendanceStatus,
    this.overtime,
    this.emergencyStatus = false,
    this.emergency,
  });

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      attendanceId: map[Constant.attendanceId],
      date: map[Constant.date],
      checkInTime: map[Constant.checkInTime],
      checkOutTime: map[Constant.checkOutTime],
      totalHours: (map[Constant.totalHours] ?? 0).toDouble(),
      fullName: map[Constant.fullName],
      employeeId: map[Constant.employeeId],
      checkInLat: map[Constant.checkInLat],
      checkInLong: map[Constant.checkInLong],
      checkOutLat: map[Constant.checkOutLat],
      checkOutLong: map[Constant.checkOutLong],
      earlyReason: map[Constant.earlyReason],
      earlyReasonStatus: map[Constant.earlyReasonStatus],
      attendanceStatus: map[Constant.attendanceStatus],
      overtime: OvertimeModel.fromJson(map[Constant.overtime] ?? {}),
      emergencyStatus: map[Constant.emergencyStatus] ?? false,
      emergency: EmergencyModel.fromJson(map[Constant.emergency] ?? EmergencyModel()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      Constant.attendanceId: attendanceId,
      Constant.date: date,
      Constant.checkInTime: checkInTime,
      Constant.checkOutTime: checkOutTime,
      Constant.totalHours: totalHours,
      Constant.fullName: fullName,
      Constant.employeeId: employeeId,
      Constant.checkInLat: checkInLat,
      Constant.checkInLong: checkInLong,
      Constant.checkOutLat: checkOutLat,
      Constant.checkOutLong: checkOutLong,
      Constant.earlyReason: earlyReason,
      Constant.earlyReasonStatus: earlyReasonStatus,
      Constant.attendanceStatus: attendanceStatus,
      Constant.overtime: overtime?.toJson(),
      Constant.emergencyStatus: emergencyStatus,
      Constant.emergency: emergency?.toJson(),
    };
  }

  Map<String, dynamic> toJsonAdd() => {Constant.userId: attendanceId, Constant.checkInTime: checkInTime, Constant.checkOutTime: checkOutTime};

  Map<String, dynamic> toJsonUpdate() => {
    Constant.attendanceId: attendanceId,
    Constant.checkInTime: checkInTime,
    Constant.checkOutTime: checkOutTime,
  };

  Map<String, dynamic> toJsonDelete() => {Constant.attendanceId: attendanceId};
}

class OvertimeModel {
  int overtimeStatus;
  final double overtimeHours;
  final String reason;
  final List<String> imageUrls;
  final List<String> audioUrls;

  OvertimeModel({required this.overtimeStatus, required this.overtimeHours, required this.reason, required this.imageUrls, required this.audioUrls});

  String get formattedOverTimeHours {
    final hours = overtimeHours.floor();
    final minutes = ((overtimeHours - hours) * 60).round();
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  factory OvertimeModel.fromJson(Map<String, dynamic> json) {
    return OvertimeModel(
      overtimeStatus: json[Constant.overtimeStatus] ?? 0,
      overtimeHours: (json[Constant.overtimeHours] ?? 0).toDouble(),
      reason: json[Constant.reason] ?? '',
      imageUrls: List<String>.from(json[Constant.imageUrls] ?? []),
      audioUrls: List<String>.from(json[Constant.audioUrls] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {Constant.overtimeHours: overtimeHours, Constant.reason: reason, Constant.imageUrls: imageUrls, Constant.audioUrls: audioUrls};
  }
}

class EmergencyModel {
  String? emergencyCheckInTime;
  String? emergencyCheckInLatitude;
  String? emergencyCheckInLongitude;
  String? emergencyCheckInDeviceId;
  String? emergencyCheckOutTime;
  String? emergencyCheckOutLatitude;
  String? emergencyCheckOutLongitude;
  String? emergencyCheckOutDeviceId;
  double? emergencyHours;
  String? emergencyReason;
  List<String>? emergencyCheckOutImages;
  List<String>? emergencyCheckOutAudio;

  String get formattedEmergencyHours {
    if (emergencyHours == null) return '';
    final hours = emergencyHours!.floor();
    final minutes = ((emergencyHours! - hours) * 60).round();
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  EmergencyModel({
    this.emergencyCheckInTime,
    this.emergencyCheckInLatitude,
    this.emergencyCheckInLongitude,
    this.emergencyCheckInDeviceId,
    this.emergencyCheckOutTime,
    this.emergencyCheckOutLatitude,
    this.emergencyCheckOutLongitude,
    this.emergencyCheckOutDeviceId,
    this.emergencyHours,
    this.emergencyReason,
    this.emergencyCheckOutImages,
    this.emergencyCheckOutAudio,
  });

  factory EmergencyModel.fromJson(Map<String, dynamic> json) {
    return EmergencyModel(
      emergencyCheckInTime: json[Constant.emergencyCheckInTime] ?? '',
      emergencyCheckInLatitude: json[Constant.emergencyCheckInLatitude],
      emergencyCheckInLongitude: json[Constant.emergencyCheckInLongitude],
      emergencyCheckInDeviceId: json[Constant.emergencyCheckInDeviceId] ?? '',
      emergencyCheckOutTime: json[Constant.emergencyCheckOutTime] ?? '',
      emergencyCheckOutLatitude: json[Constant.emergencyCheckOutLatitude],
      emergencyCheckOutLongitude: json[Constant.emergencyCheckOutLongitude],
      emergencyCheckOutDeviceId: json[Constant.emergencyCheckOutDeviceId] ?? '',
      emergencyHours: (json[Constant.emergencyHours] ?? 0).toDouble(),
      emergencyReason: json[Constant.emergencyReason] ?? '',
      emergencyCheckOutImages: List<String>.from(json[Constant.emergencyCheckOutImages] ?? []),
      emergencyCheckOutAudio: List<String>.from(json[Constant.emergencyCheckOutAudio] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      Constant.emergencyCheckInTime: emergencyCheckInTime,
      Constant.emergencyCheckInLatitude: emergencyCheckInLatitude,
      Constant.emergencyCheckInLongitude: emergencyCheckInLongitude,
      Constant.emergencyCheckInDeviceId: emergencyCheckInDeviceId,
      Constant.emergencyCheckOutTime: emergencyCheckOutTime,
      Constant.emergencyCheckOutLatitude: emergencyCheckOutLatitude,
      Constant.emergencyCheckOutLongitude: emergencyCheckOutLongitude,
      Constant.emergencyCheckOutDeviceId: emergencyCheckOutDeviceId,
      Constant.emergencyHours: emergencyHours,
      Constant.emergencyReason: emergencyReason,
      Constant.emergencyCheckOutImages: emergencyCheckOutImages,
      Constant.emergencyCheckOutAudio: emergencyCheckOutAudio,
    };
  }
}
