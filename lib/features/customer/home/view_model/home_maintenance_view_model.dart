import 'package:flutter/material.dart';
import 'package:panamera_app/comman_widget/custom_loader.dart';
import 'package:panamera_app/features/customer/home/model/amc_calendar_model.dart';
import 'package:panamera_app/features/customer/home/repository/customer_home_repo.dart';
import 'package:panamera_app/features/employee/amc/model/amc_job_data_model.dart';
import 'package:panamera_app/features/employee/amc/repository/amc_repo.dart';
import 'package:panamera_app/services/network_service.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/log_utils.dart';
import 'package:panamera_app/utils/preference.dart';
import 'package:panamera_app/utils/snackbar_messages.dart';
import 'package:panamera_app/utils/time_utils.dart';

class HomeMaintenanceViewModel extends ChangeNotifier {
  final List<AmcCalendarModel> _calendarJobs = [];
  DateTime? _selectedDate;
  final List<AmcJobDetail> _jobsForSelectedDate = [];
  List<AmcTaskModel> _mergedGardenTasks = [];
  List<AmcTaskModel> _mergedPoolTasks = [];
  List<String> _gardenPhotos = [];
  List<String> _poolPhotos = [];
  Map<DateTime, Set<int>> _dateJobTypes = {};

  List<AmcCalendarModel> get calendarJobs => _calendarJobs;
  DateTime? get selectedDate => _selectedDate;
  List<AmcJobDetail> get jobsForSelectedDate => _jobsForSelectedDate;
  List<AmcTaskModel> get mergedGardenTasks => _mergedGardenTasks;
  List<AmcTaskModel> get mergedPoolTasks => _mergedPoolTasks;
  List<String> get gardenPhotos => _gardenPhotos;
  List<String> get poolPhotos => _poolPhotos;
  AmcJobDetail? get jobData => _jobsForSelectedDate.isNotEmpty ? _jobsForSelectedDate.first : null;
  int? get gardenStatus => _jobsForSelectedDate.where((job) => job.visitType == Constant.VISIT_TYPE_GARDEN).firstOrNull?.amcJobStatus;
  int? get poolStatus => _jobsForSelectedDate.where((job) => job.visitType == Constant.VISIT_TYPE_POOL).firstOrNull?.amcJobStatus;
  Map<DateTime, Set<int>> get dateJobTypes => _dateJobTypes;

  initModel(BuildContext context, int villaId) {
    getCalendarJobs(context, villaId);
  }

  resetModel() {
    _calendarJobs.clear();
    _selectedDate = null;
    _jobsForSelectedDate.clear();
    _mergedGardenTasks = [];
    _mergedPoolTasks = [];
    _gardenPhotos = [];
    _poolPhotos = [];
    _dateJobTypes = {};
  }

  Future<void> setSelectedDate(BuildContext context, DateTime date) async {
    _selectedDate = date;

    // Get all jobs for the selected date
    final jobsOnDate = _calendarJobs.where((job) {
      if (job.date == null) return false;
      final jobDate = DateTime.parse(job.date!);
      return jobDate.year == date.year && jobDate.month == date.month && jobDate.day == date.day;
    }).toList();

    // Fetch details for all jobs on this date
    await _fetchAndMergeJobs(context, jobsOnDate);
    notifyListeners();
  }

  Future<void> _fetchAndMergeJobs(BuildContext context, List<AmcCalendarModel> jobsOnDate) async {
    _jobsForSelectedDate.clear();
    _mergedGardenTasks = [];
    _mergedPoolTasks = [];
    _gardenPhotos = [];
    _poolPhotos = [];

    for (final job in jobsOnDate) {
      if (job.amcJobId != null) {
        final jobDetail = await getJobDetail(context, job.amcJobId!);
        if (jobDetail != null) {
          _jobsForSelectedDate.add(jobDetail);
        }
      }
    }

    // Merge all garden tasks, pool tasks, and separate photos by job type
    for (final job in _jobsForSelectedDate) {
      _mergedGardenTasks.addAll(job.gardenTask);
      _mergedPoolTasks.addAll(job.poolTask);

      // Separate photos by visit type
      if (job.visitType == Constant.VISIT_TYPE_GARDEN) {
        _gardenPhotos.addAll(job.comments.imageUrls);
      } else if (job.visitType == Constant.VISIT_TYPE_POOL) {
        _poolPhotos.addAll(job.comments.imageUrls);
      }
    }
  }

