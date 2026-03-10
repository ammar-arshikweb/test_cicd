import 'package:panamera_app/utils/constant.dart';

class EmergencyCheckInOutStatus {
  int? attendanceId;
  String? checkInTime;
  String? checkOutTime;
  String? checkInLat;
  String? checkInLong;
  String? checkOutLat;
  String? checkOutLong;
  String? checkInDeviceId;
  String? checkOutDeviceId;
  String? reason;
  List<String>? imageUrls;
  List<String>? audioUrls;

  EmergencyCheckInOutStatus({
    this.attendanceId,
    this.checkInTime,
    this.checkOutTime,
    this.checkInLat,
    this.checkInLong,
    this.checkOutLat,
    this.checkOutLong,
    this.checkInDeviceId,
    this.checkOutDeviceId,
    this.reason,
    this.imageUrls,
    this.audioUrls,
  });

  factory EmergencyCheckInOutStatus.fromMap(Map<String, dynamic> map) {
    return EmergencyCheckInOutStatus(
      attendanceId: map[Constant.attendanceId] ?? 0,
      checkInTime: map[Constant.checkInTime] ?? '',
      checkOutTime: map[Constant.checkOutTime] ?? '',
      checkInLat: map[Constant.checkInLat],
      checkInLong: map[Constant.checkInLong],
      checkOutLat: map[Constant.checkOutLat],
      checkOutLong: map[Constant.checkOutLong],
      checkInDeviceId: map[Constant.checkInDeviceId] ?? '',
      checkOutDeviceId: map[Constant.checkOutDeviceId] ?? '',
      reason: map[Constant.reason] ?? '',
      imageUrls: List<String>.from(map[Constant.imageUrls] ?? []),
      audioUrls: List<String>.from(map[Constant.audioUrls] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      Constant.attendanceId: attendanceId,
      Constant.checkInTime: checkInTime,
      Constant.checkOutTime: checkOutTime,
      Constant.checkInLat: checkInLat,
      Constant.checkInLong: checkInLong,
      Constant.checkOutLat: checkOutLat,
      Constant.checkOutLong: checkOutLong,
      Constant.checkInDeviceId: checkInDeviceId,
      Constant.checkOutDeviceId: checkOutDeviceId,
      Constant.reason: reason,
      Constant.imageUrls: imageUrls,
      Constant.audioUrls: audioUrls,
    };
  }
}

class EmergencyClockOutRes {
  int? attendanceId;

  EmergencyClockOutRes({required this.attendanceId});

  factory EmergencyClockOutRes.fromMap(Map<String, dynamic> map) {
    return EmergencyClockOutRes(
      attendanceId: map[Constant.attendanceId] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      Constant.attendanceId: attendanceId,
    };
  }
}
