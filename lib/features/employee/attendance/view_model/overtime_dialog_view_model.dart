import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
import 'package:panamera_app/comman_widget/custom_loader.dart';
import 'package:panamera_app/comman_widget/image_widgets.dart';
import 'package:panamera_app/features/employee/attendance/model/attendance_model/attendance_model.dart';
import 'package:panamera_app/features/employee/attendance/model/overtime_status/overtime_status_req.dart';
import 'package:panamera_app/features/employee/attendance/repository/attendance_repo.dart';
import 'package:panamera_app/features/employee/attendance/view_model/attendance_view_model.dart';
import 'package:panamera_app/services/database_service.dart';
import 'package:panamera_app/services/network_service.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/log_utils.dart';
import 'package:panamera_app/utils/snackbar_messages.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class OverTimeDialogViewModel extends ChangeNotifier {
  final TextEditingController _reasonController = TextEditingController();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  final picker = ImagePicker();
  final List<XFile> _images = [];
  final List<String> recordings = [];
  late int _attendanceId;
  List<String> imageUrls = [];
  List<String> emergencyImageUrls = [];
  List<String> voiceUrls = [];
  List<String> emergencyVoiceUrls = [];
  bool isPlaying = false;
  bool isRecording = false;
  int? clockOutId;
  bool _canStop = false;

  FlutterSoundPlayer get player => _player;
  List<XFile> get images => _images;
  TextEditingController get reasonController => _reasonController;

  initModel(int attendanceId, OvertimeModel? overtimeModel, EmergencyModel? emergencyModel, int? clockOut) async {
    clockOutId = clockOut;
    _attendanceId = attendanceId;
    if (overtimeModel != null) {
      Log.e('00, overtimeModel: ${overtimeModel.toJson()}');
      _reasonController.text = overtimeModel.reason ?? '';
      imageUrls.addAll(overtimeModel.imageUrls);
      voiceUrls.addAll(overtimeModel.audioUrls);
    }
    if (emergencyModel != null) {
      Log.e('00, emergencyModel: ${emergencyModel.toJson()}');
      emergencyImageUrls.addAll(emergencyModel.emergencyCheckOutImages ?? []);
      emergencyVoiceUrls.addAll(emergencyModel.emergencyCheckOutAudio ?? []);
    }
    await initRecorder();
  }

  void resetModel() {
    _reasonController.clear();
    _images.clear();
    recordings.clear();
    isRecording = false;
    isPlaying = false;
    imageUrls.clear();
    voiceUrls.clear();
    emergencyImageUrls.clear();
    emergencyVoiceUrls.clear();
    _player.closePlayer();
    _recorder.closeRecorder();
  }

  Future<void> pickFromGallery(BuildContext context, bool isCamera) async {
    if (isCamera) {
      // Camera allows only single image (already compressed by imageQuality param)
      final file = await picker.pickImage(source: ImageSource.camera, imageQuality: 60, maxWidth: 1920, maxHeight: 1920);

      if (file != null) {
        context.showLoader();

        final XFile? timestampedFile = await ImageWidgets.addTimestampFast(file);

        if (timestampedFile != null) {
          _images.add(timestampedFile);
        }
        context.hideLoader();
        notifyListeners();
      }
    } else {
      // Gallery allows multiple images
      context.showLoader(); // Show loader BEFORE picking

      final List<XFile> files = await picker.pickMultiImage(
        imageQuality: 60, // Note: This param is ignored for gallery in most cases
        maxWidth: 1920,
        maxHeight: 1920,
      );

      final limitedFiles = files.take(Constant.IMAGE_LIMIT - _images.length).toList();

      if (limitedFiles.isNotEmpty) {
        // Process images in parallel for faster processing
        final results = await Future.wait(
          limitedFiles.map((file) async {
            try {
              return await ImageWidgets.addTimestampFast(file);
            } catch (e) {
              Log.e('Error processing image: $e');
              return null;
            }
          }),
        );

        for (final timestampedFile in results) {
          if (timestampedFile != null) {
            _images.add(timestampedFile);
          }
        }
        notifyListeners();
      }

      context.hideLoader();
    }
  }

  void removeImage(int index) {
    _images.removeAt(index);
    notifyListeners();
  }

  Future<void> initRecorder() async {
    await Permission.microphone.request();
  }

  Future<void> startRecording() async {
    await _recorder.openRecorder();
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.mp4';

    await _recorder.startRecorder(toFile: filePath, codec: Codec.aacMP4);

    Timer(const Duration(minutes: 5), () async {
      await stopRecording(); // Automatically stop recording after 5 minutes
    });

    Timer(const Duration(seconds: 2), () async {
      _canStop = true; // Allow stopping after 2 seconds
      Log.e('_canStop: $_canStop');
      notifyListeners();
    });

    isRecording = true;
    notifyListeners();
  }

  Future<void> stopRecording() async {
    if (!_canStop) {
      Log.e('Cannot stop recording yet, please wait for 2 seconds.');
      return;
    }
    final path = await _recorder.stopRecorder();
    if (path != null) {
      recordings.add(path);
    }
    _recorder.closeRecorder();
    isRecording = false;
    _canStop = false;
    notifyListeners();
  }

  void deleteRecording(String path) {
    recordings.removeWhere((recording) => recording == path);
    notifyListeners();
  }

  Future<void> uploadOvertimeData(BuildContext context) async {
    if (_reasonController.text.isEmpty) {
      SnackBarMsg.showErrorMessage(context, Helper.getLocalization()!.please_enter_reason);
      return;
    }

    try {
      context.showLoader();

      // Save data to local database if offline
      if (!NetworkStatusService().connectionStatus.value) {
        final photoFiles = _images.map((xFile) => xFile.path).toList();
        final voiceFiles = recordings;

        // Store data in local database
        if (clockOutId == null) {
          SnackBarMsg.showErrorMessage(context, Helper.getLocalization()!.clock_out_not_found);
          return;
        }

        await DatabaseService.addOvertimeData(
          clockOutId: clockOutId!,
          reasonText: _reasonController.text,
          photoFiles: photoFiles,
          voiceFiles: voiceFiles,
        );
        SnackBarMsg.showSuccessMessage(context, Helper.getLocalization()!.overtime_request_saved);
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        return;
      }

      // Convert image files to MultipartFile
      final imageMultipartFiles = await Future.wait(
        _images.map((xFile) async {
          return await MultipartFile.fromFile(xFile.path, filename: xFile.name);
        }),
      );

      // Convert voice files to MultipartFile
      final voiceMultipartFiles = await Future.wait(
        recordings.map((path) async {
          return await MultipartFile.fromFile(path, filename: path.split('/').last);
        }),
      );

      // OvertimeDetailsReq overtimeDetailsReq = OvertimeDetailsReq(attendanceRecordId: _attendanceId, photoFiles: imageMultipartFiles, voiceFiles: voiceMultipartFiles);
      final overtimeDetailsReq = FormData.fromMap({
        Constant.attendanceRecordId: _attendanceId,
        Constant.reasonText: _reasonController.text,
        Constant.photoFiles: imageMultipartFiles,
        Constant.voiceFiles: voiceMultipartFiles,
      });

      final apiRes = await AttendanceRepo().uploadOvertimeDetails(overtimeDetailsReq: overtimeDetailsReq);

      if (apiRes.successMessage != null && context.mounted) {
        SnackBarMsg.showSuccessMessage(context, apiRes.successMessage);

        if (apiRes.data == null) {
          Log.e('apiRes.data is null');
          SnackBarMsg.showError(context);
        } else {
          Navigator.of(context).pop();
        }
      } else {
        SnackBarMsg.showErrorMessage(context, apiRes.errorMessage!);
      }
    } catch (e) {
      Log.e('Error uploading overtime data: $e');
    } finally {
      context.hideLoader();
      notifyListeners();
    }
  }

  Future<void> updateOvertimeStatus(BuildContext context, bool isApproved, int? overtimeHours) async {
    try {
      context.showLoader();

      OvertimeStatusReq overtimeStatusReq = OvertimeStatusReq(
        attendanceId: _attendanceId,
        overtimeHours: overtimeHours ?? 0,
        status: isApproved ? Constant.APPROVED : Constant.REJECTED,
      );

      final apiRes = await AttendanceRepo().uploadOvertimeStatus(overtimeStatusReq: overtimeStatusReq);

      if (apiRes.successMessage != null && context.mounted) {
        SnackBarMsg.showSuccessMessage(context, apiRes.successMessage);
        await Provider.of<AttendanceViewModel>(context, listen: false).getTeamAttendance(context);
        Navigator.of(context).pop();
      } else {
        SnackBarMsg.showErrorMessage(context, apiRes.errorMessage!);
      }
    } catch (e) {
      Log.e('Error uploading overtime data: $e');
    } finally {
      context.hideLoader();
      notifyListeners();
    }
  }
}
