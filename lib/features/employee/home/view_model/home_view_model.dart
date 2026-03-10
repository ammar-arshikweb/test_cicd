import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:panamera_app/comman_widget/custom_loader.dart';
import 'package:panamera_app/comman_widget/image_widgets.dart';
import 'package:panamera_app/features/customer/home/model/customer_model.dart';
import 'package:panamera_app/features/customer/home/model/task_model.dart';
import 'package:panamera_app/features/employee/home/model/job_count_model.dart';
import 'package:panamera_app/features/employee/home/repository/home_repo.dart';
import 'package:panamera_app/features/login/model/emp_login_res.dart';
import 'package:panamera_app/services/network_service.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/log_utils.dart';
import 'package:panamera_app/utils/preference.dart';
import 'package:panamera_app/utils/snackbar_messages.dart';
import 'package:panamera_app/utils/time_utils.dart';
import 'package:panamera_app/values/colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeViewModel extends ChangeNotifier {
  JobCountsModel? _jobCounts;
  late final FlutterSoundRecorder _recorder;
  final picker = ImagePicker();
  final List<XFile> _images = [];
  final List<String> recordings = [];
  bool isPlaying = false;
  bool isRecording = false;
  bool _canStop = false;
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  DateTime? _startDate;
  DateTime? _dueDate;
  List<EmployeeModel> allSupervisorList = [];
  List<EmployeeModel> allTLList = [];
  List<CustomerModel> allCustomerList = [];
  CustomerModel? _selectedCustomer;
  VillaModel? _selectedVilla;
  int? _selectedPriority;
  String? _selectedReminder;
  EmployeeModel? _selectedSupervisor;
  EmployeeModel? _selectedTL;

  JobCountsModel? get jobCounts => _jobCounts;
  List<XFile> get images => _images;
  TextEditingController get titleController => _titleController;
  TextEditingController get descController => _descController;
  DateTime? get startDate => _startDate;
  DateTime? get dueDate => _dueDate;
  CustomerModel? get selectedCustomer => _selectedCustomer;
  VillaModel? get selectedVilla => _selectedVilla;
  List<VillaModel> get availableVillas => _selectedCustomer?.villaList ?? [];
  int? get selectedPriority => _selectedPriority;
  String? get selectedReminder => _selectedReminder;
  EmployeeModel? get selectedSupervisor => _selectedSupervisor;
  EmployeeModel? get selectedTL => _selectedTL;

  initModel(BuildContext context) async {
    await getJobCounts(context, isFirstTime: true);
    await getAllCustomerAndSupervisor(context);
    _selectedSupervisor = allSupervisorList.firstWhereOrNull((element) => element.employeeId == Pref.getEmpId());
    if (Pref.getFunctionality()?.contains(Constant.MOBILE_DASHBOARD_ADMIN) ?? false) {
      _titleController = TextEditingController();
      _descController = TextEditingController();
      _recorder = FlutterSoundRecorder();
      initRecorder();
    }
    notifyListeners();
  }

  void resetModel() {
    allCustomerList.clear();
    allSupervisorList.clear();
    allTLList.clear();
    if (Pref.getFunctionality()?.contains(Constant.MOBILE_DASHBOARD_ADMIN) ?? false) {
      clearTaskForm();
    }
  }

  void clearTaskForm() {
    _images.clear();
    recordings.clear();
    isRecording = false;
    isPlaying = false;
    _recorder.closeRecorder();
    _titleController.clear();
    _descController.clear();
    _startDate = null;
    _dueDate = null;
    _selectedCustomer = null;
    _selectedVilla = null;
    _selectedPriority = null;
    _selectedReminder = null;
    _selectedSupervisor = null;
    _selectedTL = null;
  }

  void setCustomer(CustomerModel? customer) {
    _selectedCustomer = customer;
    _selectedVilla = null; // Reset villa selection when customer changes
    notifyListeners();
  }

  void setVilla(VillaModel? villa) {
    _selectedVilla = villa;
    notifyListeners();
  }

  void setPriority(int? priority) {
    _selectedPriority = priority;
    notifyListeners();
  }

  void setReminder(String? reminder) {
    _selectedReminder = reminder;
    notifyListeners();
  }

  void setSupervisor(EmployeeModel? supervisor) {
    _selectedSupervisor = supervisor;
    notifyListeners();
  }

  void setTL(EmployeeModel? tl) {
    _selectedTL = tl;
    notifyListeners();
  }

  Future<void> pickDueDate(BuildContext context, bool isStartDate) async {
    FocusScope.of(context).requestFocus(FocusNode());
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate ?? TimeUtils.getCurrentDateTime() : _dueDate ?? TimeUtils.getCurrentDateTime(),
      firstDate: TimeUtils.getCurrentDateTime(),
      lastDate: DateTime(2100),
      helpText: isStartDate ? Helper.getLocalization()!.select_start_date : Helper.getLocalization()!.select_due_date,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: MColors.primaryGreen, primary: MColors.primaryGreen),
            dialogTheme: DialogThemeData(backgroundColor: Colors.white),
            datePickerTheme: DatePickerThemeData(
              headerHelpStyle: Theme.of(context).textTheme.displaySmall?.copyWith(color: MColors.white, fontWeight: FontWeight.w600),
            ),
          ),
          child: child!,
        );
      },
    );
    FocusScope.of(context).requestFocus(FocusNode());
    if (picked != null) {
      if (isStartDate) {
        _startDate = picked;
      } else {
        _dueDate = picked;
      }
      notifyListeners();
    }
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

  Future<void> getAllCustomerAndSupervisor(BuildContext context, {bool isFirstTime = false}) async {
    if (!NetworkStatusService().connectionStatus.value) {
      SnackBarMsg.showErrorMessage(context, Helper.getLocalization()?.no_internet_connection);
      return;
    }
    try {
      if (!isFirstTime) context.showLoader();

      final customerRes = await HomeRepo().getAllCustomers(getAll: true);
      final supervisorRes = await HomeRepo().getEmployeeByUserRole(3);
      final tlRes = await HomeRepo().getEmployeeByUserRole(4, isTeamLeader: true);
      // Considering 3 is the role ID for supervisors
      if (!context.mounted) return;

      if (customerRes.data != null) {
        allCustomerList = customerRes.data!;
      } else {
        SnackBarMsg.showErrorMessage(context, customerRes.errorMessage);
      }

      if (supervisorRes.data != null) {
        allSupervisorList = supervisorRes.data!;
      } else {
        SnackBarMsg.showErrorMessage(context, supervisorRes.errorMessage);
      }

      if (tlRes.data != null) {
        allTLList = tlRes.data!;
      } else {
        SnackBarMsg.showErrorMessage(context, tlRes.errorMessage);
      }

      notifyListeners();
    } catch (e) {
      Log.e('Error in getAllCustomerAndSupervisor: $e');
      SnackBarMsg.showError(context);
    } finally {
      context.hideLoader();
    }
  }

  Future<void> getJobCounts(BuildContext context, {bool isFirstTime = false}) async {
    if (!NetworkStatusService().connectionStatus.value) {
      SnackBarMsg.showErrorMessage(context, Helper.getLocalization()?.no_internet_connection);
      return;
    }
    try {
      if (!isFirstTime) context.showLoader();

      final apiRes = await HomeRepo().getJobsCount();

      if (apiRes.status == true) {
        _jobCounts = apiRes.data;
        notifyListeners();
        Log.e('Jobs count fetched successfully');
      } else {
        Log.e('Failed to get job count: ${apiRes.errorMessage}');
      }
    } catch (e) {
      Log.e('Error updating task status: $e');
    } finally {
      context.hideLoader();
    }
  }

  bool _validateForm(BuildContext context) {
    var strings = Helper.getLocalization()!;

    if (_titleController.text.trim().isEmpty) {
      SnackBarMsg.showErrorMessage(context, strings.please_enter_task_title);
      return false;
    }

    if (_descController.text.trim().isEmpty) {
      SnackBarMsg.showErrorMessage(context, strings.please_enter_task_description);
      return false;
    }

    if (_selectedCustomer == null) {
      SnackBarMsg.showErrorMessage(context, strings.please_select_customer);
      return false;
    }

    if (_selectedVilla == null) {
      SnackBarMsg.showErrorMessage(context, strings.please_select_villa);
      return false;
    }

    if (_selectedPriority == null) {
      SnackBarMsg.showErrorMessage(context, strings.please_select_priority);
      return false;
    }

    if (_selectedReminder == null) {
      SnackBarMsg.showErrorMessage(context, strings.please_select_reminder);
      return false;
    }

    if (selectedSupervisor == null) {
      SnackBarMsg.showErrorMessage(context, strings.please_select_supervisor);
      return false;
    }

    if (_startDate == null) {
      SnackBarMsg.showErrorMessage(context, strings.please_select_start_date);
      return false;
    }

    if (_dueDate == null) {
      SnackBarMsg.showErrorMessage(context, strings.please_select_due_date);
      return false;
    }

    // Check if due date is after start date
    if (_dueDate!.isBefore(_startDate!)) {
      SnackBarMsg.showErrorMessage(context, strings.due_date_should_be_after_start_date);
      return false;
    }

    return true;
  }

  Future<bool?> addTask(BuildContext context) async {
    if (!_validateForm(context)) return false;
    try {
      context.showLoader();

      final addTaskReq = TaskModel(
        taskName: _titleController.text.trim(),
        notes: _descController.text,
        customerId: _selectedCustomer?.customerId,
        customerName: _selectedCustomer?.customerName,
        villaId: _selectedVilla?.villaId,
        jobType: 0,
        priority: _selectedPriority,
        reminder: _selectedReminder,
        supervisorId: _selectedSupervisor?.employeeId,
        teamLeaderId: _selectedTL?.employeeId,
        startDate: DateFormat(Constant.yyyy_MM_dd).format(_startDate!),
        dueDate: DateFormat(Constant.yyyy_MM_dd).format(_dueDate!),
        taskStatus: 0,
        taskType: 0,
        approvalStatus: 1,
        imagesFile: _images,
        audio: recordings,
      );

      final apiRes = await HomeRepo().addFullTask(addTaskReq);

      if (apiRes.status != false && apiRes.successMessage != null) {
        SnackBarMsg.showSuccessMessage(context, apiRes.successMessage!);
        notifyListeners();
        Log.e('Task added successfully');
        return true;
      } else {
        Log.e('Failed to add task: ${apiRes.errorMessage}');
        SnackBarMsg.showError(context);
      }
    } catch (e) {
      Log.e('Error adding task data: $e');
      SnackBarMsg.showError(context);
    } finally {
      context.hideLoader();
    }
    return null;
  }
}
