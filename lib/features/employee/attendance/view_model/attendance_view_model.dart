import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:panamera_app/comman_widget/confirmation_dialog.dart';
import 'package:panamera_app/comman_widget/custom_loader.dart';
import 'package:panamera_app/features/employee/attendance/model/attendance_model/attendance_model.dart';
import 'package:panamera_app/features/employee/attendance/model/break_in_model/break_in_req.dart';
import 'package:panamera_app/features/employee/attendance/model/break_out_model/break_out_req.dart';
import 'package:panamera_app/features/employee/attendance/model/clock_in_model/clock_in_req.dart';
import 'package:panamera_app/features/employee/attendance/model/clock_in_out_status_model/clock_in_out_status_req.dart';
import 'package:panamera_app/features/employee/attendance/model/clock_out_model/clock_out_req.dart';
import 'package:panamera_app/features/employee/attendance/repository/attendance_repo.dart';
import 'package:panamera_app/features/employee/attendance/view/early_leave_dialog.dart';
import 'package:panamera_app/features/employee/attendance/view/overtime_dialog.dart';
import 'package:panamera_app/features/employee/home/repository/home_repo.dart';
import 'package:panamera_app/features/employee/main_page/view_model/main_page_view_model.dart';
import 'package:panamera_app/features/login/model/emp_login_res.dart';
import 'package:panamera_app/gen/assets.gen.dart';
import 'package:panamera_app/responsive/screen_size_config.dart';
import 'package:panamera_app/services/database_service.dart';
import 'package:panamera_app/services/network_service.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/log_utils.dart';
import 'package:panamera_app/utils/preference.dart';
import 'package:panamera_app/utils/snackbar_messages.dart';
import 'package:panamera_app/utils/time_utils.dart';
import 'package:panamera_app/values/colors.dart';
import 'package:provider/provider.dart';
import 'package:panamera_app/utils/global_tap.dart';

class AttendanceViewModel extends ChangeNotifier {
  late Completer<GoogleMapController> googleMapController;
  late MainPageViewModel homeViewModel;
  late TabController tabController;
  int _prevIndexOfTab = 0;
  DateTime? _clockInTime;
  DateTime? _clockOutTime;
  DateTime? _breakInTime;
  DateTime? _breakOutTime;
  Position? _currentPosition;
  String? _currentAddress;
  String? _lastSyncedTime;
  int _activeTeamPageIndex = 0;
  bool _isSupervisor = false;
  bool _isMobileAdmin = false;
  int _currentPage = 1;
  int _totalPages = 1;
  final List<AttendanceModel> _teamAttendanceList = [];
  DateTimeRange selectedDateRange = DateTimeRange(start: TimeUtils.getCurrentDateTime(), end: TimeUtils.getCurrentDateTime());
  int _workingDaysInMonth = 0;
  int _absentDaysInMonth = 0;
  int _holidaysInMonth = 0;
  int _totalOvertimeInMonth = 0;
  EmployeeModel? _selectedSupervisor;
  List<EmployeeModel> allSupervisorList = [];

  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  String? get lastSyncedTime => _lastSyncedTime;
  DateTime? get clockInTime => _clockInTime;
  DateTime? get clockOutTime => _clockOutTime;
  DateTime? get breakInTime => _breakInTime;
  DateTime? get breakOutTime => _breakOutTime;
  int get activeTeamPageIndex => _activeTeamPageIndex;
  bool get isSupervisor => _isSupervisor;
  bool get isMobileAdmin => _isMobileAdmin;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  List<AttendanceModel> get teamAttendanceList => _teamAttendanceList;
  int get workingDaysInMonth => _workingDaysInMonth;
  int get absentDaysInMonth => _absentDaysInMonth;
  int get holidaysInMonth => _holidaysInMonth;
  int get totalOvertimeInMonth => _totalOvertimeInMonth;
  EmployeeModel? get selectedSupervisor => _selectedSupervisor;

