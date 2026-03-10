import 'package:flutter/material.dart';
import 'package:panamera_app/comman_widget/custom_loader.dart';
import 'package:panamera_app/features/customer/home/model/task_model.dart';
import 'package:panamera_app/features/employee/home/repository/home_repo.dart';
import 'package:panamera_app/features/login/model/emp_login_res.dart';
import 'package:panamera_app/services/network_service.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/log_utils.dart';
import 'package:panamera_app/utils/snackbar_messages.dart';

class AllTasksIssuesViewModel extends ChangeNotifier {
  int _currentPage = 1;
  int _totalPages = 0;
  List<TaskModel> _taskList = [];
  int _taskType = 0; // 0 Task, 1 Issue
  int? _taskStatus; // 0 Open , 1 Closed
  int? _taskPriority;
  String? _supervisorId;
  DateTimeRange? _dateRange;
  String? _dateType; // startDate, dueDate
  List<EmployeeModel> allSupervisorList = [];
  final EmployeeModel allSupervisor = EmployeeModel(id: -1, fullName: 'All');
  EmployeeModel? _selectedSupervisor;
  int? _selectedStatus;
  int? _selectedPriority;

  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int? get taskStatus => _taskStatus;
  int? get taskPriority => _taskPriority;
  List<TaskModel> get taskList => _taskList;
  EmployeeModel? get selectedSupervisor => _selectedSupervisor;
  int? get selectedStatus => _selectedStatus;
  int? get selectedPriority => _selectedPriority;

  initModel(
    BuildContext context,
    int taskType,
    String? supervisorId,
    DateTimeRange? dateRange,
    String? dateType,
    int? taskStatus,
    List<EmployeeModel> allSupervisorList,
  ) async {
    _taskType = taskType;
    _supervisorId = supervisorId;
    if (supervisorId != null) {
      _selectedSupervisor = allSupervisorList.firstWhere((element) => element.employeeId.toString() == supervisorId, orElse: () => allSupervisor);
      setSupervisor(context, _selectedSupervisor, isFirstTime: true);
    }
    _dateRange = dateRange;
    _dateType = dateType;
    _taskStatus = taskStatus;
    _selectedStatus = taskStatus;
    this.allSupervisorList = allSupervisorList;
    await getTasks(context);
  }

  resetModel() {
    _currentPage = 1;
    _totalPages = 0;
    _taskType = 0;
    _taskStatus = null;
    _taskPriority = null;
    _supervisorId = null;
    _dateRange = null;
    _dateType = null;
    _taskList.clear();
    _selectedSupervisor = null;
    _selectedStatus = null;
    _selectedPriority = null;
  }

  void setTaskStatus(BuildContext context, int? status) {
    if (status == -1) {
      _taskStatus = null;
    } else {
      _taskStatus = status;
    }
    _currentPage = 1;
    getTasks(context);
    notifyListeners();
  }

  void setSupervisor(BuildContext context, EmployeeModel? supervisor, {bool isFirstTime = false}) {
    if (supervisor == null || supervisor.id == -1) {
      _selectedSupervisor = allSupervisor;
      _supervisorId = null;
    } else {
      _selectedSupervisor = supervisor;
      _supervisorId = supervisor.employeeId.toString();
    }
    _currentPage = 1;
    if (!isFirstTime) getTasks(context);
    notifyListeners();
  }

  void setStatus(BuildContext context, int? status) {
    if (status == null || status == -1) {
      _selectedStatus = null;
      _taskStatus = null;
    } else {
      _selectedStatus = status;
      _taskStatus = status;
    }
    _currentPage = 1;
    getTasks(context);
    notifyListeners();
  }

  void setPriority(BuildContext context, int? priority) {
    if (priority == null || priority == -1) {
      _selectedPriority = null;
      _taskPriority = null;
    } else {
      _selectedPriority = priority;
      _taskPriority = priority;
    }
    _currentPage = 1;
    getTasks(context);
    notifyListeners();
  }

  void goToNextPage(BuildContext context) {
    if (_currentPage < _totalPages) {
      _currentPage++;
      getTasks(context);
    }
  }

  void goToPrevPage(BuildContext context) {
    if (_currentPage > 1) {
      _currentPage--;
      getTasks(context);
    }
  }

  Future<void> getTasks(BuildContext context, {bool isExport = false}) async {
    if (!NetworkStatusService().connectionStatus.value) {
      SnackBarMsg.showErrorMessage(context, Helper.getLocalization()?.no_internet_connection);
      return;
    }
    try {
      context.showLoader();

      final apiRes = await HomeRepo().getTasks(
        page: _currentPage,
        taskType: _taskType,
        taskStatus: _taskStatus,
        taskPriority: _taskPriority,
        supervisorId: _supervisorId,
        dateType: _dateType,
        dateRange: _dateRange,
      );

      if (!context.mounted) {
        Log.e('Context is not mounted');
        return;
      }

      if (apiRes.status != false && apiRes.data != null) {
        var results = apiRes.data!.results;

        _taskList
          ..clear()
          ..addAll(results);
        _totalPages = apiRes.data!.pagination.totalPages;
      } else {
        SnackBarMsg.showErrorMessage(context, apiRes.errorMessage);
      }
      Log.i('Tasks List: ${_taskList.length}');
    } catch (e) {
      Log.e('Error while getTasks: $e');
      SnackBarMsg.showError(context);
    } finally {
      context.hideLoader();
      notifyListeners();
    }
  }
}
