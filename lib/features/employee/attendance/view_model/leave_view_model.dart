import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:panamera_app/comman_widget/custom_loader.dart';
import 'package:panamera_app/features/employee/attendance/model/leave_model.dart';
import 'package:panamera_app/features/employee/attendance/repository/attendance_repo.dart';
import 'package:panamera_app/features/employee/attendance/view/leave_screen.dart';
import 'package:panamera_app/services/network_service.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/log_utils.dart';
import 'package:panamera_app/utils/snackbar_messages.dart';
import 'package:panamera_app/utils/time_utils.dart';
import 'package:panamera_app/values/colors.dart';

enum DateTypes { startDate, endDate, reportingDate }

class LeaveViewModel extends ChangeNotifier {
  final List<LeaveType> leaveTypes = [
    LeaveType(id: 0, name: 'Emergency Leave'),
    LeaveType(id: 1, name: 'Annual Leave'),
    LeaveType(id: 2, name: 'Sick Leave'),
  ];
  LeaveType? _selectedLeaveType;
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _reportingDate;
  String _selectedCountryCode = '+971';
  File? _certificateFile;
  String? _certificateFileName;
  int _activeReqPageIndex = 0;
  final TextEditingController _emergencyReasonController = TextEditingController();
  final TextEditingController _contactAddressController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  late TabController _tabController;
  final List<LeaveModel> _leaveApplicationsList = [];
  int _currentPage = 1;
  int _totalPages = 1;

  LeaveType? get selectedLeaveType => _selectedLeaveType;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  DateTime? get reportingDate => _reportingDate;
  String get selectedCountryCode => _selectedCountryCode;
  File? get certificateFile => _certificateFile;
  String? get certificateFileName => _certificateFileName;
  int get activeReqPageIndex => _activeReqPageIndex;
  TextEditingController get contactAddressController => _contactAddressController;
  TextEditingController get contactNumberController => _contactNumberController;
  TextEditingController get emergencyReasonController => _emergencyReasonController;
  TabController get tabController => _tabController;
  List<LeaveModel> get leaveApplicationsList => _leaveApplicationsList;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get isCertificatePdf => _certificateFileName?.toLowerCase().endsWith('.pdf') ?? false;
  int get numberOfLeaveDays => _endDate?.difference(_startDate ?? TimeUtils.getCurrentDateTime()).inDays ?? -1;

  initModel(BuildContext context, leaveScreenState) {
    _tabController = TabController(length: 2, vsync: leaveScreenState);
    getLeaveApplications(context, isFirstTime: true);
  }

  resetModel() {
    _selectedLeaveType = null;
    _startDate = null;
    _endDate = null;
    _reportingDate = null;
    _certificateFile = null;
    _certificateFileName = null;
    _activeReqPageIndex = 0;
    _tabController.dispose();
    _emergencyReasonController.clear();
    _contactAddressController.clear();
    _contactNumberController.clear();
    _leaveApplicationsList.clear();
    _currentPage = 1;
    _totalPages = 1;
  }

  setLeaveType(LeaveType type) {
    _selectedLeaveType = type;
    notifyListeners();
  }

  void setCountryCode(CountryCode value) {
    _selectedCountryCode = value.dialCode ?? '+971';
    notifyListeners();
  }

  /// Remove certificate file
  void removeCertificate() {
    _certificateFile = null;
    _certificateFileName = null;
    notifyListeners();
  }

  void requestPageClick(BuildContext context, int index) {
    _activeReqPageIndex = index;
    _currentPage = 1;
    if (_activeReqPageIndex == 0) {
      // selectedDateRange = DateTimeRange(start: TimeUtils.getCurrentDateTime(), end: TimeUtils.getCurrentDateTime());
    } else {
      // selectedDateRange = DateTimeRange(
      //   start: TimeUtils.getCurrentDateTime().subtract(Duration(days: 1)),
      //   end: TimeUtils.getCurrentDateTime().subtract(Duration(days: 1)),
      // );
    }
    getLeaveApplications(context);
  }

  void goToNextPage(BuildContext context) {
    if (_currentPage < _totalPages) {
      _currentPage++;
      getLeaveApplications(context);
    }
  }

  void goToPrevPage(BuildContext context) {
    if (_currentPage > 1) {
      _currentPage--;
      getLeaveApplications(context);
    }
  }

