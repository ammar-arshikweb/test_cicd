import 'package:flutter/material.dart';
import 'package:panamera_app/comman_widget/custom_loader.dart';
import 'package:panamera_app/features/customer/home/model/amc_calendar_model.dart';
import 'package:panamera_app/features/customer/home/model/customer_model.dart';
import 'package:panamera_app/features/customer/home/repository/customer_home_repo.dart';
import 'package:panamera_app/features/employee/amc/model/amc_job_data_model.dart';
import 'package:panamera_app/features/employee/amc/repository/amc_repo.dart';
import 'package:panamera_app/features/employee/home/repository/home_repo.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/log_utils.dart';
import 'package:panamera_app/utils/snackbar_messages.dart';
import 'package:panamera_app/utils/time_utils.dart';

class AdminAmcViewModel extends ChangeNotifier {
  final List<AmcCalendarModel> _calendarJobs = [];
  DateTime? _selectedDate;
  final List<AmcJobDetail> _jobsForSelectedDate = [];
  List<AmcTaskModel> _mergedGardenTasks = [];
  List<AmcTaskModel> _mergedPoolTasks = [];
  List<String> _gardenPhotos = [];
  List<String> _poolPhotos = [];
  final List<Map<String, dynamic>> allVillasWithCustomer = [];
  List<CustomerModel> allCustomerList = [];
  CustomerModel? _selectedCustomer;
  VillaModel? _selectedVilla;
  Map<DateTime, Set<int>> _dateJobTypes = {};

  List<AmcCalendarModel> get calendarJobs => _calendarJobs;
  DateTime? get selectedDate => _selectedDate;
  List<AmcJobDetail> get jobsForSelectedDate => _jobsForSelectedDate;
  List<AmcTaskModel> get mergedGardenTasks => _mergedGardenTasks;
  List<AmcTaskModel> get mergedPoolTasks => _mergedPoolTasks;
  List<String> get gardenPhotos => _gardenPhotos;
  List<String> get poolPhotos => _poolPhotos;
  AmcJobDetail? get jobData => _jobsForSelectedDate.isNotEmpty ? _jobsForSelectedDate.first : null;
  CustomerModel? get selectedCustomer => _selectedCustomer;
  VillaModel? get selectedVilla => _selectedVilla;
  Map<DateTime, Set<int>> get dateJobTypes => _dateJobTypes;
  int? get gardenStatus => _jobsForSelectedDate.where((job) => job.visitType == Constant.VISIT_TYPE_GARDEN).firstOrNull?.amcJobStatus;
  int? get poolStatus => _jobsForSelectedDate.where((job) => job.visitType == Constant.VISIT_TYPE_POOL).firstOrNull?.amcJobStatus;
  String get gardenTeamLeaderName =>
      _jobsForSelectedDate.where((job) => job.visitType == Constant.VISIT_TYPE_GARDEN).firstOrNull?.gardenTeamLeaderName ?? '';
  String get poolTeamLeaderName =>
      _jobsForSelectedDate.where((job) => job.visitType == Constant.VISIT_TYPE_POOL).firstOrNull?.poolTeamLeaderName ?? '';

  initModel(BuildContext context) async {
    await getAllCustomer(context, isFirstTime: true);
  }

  resetModel() {
    _calendarJobs.clear();
    _selectedDate = null;
    _jobsForSelectedDate.clear();
    _mergedGardenTasks = [];
    _mergedPoolTasks = [];
    _gardenPhotos = [];
    _poolPhotos = [];
    _selectedCustomer = null;
    _selectedVilla = null;
    _dateJobTypes = {};
    allVillasWithCustomer.clear();
    allCustomerList.clear();
  }

  Future<void> setSelectedVilla(BuildContext context, VillaModel? villa, CustomerModel customer) async {
    _selectedCustomer = customer;
    _selectedVilla = villa;
    _selectedDate = null;
    _jobsForSelectedDate.clear();
    _mergedGardenTasks = [];
    _mergedPoolTasks = [];
    _gardenPhotos = [];
    _poolPhotos = [];
    _calendarJobs.clear();
    _dateJobTypes = {};
    await getCalendarJobs(context, villa?.villaId ?? 0, customer.customerId);
    notifyListeners();
  }

  Future<void> setSelectedDate(BuildContext context, DateTime date) async {
    _selectedDate = date;
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

  Future<void> getAllCustomer(BuildContext context, {bool isFirstTime = false}) async {
    try {
      if (!isFirstTime) context.showLoader();

      final customerRes = await HomeRepo().getAllCustomers(getAll: true);
      if (!context.mounted) return;

      if (customerRes.data != null) {
        allCustomerList
          ..clear()
          ..addAll(customerRes.data!);
        for (final customer in allCustomerList) {
          final villas = customer.villaList ?? [];
          for (final villa in villas) {
            allVillasWithCustomer.add({'villa': villa, 'customer': customer});
          }
        }
      } else {
        SnackBarMsg.showErrorMessage(context, customerRes.errorMessage);
      }
      notifyListeners();
    } catch (e) {
      Log.e('Error in getAllCustomer: $e');
      SnackBarMsg.showError(context);
    } finally {
      context.hideLoader();
    }
  }

  getCalendarJobs(BuildContext context, int villaId, String? customerId) async {
    try {
      context.showLoader();
      final apiRes = await CustomerHomeRepo().getAmcJobsCalendar(
        dateRange: DateTimeRange(start: TimeUtils.getCurrentDateTime().subtract(Duration(days: 1825)), end: TimeUtils.getCurrentDateTime()),
        customerId: customerId,
        villaId: villaId,
      );
      if (apiRes.status! && apiRes.data != null) {
        if (apiRes.data!.isNotEmpty) {
          _calendarJobs
            ..clear()
            ..addAll(apiRes.data!)
            ..sort((a, b) => a.amcJobId!.compareTo(b.amcJobId!));
          _buildDateJobTypesMap();
          // Select the latest date (fetch all jobs for that date)
          await setSelectedDate(context, DateTime.parse(_calendarJobs.last.date!));
        }
      } else {
        Log.e('Error fetching calendar jobs: ${apiRes.errorMessage}');
      }
    } catch (e) {
      Log.e('Error fetching calendar jobs: $e');
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
      }
    } catch (e) {
      Log.e('Error fetching job data: $e');
    } finally {
      context.hideLoader();
      notifyListeners();
    }
    return null;
  }
}
