import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:panamera_app/comman_widget/custom_loader.dart';
import 'package:panamera_app/comman_widget/image_widgets.dart';
import 'package:panamera_app/features/employee/attendance/model/clock_in_model/clock_in_req.dart';
import 'package:panamera_app/features/employee/attendance/model/clock_in_out_status_model/clock_in_out_status_req.dart';
import 'package:panamera_app/features/employee/attendance/model/clock_out_model/clock_out_req.dart';
import 'package:panamera_app/features/employee/attendance/repository/attendance_repo.dart';
import 'package:panamera_app/features/employee/attendance/view_model/attendance_view_model.dart';
import 'package:panamera_app/services/database_service.dart';
import 'package:panamera_app/services/network_service.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/log_utils.dart';
import 'package:panamera_app/utils/preference.dart';
import 'package:panamera_app/utils/snackbar_messages.dart';
import 'package:panamera_app/utils/time_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class EmergencyViewModel extends ChangeNotifier {
  DateTime? _clockInTime;
  DateTime? _clockOutTime;
  Position? _currentPosition;
  final TextEditingController _reasonController = TextEditingController();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final picker = ImagePicker();
  final List<XFile> _images = [];
  final List<String> recordings = [];
  List<String> imageUrls = [];
  List<String> voiceUrls = [];
  bool isPlaying = false;
  bool isRecording = false;
  bool _canStop = false;
  bool isBackButtonAvail = false;
  int? _attendanceId;
  int? _clockOutId;

  DateTime? get clockInTime => _clockInTime;
  DateTime? get clockOutTime => _clockOutTime;
  Position? get currentPosition => _currentPosition;
  TextEditingController get reasonController => _reasonController;
  List<XFile> get images => _images;

  initModel(BuildContext context) {
    getClockInOutStatus(context);
    initRecorder();
    getLocationAndAddress(context);
    final locationSettings = const LocationSettings(accuracy: LocationAccuracy.best, distanceFilter: 15);
    var positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
      // Log.e('position changed');
      getLocationAndAddress(context);
    });
  }

  resetModel() {
    _attendanceId = null;
    _clockOutId = null;
    _clockInTime = null;
    _clockOutTime = null;
    _reasonController.clear();
    _images.clear();
    recordings.clear();
    isRecording = false;
    isBackButtonAvail = false;
    isPlaying = false;
    _canStop = false;
    imageUrls.clear();
    voiceUrls.clear();
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
      notifyListeners();
    });

    isRecording = true;
    notifyListeners();
  }

  Future<void> stopRecording() async {
    if (!_canStop) {
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

  getLocationAndAddress(BuildContext context) async {
    try {
      _currentPosition = await AttendanceViewModel().getCurrentPosition(context);
      notifyListeners();
    } catch (e) {
      Log.e("Error getting location: $e");
    }
  }

  Future<void> getClockInOutStatus(BuildContext context, {bool isFirstTime = false}) async {
    // If device is offline, get status from local database
    if (!NetworkStatusService().connectionStatus.value) {
      Log.i('Device is offline, getting status from local database');
      context.showLoader();
      Map<String, dynamic> todayStatus = await DatabaseService.getTodayEmergencyClockInOutTimes();
      if (todayStatus[Constant.clockInTime] != null) {
        _clockInTime = todayStatus[Constant.clockInTime];
        Log.i('Clock-in time from DB: $clockInTime');
      }
      if (todayStatus[Constant.clockOutTime] != null) {
        _clockOutTime = todayStatus[Constant.clockOutTime];
        Log.i('Clock-out time from DB: $clockOutTime');
      }
      if (todayStatus[Constant.clockOutId] != null) _clockOutId = todayStatus[Constant.clockOutId];
      if (todayStatus[Constant.reasonText] != null) {
        _reasonController.text = todayStatus[Constant.reasonText];
      }
      if (todayStatus[Constant.photoFiles] != null) {
        final List<String> photoFiles = List<String>.from(todayStatus[Constant.photoFiles]);
        photoFiles.removeWhere((e) => e.trim().isEmpty);
        if (photoFiles.isNotEmpty) {
          _images
            ..clear()
            ..addAll(photoFiles.map((path) => XFile(path)));
        }
      }
      if (todayStatus[Constant.voiceFiles] != null) {
        final List<String> voiceFiles = List<String>.from(todayStatus[Constant.voiceFiles]);
        voiceFiles.removeWhere((e) => e.trim().isEmpty);
        if (voiceFiles.isNotEmpty) {
          recordings
            ..clear()
            ..addAll(voiceFiles);
        }
      }
      context.hideLoader();
      notifyListeners();
      return;
    }

    ClockInOutStatusReq clockInOutStatusReq = ClockInOutStatusReq(userId: Pref.getUserId().toString());
    try {
      if (!isFirstTime) context.showLoader();
      final apiRes = await AttendanceRepo().emergencyClockInOutStatus(clockInOutStatusReq: clockInOutStatusReq);

      if (!context.mounted) {
        Log.e('Context is not mounted');
        return;
      }

      if (apiRes.successMessage != null && context.mounted) {
        if (apiRes.data == null) {
          Log.e('apiRes.data is null');
          SnackBarMsg.showError(context);
        } else {
          _clockInTime = null;
          _clockOutTime = null;
          _attendanceId = apiRes.data!.attendanceId;
          if (apiRes.data!.checkInTime != null) {
            DateTime? localClockInTime = TimeUtils.formatStringToDateTime(apiRes.data!.checkInTime!);
            _clockInTime = localClockInTime;
          }
          if (apiRes.data!.checkOutTime != null) {
            DateTime? localClockOutTime = TimeUtils.formatStringToDateTime(apiRes.data!.checkOutTime!);
            _clockOutTime = localClockOutTime;
          }
          if (apiRes.data!.reason != null) _reasonController.text = apiRes.data!.reason!;
          if (apiRes.data!.imageUrls != null) {
            imageUrls
              ..clear()
              ..addAll(apiRes.data!.imageUrls!);
          }
          if (apiRes.data!.audioUrls != null) {
            voiceUrls
              ..clear()
              ..addAll(apiRes.data!.audioUrls!);
          }
          isBackButtonAvail = !(imageUrls.isEmpty && voiceUrls.isEmpty);
        }
      } else {
        SnackBarMsg.showErrorMessage(context, apiRes.errorMessage!);
      }
    } catch (e) {
      Log.e('Error getClockInOutStatus: $e');
      SnackBarMsg.showError(context);
    } finally {
      context.hideLoader();
      notifyListeners();
    }
  }

  Future<int> setTime(BuildContext context, DateTime time, bool isClockOut) async {
    if (isClockOut) {
      return await setClockOutTime(context, time);
    } else {
      return await setClockInTime(context, time);
    }
  }

  Future<int> setClockInTime(BuildContext context, DateTime time) async {
    String dateTimeString = TimeUtils.formatDateTimeToOutput(time, Constant.yyyy_MM_dd_HH_mm_ss);
    String deviceId = await getDeviceId() ?? '';

    ClockInReq clockInReq = ClockInReq(
      dateTime: dateTimeString,
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      checkInDeviceId: deviceId,
    );
    try {
      context.showLoader();

      // If device is offline, return true after saving locally
      if (!NetworkStatusService().connectionStatus.value) {
        await DatabaseService.addEmergencyClockIn(clockInReq, false);
        Log.i('Offline mode: Clock In data saved locally');
        _clockInTime = time;
        return 1;
      }

      final apiRes = await AttendanceRepo().emergencyClockIn(clockInReq: clockInReq);

      if (!context.mounted) {
        Log.e('Context is not mounted');
        return 0;
      }

      if (apiRes.successMessage != null && context.mounted) {
        await DatabaseService.addEmergencyClockIn(clockInReq, true);
        _clockInTime = time;
        return 1;
      } else {
        SnackBarMsg.showErrorMessage(context, apiRes.errorMessage!);
        return 0;
      }
    } catch (e) {
      Log.e('Error setClockInTime: $e');
      SnackBarMsg.showError(context);
      return 0;
    } finally {
      context.hideLoader();
      notifyListeners();
    }
  }

  Future<int> setClockOutTime(BuildContext context, DateTime time) async {
    String dateTimeString = TimeUtils.formatDateTimeToOutput(time, Constant.yyyy_MM_dd_HH_mm_ss);
    String deviceId = await getDeviceId() ?? '';

    ClockOutReq clockOutReq = ClockOutReq(
      dateTime: dateTimeString,
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      checkOutDeviceId: deviceId,
    );
    try {
      context.showLoader();

      // If device is offline, return true after saving locally
      if (!NetworkStatusService().connectionStatus.value) {
        int clockOutId = await DatabaseService.addEmergencyClockOut(clockOutReq, false);
        _clockOutId = clockOutId;
        Log.i('Offline mode: Clock Out data saved locally');
        _clockOutTime = time;
        await uploadEmergencyData(context);
        return 1;
      }

      final apiRes = await AttendanceRepo().emergencyClockOut(clockOutReq: clockOutReq);

      if (!context.mounted) {
        Log.e('Context is not mounted');
        return 0;
      }

      if (apiRes.successMessage != null && context.mounted) {
        if (apiRes.data == null) {
          Log.e('apiRes.data is null');
          SnackBarMsg.showError(context);
          return 0;
        } else {
          await DatabaseService.addEmergencyClockOut(clockOutReq, true);
          _attendanceId = apiRes.data!.attendanceId;
          _clockOutTime = time;
          await uploadEmergencyData(context);
          return 1;
        }
      } else {
        SnackBarMsg.showErrorMessage(context, apiRes.errorMessage!);
        return 0;
      }
    } catch (e) {
      Log.e('Error setClockOutTime: $e');
      SnackBarMsg.showError(context);
      return 0;
    } finally {
      context.hideLoader();
      notifyListeners();
    }
  }

  Future<void> uploadEmergencyData(BuildContext context, {bool isOnlyMediaUpload = false}) async {
    if (_clockInTime == null) {
      SnackBarMsg.showErrorMessage(context, Helper.getLocalization()!.please_check_in_first);
      return;
    }
    if (!NetworkStatusService().connectionStatus.value && _clockOutTime == null) {
      SnackBarMsg.showErrorMessage(context, Helper.getLocalization()!.please_check_out_first);
      return;
    }
    if (reasonController.text.trim().isEmpty) {
      SnackBarMsg.showErrorMessage(context, Helper.getLocalization()!.please_enter_reason);
      return;
    }
    // if (_images.isEmpty && recordings.isEmpty) {
    //   SnackBarMsg.showErrorMessage(context, Helper.getLocalization()!.please_add_images_or_audio_files);
    //   return;
    // }
    try {
      context.showLoader();

      // Save data to local database if offline
      if (!NetworkStatusService().connectionStatus.value) {
        final photoFiles = _images.map((xFile) => xFile.path).toList();
        final voiceFiles = recordings;

        // Store data in local database
        if (_clockOutId == null) {
          SnackBarMsg.showErrorMessage(context, Helper.getLocalization()!.clock_out_not_found);
          return;
        }

        await DatabaseService.addEmergencyMediaData(
          clockOutId: _clockOutId!,
          reasonText: _reasonController.text,
          photoFiles: photoFiles,
          voiceFiles: voiceFiles,
        );
        if (isOnlyMediaUpload) SnackBarMsg.showSuccessMessage(context, Helper.getLocalization()!.emergency_details_saved);
        // Navigator.of(context).pop();
        _images.clear();
        recordings.clear();
        getClockInOutStatus(context);
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

      final overtimeDetailsReq = FormData.fromMap({
        Constant.attendanceId: _attendanceId,
        Constant.emergencyReason: _reasonController.text.trim(),
        Constant.images: imageMultipartFiles,
        Constant.audio: voiceMultipartFiles,
      });

      final apiRes = await AttendanceRepo().uploadEmergencyDetails(emergencyDetailsReq: overtimeDetailsReq);

      if (apiRes.successMessage != null && context.mounted) {
        if (isOnlyMediaUpload) SnackBarMsg.showSuccessMessage(context, apiRes.successMessage);
        // Navigator.of(context).pop();
        _images.clear();
        recordings.clear();
        getClockInOutStatus(context);
      } else {
        SnackBarMsg.showErrorMessage(context, apiRes.errorMessage!);
      }
    } catch (e) {
      Log.e('Error uploading emergency data: $e');
    } finally {
      context.hideLoader();
      notifyListeners();
    }
  }

  Future<String?> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor;
    }
    return null;
  }
}
