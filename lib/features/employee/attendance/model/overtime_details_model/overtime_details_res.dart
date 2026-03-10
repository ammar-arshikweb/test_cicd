import 'package:panamera_app/utils/constant.dart';

class OvertimeDetailsRes {
  List<dynamic> photoPaths;
  List<dynamic> voiceNotePaths;

  OvertimeDetailsRes({required this.photoPaths, required this.voiceNotePaths});

  factory OvertimeDetailsRes.fromMap(Map<String, dynamic> map) {
    return OvertimeDetailsRes(photoPaths: map[Constant.photoPaths], voiceNotePaths: map[Constant.voiceNotePaths]);
  }

  Map<String, dynamic> toMap() {
    return {Constant.photoPaths: photoPaths, Constant.voiceNotePaths: voiceNotePaths};
  }
}
