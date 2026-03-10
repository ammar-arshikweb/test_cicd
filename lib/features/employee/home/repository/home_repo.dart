import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:panamera_app/features/customer/home/model/customer_model.dart';
import 'package:panamera_app/features/customer/home/model/task_model.dart';
import 'package:panamera_app/features/employee/home/model/job_count_model.dart';
import 'package:panamera_app/features/login/model/emp_login_res.dart';
import 'package:panamera_app/repositories/base_api_model.dart';
import 'package:panamera_app/services/api_constant.dart';
import 'package:panamera_app/services/dio_client.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/preference.dart';
import 'package:panamera_app/utils/time_utils.dart';

class HomeRepo {
  Future<ApiResponse<PaginatedData<TaskModel>>> getTasks({
    int page = 1,
    String? supervisorId,
    String? customerId,
    String? dateType,
    DateTimeRange? dateRange,
    int? taskStatus,
    int? taskPriority,
    int? pageSize,
    bool? isExport,
    required int taskType,
  }) async {
    try {
      final queryParams = {
        Constant.page: page,
        Constant.taskType: taskType,
        Constant.pageSize: pageSize ?? 10,
        if (taskStatus != null) Constant.taskStatus: taskStatus,
        if (taskPriority != null) Constant.priority: taskPriority,
        if (supervisorId != null) Constant.supervisorId: supervisorId,
        if (customerId != null) Constant.customerId: customerId,
        if (isExport != null) Constant.isExport: isExport,
        if (dateType != null && dateRange != null) Constant.dateType: dateType,
        if (dateType != null && dateRange != null) Constant.startDate: DateFormat(Constant.yyyy_MM_dd).format(dateRange.start),
        if (dateType != null && dateRange != null) Constant.endDate: DateFormat(Constant.yyyy_MM_dd).format(dateRange.end),
      };

      final response = await DioClient().sendRequest.get(ApiConstant.TASK_MANAGER, queryParameters: queryParams);

      return ApiResponse<PaginatedData<TaskModel>>.fromJson(
        response.data,
        (data) => PaginatedData<TaskModel>.fromJson(data, (e) => TaskModel.fromMap(e)),
      );
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<PaginatedData<TaskModel>>.error(e.response!.data);
      } else {
        return ApiResponse<PaginatedData<TaskModel>>(errorMessage: Constant.something_went_wrong_please_try_again);
      }
    }
  }

  Future<ApiResponse<JobCountsModel>> getJobsCount() async {
    try {
      final response = await DioClient().sendRequest.get(
        ApiConstant.COUNT_OF_JOB_STATS,
        queryParameters: {
          Constant.employeeId: Pref.getEmpId(),
          Constant.startDate: DateFormat(Constant.yyyy_MM_dd).format(TimeUtils.getCurrentDateTime()),
          Constant.endDate: DateFormat(Constant.yyyy_MM_dd).format(TimeUtils.getCurrentDateTime()),
        },
      );

      return ApiResponse.fromJson(response.data, (data) => JobCountsModel.fromMap(data));
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<JobCountsModel>.error(e.response!.data);
      } else {
        return ApiResponse(status: false, errorMessage: Constant.something_went_wrong_please_try_again);
      }
    }
  }

  Future<ApiResponse> addTaskComment(int taskId, {required dynamic commentsData}) async {
    try {
      final response = await DioClient().sendRequest.post(ApiConstant.TASK_COMMENTS_ISSUES, data: commentsData);

      return ApiResponse.fromJson(response.data, ((_) {}));
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse.fromJson(e.response!.data, ((_) {}));
      } else {
        return ApiResponse(errorMessage: Constant.something_went_wrong_please_try_again);
      }
    }
  }

  Future<ApiResponse<List<EmployeeModel>>> getEmployeeByUserRole(int order, {bool isGroupNumber = false, bool isTeamLeader = false}) async {
    try {
      final response = await DioClient().sendRequest.post(
        ApiConstant.EMPLOYEE_BY_ORDER_ROLE_LIST,
        data: {isGroupNumber ? Constant.groupNumber : Constant.roleOrderId: order.toString(), if (isTeamLeader) Constant.isTeamLeader: true},
      );

      final List<dynamic> jsonList = response.data[Constant.data] ?? [];
      final items = jsonList.map((e) => EmployeeModel.fromJson2(e)).toList();

      return ApiResponse<List<EmployeeModel>>(successMessage: response.data[Constant.successMessage], data: items);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<List<EmployeeModel>>.error(e.response!.data);
      } else {
        return ApiResponse<List<EmployeeModel>>(errorMessage: Constant.something_went_wrong_please_try_again);
      }
    }
  }

  Future<ApiResponse<List<CustomerModel>>> getAllCustomers({bool getAll = true}) async {
    try {
      final response = await DioClient().sendRequest.get(ApiConstant.ALL_CUSTOMERS, queryParameters: {Constant.getAll: getAll});

      final List<dynamic> jsonList = response.data[Constant.data] ?? [];
      final items = jsonList.map((e) => CustomerModel.fromMap2(e)).toList();

      return ApiResponse<List<CustomerModel>>(successMessage: response.data[Constant.successMessage], data: items);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<List<CustomerModel>>.error(e.response!.data);
      } else {
        return ApiResponse<List<CustomerModel>>(errorMessage: Constant.something_went_wrong_please_try_again);
      }
    }
  }

  Future<ApiResponse> addFullTask(TaskModel task) async {
    try {
      final formData = await TaskModel().buildFullTaskFormData(task);

      final response = await DioClient().sendRequest.post(ApiConstant.TASK_MANAGER, data: formData);
      return ApiResponse.fromJson(response.data, ((_) {}));
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse.fromJson(e.response!.data, (_) {});
      } else {
        return ApiResponse(status: false, errorMessage: Constant.something_went_wrong_please_try_again);
      }
    }
  }
}
