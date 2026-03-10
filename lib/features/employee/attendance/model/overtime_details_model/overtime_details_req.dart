import 'package:dio/dio.dart';
import 'package:panamera_app/utils/constant.dart';

class OvertimeDetailsReq {
  int attendanceRecordId;
  String reasonText;
  List<MultipartFile> photoFiles;
  List<MultipartFile> voiceFiles;

  OvertimeDetailsReq({required this.attendanceRecordId, required this.reasonText, required this.photoFiles, required this.voiceFiles});

  factory OvertimeDetailsReq.fromMap(Map<String, dynamic> map) {
    return OvertimeDetailsReq(
      attendanceRecordId: map[Constant.attendanceRecordId] as int,
      reasonText: map[Constant.reasonText] as String,
      photoFiles: map[Constant.photoFiles] as List<MultipartFile>,
      voiceFiles: map[Constant.voiceFiles] as List<MultipartFile>,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      Constant.attendanceRecordId: attendanceRecordId,
      Constant.reasonText: reasonText,
      Constant.photoFiles: photoFiles,
      Constant.voiceFiles: voiceFiles,
    };
  }
}