  // Future<AmcJobDetail?> _fetchJobDetail(BuildContext context, int amcJobId) async {
  //   try {
  //     final apiRes = await AmcRepo().getJobDetail(amcJobId);
  //     if (apiRes.status != false) {
  //       return apiRes.data;
  //     }
  //   } catch (e) {
  //     Log.e('Error fetching job data for id $amcJobId: $e');
  //   }
  //   return null;
  // }

  getCalendarJobs(BuildContext context, int villaId) async {
    if (!NetworkStatusService().connectionStatus.value) {
      SnackBarMsg.showErrorMessage(context, Helper.getLocalization()?.no_internet_connection);
      return;
    }
    try {
      context.showLoader();
      final apiRes = await CustomerHomeRepo().getAmcJobsCalendar(
        dateRange: DateTimeRange(start: TimeUtils.getCurrentDateTime().subtract(Duration(days: 1825)), end: TimeUtils.getCurrentDateTime()),
        customerId: Pref.getCustomerStringId(),
        villaId: villaId,
      );
      if (apiRes.status! && apiRes.data != null) {
        if (apiRes.data!.isNotEmpty) {
          _calendarJobs
            ..clear()
            ..addAll(apiRes.data!)
            ..sort((a, b) => DateTime.parse(a.date!).compareTo(DateTime.parse(b.date!)));
          _buildDateJobTypesMap();
          // Select the latest date (without passing amcJobId - we'll fetch all jobs for that date)
          await setSelectedDate(context, DateTime.parse(_calendarJobs.last.date!));
        }
      } else {
        Log.e('Error fetching calendar jobs: ${apiRes.errorMessage}');
        SnackBarMsg.showError(context);
      }
    } catch (e) {
      Log.e('Error fetching calendar jobs: $e');
      SnackBarMsg.showError(context);
    } finally {
      context.hideLoader();
      notifyListeners();
    }
  }

  void _buildDateJobTypesMap() {
    _dateJobTypes = {};
    for (final job in _calendarJobs) {
      if (job.date == null) continue;
      final date = DateTime.parse(job.date!);
      final normalizedDate = DateTime(date.year, date.month, date.day);

      _dateJobTypes.putIfAbsent(normalizedDate, () => <int>{});

      // Use visitType from API if available
      if (job.visitType != null) {
        _dateJobTypes[normalizedDate]!.add(job.visitType!);
      } else {
        // Fallback: infer from amcJobName
        final name = (job.amcJobName ?? '').toLowerCase();
        if (name.contains('garden')) {
          _dateJobTypes[normalizedDate]!.add(Constant.VISIT_TYPE_GARDEN);
        } else if (name.contains('pool')) {
          _dateJobTypes[normalizedDate]!.add(Constant.VISIT_TYPE_POOL);
        }
      }
    }
  }

  Future<AmcJobDetail?> getJobDetail(BuildContext context, int amcJobId) async {
    try {
      context.showLoader();

      final apiRes = await AmcRepo().getJobDetail(amcJobId);

      if (apiRes.status != false) {
        Log.e('Job data fetched successfully: ${apiRes.data?.amcJobId}');
        return apiRes.data;
      } else {
        Log.e('Failed to fetch job data: ${apiRes.errorMessage}');
        SnackBarMsg.showError(context);
      }
    } catch (e) {
      Log.e('Error fetching job data: $e');
      SnackBarMsg.showError(context);
    } finally {
      context.hideLoader();
      notifyListeners();
    }
    return null;
  }
}