  Future<void> initModel(BuildContext context, attendanceScreenState) async {
    selectedDateRange = DateTimeRange(start: TimeUtils.getCurrentDateTime(), end: TimeUtils.getCurrentDateTime());
    has(String id) => Pref.getFunctionality()?.contains(id) ?? false;
    _isSupervisor = has(Constant.MOBILE_ATTENDANCE_TEAM_ATTENDANCE);
    _isMobileAdmin = has(Constant.MOBILE_ATTENDANCE_TEAM_ATTENDANCE) && !has(Constant.MOBILE_ATTENDANCE_MY_ATTENDANCE);
    tabController = TabController(length: 2, vsync: attendanceScreenState);
    googleMapController = Completer<GoogleMapController>();
    homeViewModel = Provider.of<MainPageViewModel>(context, listen: false);

    // Now safe to call methods that depend on homeViewModel
    getLocationAndAddress(context);
    getAllSupervisor(context, isFirstTime: true);
    getTeamAttendance(context, isFirstTime: true);
    getClockInOutStatus(context, isFirstTime: true);
    homeViewModel.locationStatusStream = Geolocator.getServiceStatusStream().listen((ServiceStatus status) async {
      if (status == ServiceStatus.enabled) {
        getLocationAndAddress(context);
      }
    });

    final locationSettings = const LocationSettings(accuracy: LocationAccuracy.best, distanceFilter: 15);

    var positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
      // Log.e('position changed');
      getLocationAndAddress(context,getOnlyLocation: true);
    });

    NetworkStatusService().connectionStatus.addListener(() {
      if (NetworkStatusService().connectionStatus.value) {
        // Network is online
        getClockInOutStatus(context);
        getLocationAndAddress(context);
      } else {
        Log.e("Network is offline");
      }
    });
  }

  resetModel() {
    tabController.dispose();
    _prevIndexOfTab = 0;
    _clockInTime = null;
    _clockOutTime = null;
    _breakInTime = null;
    _breakOutTime = null;
    _activeTeamPageIndex = 0;
    _selectedSupervisor = null;
    _teamAttendanceList.clear();
  }

  void setSupervisor(BuildContext context, EmployeeModel? supervisor) {
    _selectedSupervisor = supervisor;
    getTeamAttendance(context);
    notifyListeners();
  }

  setTabControllerIndexForNotification(BuildContext context, int index) {
    if (isSupervisor) {
      tabController.index = index;
      if (tabController.index == 0) {
      } else {
        if (_isSupervisor) getTeamAttendance(context);
      }
      notifyListeners();
    }
  }

  void teamPageClick(BuildContext context, int index) {
    _activeTeamPageIndex = index;
    _currentPage = 1;
    if (_activeTeamPageIndex == 0) {
      selectedDateRange = DateTimeRange(start: TimeUtils.getCurrentDateTime(), end: TimeUtils.getCurrentDateTime());
    } else {
      selectedDateRange = DateTimeRange(
        start: TimeUtils.getCurrentDateTime().subtract(Duration(days: 1)),
        end: TimeUtils.getCurrentDateTime().subtract(Duration(days: 1)),
      );
    }
    getTeamAttendance(context);
  }

  void goToNextPage(BuildContext context) {
    if (_currentPage < _totalPages) {
      _currentPage++;
      getTeamAttendance(context);
    }
  }

  void goToPrevPage(BuildContext context) {
    if (_currentPage > 1) {
      _currentPage--;
      getTeamAttendance(context);
    }
  }

  getLocationAndAddress(BuildContext context, {bool getOnlyLocation = false}) async {
    try {
      _currentPosition = await getCurrentPosition(context);
      if (!getOnlyLocation) _currentAddress = await getAddressFromPosition(_currentPosition!);
      // Log.e("Current Position: $_currentPosition");
      notifyListeners();
      if (getOnlyLocation) return;
      final controller = await googleMapController.future;
      controller.animateCamera(CameraUpdate.newLatLngZoom(LatLng(_currentPosition!.latitude, _currentPosition!.longitude), 17));
    } catch (e) {
      Log.e("Error getting location: $e");
    }
  }

  Future<void> getAllSupervisor(BuildContext context, {bool isFirstTime = false}) async {
    if (!NetworkStatusService().connectionStatus.value) {
      return; // If offline, do not fetch data
    }
    try {
      if (!isFirstTime) context.showLoader();

      final supervisorRes = await HomeRepo().getEmployeeByUserRole(3);
      // Considering 3 is the role ID for supervisors
      if (!context.mounted) return;

      if (supervisorRes.data != null) {
        allSupervisorList = supervisorRes.data!;
        _selectedSupervisor = allSupervisorList.first;
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

  Future<void> getTeamAttendance(BuildContext context, {bool isFirstTime = false}) async {
    if (!NetworkStatusService().connectionStatus.value) {
      return; // If offline, do not fetch data
    }

    if (!isFirstTime) context.showLoader();
    try {
      Log.e('111 page: $_currentPage');

      final apiRes = await AttendanceRepo().getAttendance(
        page: _currentPage,
        dateRange: selectedDateRange,
        reportingToId: _isMobileAdmin ? _selectedSupervisor?.id : null,
      );

      if (!context.mounted) {
        Log.e('Context is not mounted');
        return;
      }

      if (apiRes.data != null) {
        _teamAttendanceList
          ..clear()
          ..addAll(apiRes.data!.results);
        _totalPages = apiRes.data!.pagination.totalPages;
      } else {
        SnackBarMsg.showErrorMessage(context, apiRes.errorMessage ?? Helper.getLocalization()!.error_occurred_try_again);
      }
      Log.i('Attendance List: ${_teamAttendanceList.length}');
    } catch (e) {
      Log.e('Error while fetching attendance: $e');
      SnackBarMsg.showError(context);
    } finally {
      context.hideLoader(); // Always hide loader
      notifyListeners();
    }
  }

  updateLastSyncedTime() {
    _lastSyncedTime = TimeUtils.formatDateTimeToOutput(TimeUtils.getCurrentDateTime(), Constant.dd_MM_yyyy_hh_mm_a);
    notifyListeners();
  }

  Future<void> getClockInOutStatus(BuildContext context, {bool isFirstTime = false}) async {
    // If device is offline, get status from local database
    if (!NetworkStatusService().connectionStatus.value) {
      Log.i('Device is offline, getting status from local database');
      context.showLoader();
      Map<String, dynamic> todayStatus = await DatabaseService.getTodayClockInOutTimes();
      if (todayStatus[Constant.clockInTime] != null) {
        _clockInTime = todayStatus[Constant.clockInTime];
        Log.i('Clock-in time from DB: $clockInTime');
      }
      if (todayStatus[Constant.clockOutTime] != null) {
        _clockOutTime = todayStatus[Constant.clockOutTime];
        Log.i('Clock-out time from DB: $clockOutTime');
      }
      if (todayStatus[Constant.breakInTime] != null) {
        _breakInTime = todayStatus[Constant.breakInTime];
        Log.i('Break-in time from DB: $breakInTime');
      }
      if (todayStatus[Constant.breakOutTime] != null) {
        _breakOutTime = todayStatus[Constant.breakOutTime];
        Log.i('Break-out time from DB: $breakOutTime');
      }
      context.hideLoader();
      return;
    }

    ClockInOutStatusReq clockInOutStatusReq = ClockInOutStatusReq(userId: Pref.getUserId().toString());
    try {
      if (!isFirstTime) context.showLoader();
      await homeViewModel.syncLocalData(context);
      final apiRes = await AttendanceRepo().clockInOutStatus(clockInOutStatusReq: clockInOutStatusReq);

      if (!context.mounted) {
        Log.e('Context is not mounted');
        return;
      }

      if (apiRes.successMessage != null && context.mounted) {
        if (apiRes.data == null) {
          Log.e('apiRes.data is null');
          SnackBarMsg.showError(context);
        } else {
          if (Pref.getShiftUpdateTime() != apiRes.data!.shiftUpdateTime) {
            confirmationDialog(
              context,
              Assets.images.attendance,
              Helper.getLocalization()!.your_shift_has_been_changed_do_you_want_to_sync_your_data,
              Helper.getLocalization()!.yes,
              DialogType.NEUTRAL,
              () async {
                await homeViewModel.syncLocalData(context);
                Navigator.pop(context);
              },
            );
          } else {
            homeViewModel.syncLocalData(context);
          }
          Pref.setShiftUpdateTime(apiRes.data!.shiftUpdateTime ?? '');
          _workingDaysInMonth = apiRes.data!.workingDaysInMonth;
          _absentDaysInMonth = apiRes.data!.absentDaysInMonth;
          _holidaysInMonth = apiRes.data!.holidaysInMonth;
          _totalOvertimeInMonth = apiRes.data!.totalOvertimeInMonth.toInt();
          _clockInTime = null;
          _clockOutTime = null;
          _breakInTime = null;
          _breakOutTime = null;
          if (apiRes.data!.clockInStatus && apiRes.data!.clockInTime != null) {
            DateTime? localClockInTime = TimeUtils.formatStringToDateTime(apiRes.data!.clockInTime!);
            _clockInTime = localClockInTime;
          }
          if (apiRes.data!.clockOutStatus && apiRes.data!.clockOutTime != null) {
            DateTime? localClockOutTime = TimeUtils.formatStringToDateTime(apiRes.data!.clockOutTime!);
            _clockOutTime = localClockOutTime;
          }
          if (apiRes.data!.breakInTime != null) {
            DateTime? localBreakInTime = TimeUtils.formatStringToDateTime(apiRes.data!.breakInTime!);
            _breakInTime = localBreakInTime;
          }
          if (apiRes.data!.breakOutTime != null) {
            DateTime? localBreakOutTime = TimeUtils.formatStringToDateTime(apiRes.data!.breakOutTime!);
            _breakOutTime = localBreakOutTime;
          }
          updateLastSyncedTime();
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

  Future<int> setBreakTime(BuildContext context, DateTime time, bool isBreakOut) async {
    if (isBreakOut) {
      return await setBreakOutTime(context, time);
    } else {
      return await setBreakInTime(context, time);
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
        await DatabaseService.addClockIn(clockInReq, false);
        Log.i('Offline mode: Clock In data saved locally');
        DateTime? localClockInTime = time;
        _clockInTime = localClockInTime;
        return 1;
      }

      final apiRes = await AttendanceRepo().clockIn(clockInReq: clockInReq);

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
          await DatabaseService.addClockIn(clockInReq, true);
          DateTime? localClockInTime = TimeUtils.formatStringToDateTime(apiRes.data!.clockInTime);
          _clockInTime = localClockInTime;
          updateLastSyncedTime();
          return 1;
        }
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

  static Future<bool?> showOvertimeOrEarlyDialog({
    required BuildContext context,
    required String message,
    required String? icon,
    required String positiveButtonText,
    required String positive2ButtonText,
    required String negativeButtonText,
    required Color mainColor,
    required Function() onPositive1ButtonClick,
    required Function() onPositive2ButtonClick,
    required Function() onNegativeButtonClick,
  }) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
          child: Dialog(
            backgroundColor: MColors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: ScreenSizeConfig.height * 0.03, horizontal: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700, color: MColors.black),
                  ),
                  SizedBox(height: ScreenSizeConfig.height * 0.05),
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mainColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => GlobalTap.safeTap(() {
                                onPositive1ButtonClick();
                              }),
                              child: Text(
                                positiveButtonText.toUpperCase(),
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: MColors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mainColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => GlobalTap.safeTap(() {
                                onPositive2ButtonClick();
                              }),
                              child: Text(
                                positive2ButtonText.toUpperCase(),
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: MColors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => GlobalTap.safeTap(() {
                                onNegativeButtonClick();
                              }),
                              child: Text(
                                negativeButtonText.toUpperCase(),
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: MColors.black, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
        int clockOutId = await DatabaseService.addClockOut(clockOutReq, false);
        Log.i('Offline mode: Clock Out data saved locally');
        DateTime? localClockOutTime = time;
        _clockOutTime = localClockOutTime;
        showOvertimeOrEarlyDialog(
          context: context,
          message: Helper.getLocalization()!.do_you_want_to_add_overtime_or_early_reason_information,
          icon: null,
          positiveButtonText: Helper.getLocalization()!.overtime,
          positive2ButtonText: Helper.getLocalization()!.early_leave_reason,
          negativeButtonText: Helper.getLocalization()!.cancel,
          mainColor: MColors.primaryGreen,
          onPositive1ButtonClick: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              barrierLabel: '',
              barrierColor: MColors.black.withValues(alpha: 0.4),
              builder: (_) {
                return OvertimeDialog(attendanceId: 0, clockOutId: clockOutId);
              },
            );
          },
          onPositive2ButtonClick: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              barrierLabel: '',
              barrierColor: MColors.black.withValues(alpha: 0.4),
              builder: (BuildContext context) {
                return EarlyLeaveDialog(attendanceId: 0, clockOutId: clockOutId);
              },
            );
          },
          onNegativeButtonClick: () {
            Navigator.of(context).pop();
          },
        ).then((_) {
          Navigator.of(context).pop();
        });
        return 2;
      }

      final apiRes = await AttendanceRepo().clockOut(clockOutReq: clockOutReq);

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
          await DatabaseService.addClockOut(clockOutReq, true);
          DateTime? localClockOutTime = TimeUtils.formatStringToDateTime(apiRes.data!.clockOutTime);
          _clockOutTime = localClockOutTime;
          updateLastSyncedTime();
          await getClockInOutStatus(context);

          if (apiRes.data!.attendanceStatus == Constant.OVERTIME) {
            // Check if overtime hours are greater than 0
            Log.e('Overtime hours: ${apiRes.data!.overtimeHours}');
            Navigator.of(context).pop();
            Future.delayed(Duration.zero, () {
              showDialog(
                context: context,
                barrierDismissible: false,
                barrierLabel: '',
                barrierColor: MColors.black.withValues(alpha: 0.4),
                builder: (BuildContext context) {
                  return OvertimeDialog(attendanceId: apiRes.data!.attendanceId);
                },
              );
            });
            return 2;
          }

          if (apiRes.data!.attendanceStatus == Constant.HALFDAY) {
            Navigator.of(context).pop();
            Future.delayed(Duration.zero, () {
              showDialog(
                context: context,
                barrierDismissible: false,
                barrierLabel: '',
                barrierColor: MColors.black.withValues(alpha: 0.4),
                builder: (BuildContext context) {
                  return EarlyLeaveDialog(attendanceId: apiRes.data!.attendanceId);
                },
              );
            });
            return 2;
          }

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

  Future<int> setBreakInTime(BuildContext context, DateTime time) async {
    String dateTimeString = TimeUtils.formatDateTimeToOutput(time, Constant.yyyy_MM_dd_HH_mm_ss);

    BreakInReq breakInReq = BreakInReq(dateTime: dateTimeString);
    try {
      context.showLoader();

      // If device is offline, return true after saving locally
      if (!NetworkStatusService().connectionStatus.value) {
        await DatabaseService.addBreakIn(breakInReq, false);
        Log.i('Offline mode: Break In data saved locally');
        DateTime? localClockInTime = time;
        _breakInTime = localClockInTime;
        return 1;
      }

      final apiRes = await AttendanceRepo().breakIn(breakInReq: breakInReq);

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
          await DatabaseService.addBreakIn(breakInReq, true);
          DateTime? localBreakInTime = TimeUtils.formatStringToDateTime(apiRes.data!.breakInTime);
          _breakInTime = localBreakInTime;
          updateLastSyncedTime();
          return 1;
        }
      } else {
        SnackBarMsg.showErrorMessage(context, apiRes.errorMessage!);
        return 0;
      }
    } catch (e) {
      Log.e('Error setBreakInTime: $e');
      SnackBarMsg.showError(context);
      return 0;
    } finally {
      context.hideLoader();
      notifyListeners();
    }
  }

  Future<int> setBreakOutTime(BuildContext context, DateTime time) async {
    String dateTimeString = TimeUtils.formatDateTimeToOutput(time, Constant.yyyy_MM_dd_HH_mm_ss);

    BreakOutReq breakOutReq = BreakOutReq(dateTime: dateTimeString);
    try {
      context.showLoader();

      // If device is offline, return true after saving locally
      if (!NetworkStatusService().connectionStatus.value) {
        await DatabaseService.addBreakOut(breakOutReq, false);
        Log.i('Offline mode: Break Out data saved locally');
        DateTime? localClockOutTime = time;
        _breakOutTime = localClockOutTime;
        return 1;
      }

      final apiRes = await AttendanceRepo().breakOut(breakOutReq: breakOutReq);

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
          await DatabaseService.addBreakOut(breakOutReq, true);
          DateTime? localBreakOutTime = TimeUtils.formatStringToDateTime(apiRes.data!.breakOutTime);
          _breakOutTime = localBreakOutTime;
          updateLastSyncedTime();
          return 1;
        }
      } else {
        SnackBarMsg.showErrorMessage(context, apiRes.errorMessage!);
        return 0;
      }
    } catch (e) {
      Log.e('Error setBreakOutTime: $e');
      SnackBarMsg.showError(context);
      return 0;
    } finally {
      context.hideLoader();
      notifyListeners();
    }
  }

  Future<Position> getCurrentPosition(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    while (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(Helper.getLocalization()!.location_permissions_are_permanently_denied_please_enable_them_in_app_settings);
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<String> getAddressFromPosition(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];
      List<String> parts =
          [place.thoroughfare, place.subLocality, place.locality].where((e) => e != null && e.trim().isNotEmpty).cast<String>().toList();

      return parts.join(", ");
    } catch (e) {
      Log.e("Error getAddressFromPosition: $e");
      return "";
    }
  }

  void setGoogleMapController(GoogleMapController controller) {
    if (!googleMapController.isCompleted) {
      googleMapController.complete(controller);
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
