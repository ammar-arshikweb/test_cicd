import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
import 'package:panamera_app/comman_widget/custom_loader.dart';
import 'package:panamera_app/comman_widget/image_widgets.dart';
import 'package:panamera_app/features/employee/amc/model/amc_job_data_model.dart';
import 'package:panamera_app/features/employee/amc/repository/amc_repo.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/log_utils.dart';
import 'package:panamera_app/utils/snackbar_messages.dart';
import 'package:panamera_app/utils/time_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class CommentsPhotoViewModel extends ChangeNotifier {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final picker = ImagePicker();
  final List<XFile> _images = [];
  final List<String> recordings = [];
  List<String> imageUrls = [];
  List<String> voiceUrls = [];
  bool isPlaying = false;
  bool isRecording = false;
  bool _canStop = false;
  AmcCommentModel? amcCommentDetail;
  final TextEditingController _commentController = TextEditingController();

  List<XFile> get images => _images;
  TextEditingController get commentController => _commentController;

  initModel(BuildContext context, int amcJobId, AmcCommentModel amcComment) {
    initRecorder();
    amcCommentDetail = amcComment;
    commentController.text = amcCommentDetail?.comment ?? '';
    imageUrls.addAll(amcCommentDetail!.imageUrls);
    voiceUrls.addAll(amcCommentDetail!.audioUrls);
  }

  void resetModel() {
    _images.clear();
    recordings.clear();
    isRecording = false;
    isPlaying = false;
    imageUrls.clear();
    voiceUrls.clear();
    _recorder.closeRecorder();
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

  Future<void> getCommentDetails(BuildContext context, int amcJobId) async {
    try {
      context.showLoader();

      final apiRes = await AmcRepo().getCommentsDetail(amcJobId);

      if (apiRes.status != false) {
        amcCommentDetail = apiRes.data;
        commentController.text = amcCommentDetail?.comment ?? '';
        imageUrls = amcCommentDetail!.imageUrls;
        voiceUrls = amcCommentDetail!.audioUrls;
        Log.e('Comments data fetched successfully: ${amcJobId}');
      } else {
        Log.e('Failed to fetch job data: ${apiRes.errorMessage}');
      }
    } catch (e) {
      Log.e('Error fetching job data: $e');
    } finally {
      context.hideLoader();
      notifyListeners();
    }
  }

  Future<void> addCommentDetails(BuildContext context, int amcJobId) async {
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
        Constant.logDate: TimeUtils.getCurrentDateTimeInLocal(Constant.yyyy_MM_dd),
        Constant.comment: _commentController.text,
        Constant.images: imageMultipartFiles,
        Constant.audio: voiceMultipartFiles,
      });

      final apiRes = await AmcRepo().addCommentsDetail(amcJobId, commentsData: addCommentReq);

      if (apiRes.status != false && apiRes.successMessage != null) {
        SnackBarMsg.showSuccessMessage(context, apiRes.successMessage!);
        Navigator.of(context).pop(true);
        Log.e('Comments added successfully: ${amcJobId}');
      } else {
        Log.e('Failed to add comments: ${apiRes.errorMessage}');
        SnackBarMsg.showSuccessMessage(context, apiRes.errorMessage ?? 'Failed to add comments.');
      }
    } catch (e) {
      Log.e('Error adding comment data: $e');
      SnackBarMsg.showError(context);
    } finally {
      context.hideLoader();
      notifyListeners();
    }
  }
}
