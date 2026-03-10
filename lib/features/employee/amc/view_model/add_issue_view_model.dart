import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:panamera_app/comman_widget/custom_loader.dart';
import 'package:panamera_app/comman_widget/image_widgets.dart';
import 'package:panamera_app/features/customer/home/model/task_model.dart';
import 'package:panamera_app/features/employee/amc/model/amc_job_data_model.dart';
import 'package:panamera_app/features/employee/amc/repository/amc_repo.dart';
import 'package:panamera_app/features/employee/home/repository/home_repo.dart';
import 'package:panamera_app/features/login/model/emp_login_res.dart';
import 'package:panamera_app/services/network_service.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/log_utils.dart';
import 'package:panamera_app/utils/snackbar_messages.dart';
import 'package:panamera_app/utils/time_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AddIssueViewModel extends ChangeNotifier {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final picker = ImagePicker();
  final List<XFile> _images = [];
  final List<String> recordings = [];
  List<String> imageUrls = [];
  List<String> voiceUrls = [];
  bool isPlaying = false;
  bool isRecording = false;
  bool _canStop = false;
  int _priority = 1;
  final TextEditingController _issueTitleController = TextEditingController();
  final TextEditingController _issueDescController = TextEditingController();
  EmployeeModel? _selectedSupervisor;
  List<EmployeeModel>? _allSupervisorList;

  List<XFile> get images => _images;
  int get priority => _priority;
  TextEditingController get issueTitleController => _issueTitleController;
  TextEditingController get issueDescController => _issueDescController;
  EmployeeModel? get selectedSupervisor => _selectedSupervisor;
  List<EmployeeModel>? get allSupervisorList => _allSupervisorList;

  initModel(BuildContext context, AmcIssueModel? issue) async {
    await getAllSupervisor(context);
    if (issue != null) {
      _issueTitleController.text = issue.title;
      _issueDescController.text = issue.notes;
      imageUrls.addAll(issue.imageUrls);
      voiceUrls.addAll(issue.audioUrls);
      if (issue.supervisorId != null) {
        _selectedSupervisor = allSupervisorList?.firstWhereOrNull((element) => element.employeeId.toString() == issue.supervisorId);
        setSupervisor(_selectedSupervisor);
      }
    }
    initRecorder();
  }

  void resetModel() {
    _images.clear();
    recordings.clear();
    isRecording = false;
    isPlaying = false;
    _selectedSupervisor = null;
    imageUrls.clear();
    voiceUrls.clear();
    _recorder.closeRecorder();
    _issueTitleController.clear();
    _issueDescController.clear();
    _priority = 1;
  }

  setPriority(int value) {
    _priority = value;
    notifyListeners();
  }

  void setSupervisor(EmployeeModel? supervisor) {
    _selectedSupervisor = supervisor;
    notifyListeners();
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

  Future<void> addIssueDetails(BuildContext context, int amcJobId, String supervisorId) async {
    if (_issueTitleController.text.isEmpty || _issueDescController.text.isEmpty) {
      SnackBarMsg.showErrorMessage(context, Helper.getLocalization()!.please_enter_issue_details);
      return;
    }
    try {
      context.showLoader();

      final addIssueReq = TaskModel(
        taskName: _issueTitleController.text,
        jobType: 1,
        amcJobId: amcJobId,
        priority: _priority,
        notes: _issueDescController.text,
        approvalStatus: 1,
        taskType: 1,
        taskStatus: 0,
        wasRequested: false,
        imagesFile: _images,
        audio: recordings,
        supervisorId: _selectedSupervisor?.employeeId ?? supervisorId,
        dueDate: DateFormat(Constant.yyyy_MM_dd).format(TimeUtils.getCurrentDateTime()),
        startDate: DateFormat(Constant.yyyy_MM_dd).format(TimeUtils.getCurrentDateTime()),
      );

      final apiRes = await AmcRepo().addIssue(addIssueReq);

      if (apiRes.status != false && apiRes.successMessage != null) {
        SnackBarMsg.showSuccessMessage(context, apiRes.successMessage!);

        final issueRes = await AmcRepo().getTask(apiRes.data!.id);
        TaskModel task = issueRes.data!;
        AmcIssueModel issueModel = AmcIssueModel(
          title: task.taskName!,
          notes: task.notes!,
          issueId: task.id!,
          priority: task.priority!,
          status: task.taskStatus!,
          audioUrls: task.audio!,
          imageUrls: task.images!,
          supervisorId: _selectedSupervisor?.employeeId ?? supervisorId,
        );

        Navigator.of(context).pop(issueModel);
        Log.e('Issue added successfully: ${amcJobId}');
      } else {
        Log.e('Failed to add issue: ${apiRes.errorMessage}');
        SnackBarMsg.showError(context);
      }
    } catch (e) {
      Log.e('Error adding issue data: $e');
      SnackBarMsg.showError(context);
    } finally {
      context.hideLoader();
      notifyListeners();
    }
  }

  Future<void> getAllSupervisor(BuildContext context, {bool isFirstTime = false}) async {
    if (!NetworkStatusService().connectionStatus.value) {
      SnackBarMsg.showErrorMessage(context, Helper.getLocalization()?.no_internet_connection);
      return;
    }
    try {
      if (!isFirstTime) context.showLoader();

      final supervisorRes = await HomeRepo().getEmployeeByUserRole(3);
      // Considering 3 is the role ID for supervisors
      if (!context.mounted) return;

      if (supervisorRes.data != null) {
        _allSupervisorList = supervisorRes.data!;
      } else {
        SnackBarMsg.showErrorMessage(context, supervisorRes.errorMessage);
      }

      notifyListeners();
    } catch (e) {
      Log.e('Error in getAllSupervisor: $e');
      SnackBarMsg.showError(context);
    } finally {
      context.hideLoader();
    }
  }
}