  /// Pick certificate file (image or PDF) from file system
  Future<void> pickCertificateFromFiles(BuildContext context) async {
    FocusScope.of(context).unfocus();
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf']);
      if (result != null && result.files.single.path != null) {
        const int maxSize = 5 * 1024 * 1024; // 5 MB
        if (result.files.single.size > maxSize) {
          SnackBarMsg.showErrorMessage(context, 'File size should be less than 5 MB');
          return;
        }
        _certificateFile = File(result.files.single.path!);
        _certificateFileName = result.files.single.name;
        notifyListeners();
      }
    } catch (e) {
      Log.e('Error picking certificate file: $e');
      SnackBarMsg.showErrorMessage(context, 'Error picking certificate file');
    }
  }

  Future<void> pickDueDate(BuildContext context, DateTypes dateType) async {
    FocusScope.of(context).requestFocus(FocusNode());
    final picked = await showDatePicker(
      context: context,
      initialDate: dateType == DateTypes.startDate
          ? _startDate ?? TimeUtils.getCurrentDateTime()
          : dateType == DateTypes.reportingDate
          ? _reportingDate ?? TimeUtils.getCurrentDateTime()
          : _endDate ?? _startDate ?? TimeUtils.getCurrentDateTime(),
      firstDate: dateType == DateTypes.endDate ? _startDate ?? TimeUtils.getCurrentDateTime() : TimeUtils.getCurrentDateTime(),
      lastDate: DateTime(2100),
      helpText: dateType == DateTypes.startDate
          ? Helper.getLocalization()!.select_start_date
          : dateType == DateTypes.reportingDate
          ? Helper.getLocalization()!.select_reporting_date
          : Helper.getLocalization()!.select_end_date,
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
      if (dateType == DateTypes.startDate) {
        _startDate = picked;
      } else if (dateType == DateTypes.reportingDate) {
        _reportingDate = picked;
      } else {
        _endDate = picked;
      }
      notifyListeners();
    }
  }

  Future<void> getLeaveApplications(BuildContext context, {bool isFirstTime = false}) async {
    if (!NetworkStatusService().connectionStatus.value) {
      return; // If offline, do not fetch data
    }

    if (!isFirstTime) context.showLoader();
    try {
      final apiRes = await AttendanceRepo().getLeaveApplications(page: _currentPage, activeIndex: _activeReqPageIndex);

      if (apiRes.data != null) {
        _leaveApplicationsList
          ..clear()
          ..addAll(apiRes.data!.results);
        _totalPages = apiRes.data!.pagination.totalPages;
      } else {
        SnackBarMsg.showErrorMessage(context, apiRes.errorMessage ?? Helper.getLocalization()!.error_occurred_try_again);
      }
      Log.i('Leaves List: ${_leaveApplicationsList.length}');
    } catch (e) {
      Log.e('Error while fetching leave applications: $e');
      SnackBarMsg.showError(context);
    } finally {
      context.hideLoader(); // Always hide loader
      notifyListeners();
    }
  }

  submitLeave(BuildContext context) async {
    if (!validateLeave(context)) {
      return;
    }
    try {
      context.showLoader();

      MultipartFile? certificateMultipartFile;
      if (_selectedLeaveType!.id == Constant.LEAVE_TYPE_SICK && _certificateFile != null) {
        certificateMultipartFile = await MultipartFile.fromFile(_certificateFile!.path, filename: _certificateFileName);
      }

      final LeaveModel leaveModel = LeaveModel(
        leaveType: _selectedLeaveType!.id,
        emergencyReason: _selectedLeaveType!.id == Constant.LEAVE_TYPE_EMERGENCY ? _emergencyReasonController.text.trim() : null,
        startDate: TimeUtils.formatDateTimeToOutput(_startDate!, Constant.yyyy_MM_dd),
        endDate: TimeUtils.formatDateTimeToOutput(_endDate!, Constant.yyyy_MM_dd),
        reportingDate: TimeUtils.formatDateTimeToOutput(_reportingDate!, Constant.yyyy_MM_dd),
        contactAddress: _contactAddressController.text.trim(),
        contactNumber: '$_selectedCountryCode ${_contactNumberController.text.trim()}',
      );

      final apiRes = await AttendanceRepo().uploadLeaveApplication(leaveDetailsReq: leaveModel.toFormData(certificateMultipartFile));

      if (apiRes.status! && apiRes.successMessage != null) {
        SnackBarMsg.showSuccessMessage(context, apiRes.successMessage!);
        refreshLeaveTab();
        getLeaveApplications(context);
      } else {
        SnackBarMsg.showErrorMessage(context, apiRes.errorMessage ?? Helper.getLocalization()!.error_occurred_try_again);
      }
    } catch (e) {
      Log.e('Error while submit leave: $e');
      SnackBarMsg.showError(context);
    } finally {
      context.hideLoader();
    }
  }

  uploadPendingCertificate(int leaveId, BuildContext context) async {
    if (_certificateFile == null) {
      SnackBarMsg.showErrorMessage(context, 'Please select certificate file');
      return;
    }
    try {
      context.showLoader();

      MultipartFile? certificateMultipartFile;
      if (_certificateFile != null) {
        certificateMultipartFile = await MultipartFile.fromFile(_certificateFile!.path, filename: _certificateFileName);
      }

      final apiRes = await AttendanceRepo().uploadPendingCertificate(
        leaveId: leaveId,
        leaveDetailsReq: FormData.fromMap({Constant.leaveCertificate: certificateMultipartFile}),
      );

      if (apiRes.status! && apiRes.successMessage != null) {
        SnackBarMsg.showSuccessMessage(context, apiRes.successMessage!);
        await getLeaveApplications(context);
        removeCertificate();
        Navigator.of(context).pop();
      } else {
        SnackBarMsg.showErrorMessage(context, apiRes.errorMessage ?? Helper.getLocalization()!.error_occurred_try_again);
      }
    } catch (e) {
      Log.e('Error while submit leave: $e');
      SnackBarMsg.showError(context);
    } finally {
      context.hideLoader();
    }
  }

  updateLeaveStatus(BuildContext context, int leaveId, int status) async {
    try {
      context.showLoader();

      final apiRes = await AttendanceRepo().updateLeaveStatus(leaveId: leaveId, status: status);

      if (apiRes.status! && apiRes.successMessage != null) {
        SnackBarMsg.showSuccessMessage(context, apiRes.successMessage!);
        await getLeaveApplications(context);
        Navigator.of(context).pop();
      } else {
        SnackBarMsg.showErrorMessage(context, apiRes.errorMessage ?? Helper.getLocalization()!.error_occurred_try_again);
      }
    } catch (e) {
      Log.e('Error while submit leave: $e');
      SnackBarMsg.showError(context);
    } finally {
      context.hideLoader();
    }
  }

  refreshLeaveTab() {
    _selectedLeaveType = null;
    _startDate = null;
    _endDate = null;
    _reportingDate = null;
    _certificateFile = null;
    _selectedCountryCode = '+971';
    _certificateFileName = null;
    _emergencyReasonController.clear();
    _contactAddressController.clear();
    _contactNumberController.clear();
    _activeReqPageIndex = 0;
    _tabController.index = 0;
    notifyListeners();
  }

  bool validateLeave(BuildContext context) {
    if (_selectedLeaveType == null) {
      SnackBarMsg.showErrorMessage(context, 'Please select leave type');
      return false;
    }
    if (_selectedLeaveType!.id == Constant.LEAVE_TYPE_EMERGENCY) {
      if (_emergencyReasonController.text.trim().isEmpty) {
        SnackBarMsg.showErrorMessage(context, 'Please enter emergency reason');
        return false;
      }
    }
    if (_startDate == null) {
      SnackBarMsg.showErrorMessage(context, 'Please select start date');
      return false;
    }
    if (_endDate == null) {
      SnackBarMsg.showErrorMessage(context, 'Please select end date');
      return false;
    }
    if (_reportingDate == null) {
      SnackBarMsg.showErrorMessage(context, 'Please select reporting date');
      return false;
    }
    if (_reportingDate!.isBefore(_endDate!.add(Duration(days: 1)))) {
      SnackBarMsg.showErrorMessage(context, 'Reporting date should be after end date');
      return false;
    }
    if (_contactAddressController.text.trim().isEmpty) {
      SnackBarMsg.showErrorMessage(context, 'Please enter contact address');
      return false;
    }
    if (_contactNumberController.text.trim().isEmpty) {
      SnackBarMsg.showErrorMessage(context, 'Please enter contact number');
      return false;
    }
    return true;
  }

  /// View certificate file
  Future<void> viewCertificate(BuildContext context) async {
    if (_certificateFile == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CertificateViewerScreen(file: _certificateFile!, fileName: _certificateFileName ?? 'Certificate', isPdf: isCertificatePdf),
      ),
    );
  }
}
