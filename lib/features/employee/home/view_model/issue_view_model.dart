import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
import 'package:panamera_app/comman_widget/custom_loader.dart';
import 'package:panamera_app/comman_widget/image_widgets.dart';
import 'package:panamera_app/features/customer/home/model/task_model.dart';
import 'package:panamera_app/features/employee/amc/repository/amc_repo.dart';
import 'package:panamera_app/features/employee/home/repository/home_repo.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/log_utils.dart';
import 'package:panamera_app/utils/preference.dart';
import 'package:panamera_app/utils/snackbar_messages.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class IssueViewModel extends ChangeNotifier {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final picker = ImagePicker();
  final List<XFile> _images = [];
  final List<String> recordings = [];
  List<String> taskImageUrls = [];
  List<String> taskVoiceUrls = [];
  List<CommentsModel> comments = [];
  bool isPlaying = false;
  bool isRecording = false;
  bool _canStop = false;
  bool statusUpdated = false;
  late int currentTaskStatus;

  List<XFile> get images => _images;

  initModel(TaskModel? task) {
    if (task != null) {
      currentTaskStatus = task.taskStatus ?? 0;
      taskImageUrls.addAll(task.images!);
      taskVoiceUrls.addAll(task.audio!);
      if (task.comments != null && task.comments!.isNotEmpty) {
        comments.addAll(task.comments!);
      }
    }
    initRecorder();
  }

  void resetModel() {
    _images.clear();
    recordings.clear();
    isRecording = false;
    isPlaying = false;
    taskImageUrls.clear();
    taskVoiceUrls.clear();
    _recorder.closeRecorder();
    statusUpdated = false;
    comments.clear();
  }

  Future<void> pickFromGallery(BuildContext context, bool isCamera) async {
    if (isCamera) {
      // Camera allows only single image (already compressed by imageQuality param)
      final file = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 60,
        maxWidth: 1920,
        maxHeight: 1920,
      );

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

  Future<void> updateIssueStatus(BuildContext context, int taskId, int status, TaskModel issue) async {
    try {
      context.showLoader();

      final apiRes = await AmcRepo().updateIssueStatus(taskId, status);

      if (apiRes.status == true) {
        statusUpdated = true;
        currentTaskStatus = status;
        notifyListeners();
        Log.e('task status updated successfully: $taskId');
      } else {
        Log.e('Failed to update task status: ${apiRes.errorMessage}');
      }
    } catch (e) {
      Log.e('Error updating task status: $e');
    } finally {
      Navigator.of(context).pop();
      context.hideLoader();
    }
  }

  Future<void> addComments(BuildContext context, int taskId) async {
    try {
      context.showLoader();

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

      final addCommentReq = FormData.fromMap({
        Constant.taskManagerId: taskId,
        Constant.employeeId: Pref.getEmpId(),
        Constant.employeeName: Pref.getEmpName(),
        Constant.images: imageMultipartFiles,
        Constant.audio: voiceMultipartFiles,
      });

      final apiRes = await HomeRepo().addTaskComment(taskId, commentsData: addCommentReq);

      if (apiRes.status != false && apiRes.successMessage != null) {
        SnackBarMsg.showSuccessMessage(context, apiRes.successMessage!);
        Navigator.of(context).pop();
        Log.e('Comments added successfully: ${taskId}');
      } else {
        Log.e('Failed to add task comments: ${apiRes.errorMessage}');
        SnackBarMsg.showError(context);
      }
    } catch (e) {
      Log.e('Error adding task comment data: $e');
      SnackBarMsg.showError(context);
    } finally {
      context.hideLoader();
      notifyListeners();
    }
  }
}
