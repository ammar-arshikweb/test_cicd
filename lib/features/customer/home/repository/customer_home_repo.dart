import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:panamera_app/features/customer/home/model/amc_calendar_model.dart';
import 'package:panamera_app/features/customer/home/model/customer_model.dart';
import 'package:panamera_app/features/customer/home/model/project_model.dart';
import 'package:panamera_app/features/customer/home/model/task_model.dart';
import 'package:panamera_app/repositories/base_api_model.dart';
import 'package:panamera_app/services/api_constant.dart';
import 'package:panamera_app/services/dio_client.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/preference.dart';

class CustomerHomeRepo {
  Future<ApiResponse> addTask(TaskModel task) async {
    try {
      final formData = await TaskModel().buildTaskFormData(task);

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

  Future<ApiResponse<CustomerModel>> getCustomerDetail() async {
    try {
      final response = await DioClient().sendRequest.get('${ApiConstant.CUSTOMER}/${Pref.getCustomerId()}');
      return ApiResponse.fromJson(response.data, (data) => CustomerModel.fromMap(data));
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<CustomerModel>.error(e.response!.data);
      } else {
        return ApiResponse(status: false, errorMessage: Constant.something_went_wrong_please_try_again);
      }
    }
  }

  Future<ApiResponse<List<AmcCalendarModel>?>> getAmcJobsCalendar({DateTimeRange? dateRange, String? customerId, int? villaId}) async {
    try {
      final response = await DioClient().sendRequest.get(
        ApiConstant.AMC_JOBS_CALENDAR,
        queryParameters: {
          if (dateRange != null) Constant.startDate: DateFormat(Constant.yyyy_MM_dd).format(dateRange.start),
          if (dateRange != null) Constant.endDate: DateFormat(Constant.yyyy_MM_dd).format(dateRange.end),
          if (customerId != null) Constant.customerId: customerId,
          if (villaId != null) Constant.villaId: villaId,
        },
      );

      final List<dynamic> jsonList = response.data[Constant.data] ?? [];

      final List<AmcCalendarModel> jobs = jsonList.map((e) => AmcCalendarModel.fromJson(e as Map<String, dynamic>)).toList();

      return ApiResponse<List<AmcCalendarModel>>(
        status: response.data[Constant.status],
        successMessage: response.data[Constant.successMessage],
        data: jobs,
      );
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<List<AmcCalendarModel>>.error(e.response!.data);
      } else {
        return ApiResponse<List<AmcCalendarModel>>(errorMessage: Constant.something_went_wrong_please_try_again);
      }
    }
  }

  Future<ApiResponse<List<ProjectModel>>> getProjectImages() async {
    try {
      final response = await DioClient().sendRequest.get(ApiConstant.PROJECT_IMAGES);

      final List<dynamic> jsonList = response.data[Constant.data] ?? [];
      final List<ProjectModel> projects = jsonList.map((e) => ProjectModel.fromMap(e as Map<String, dynamic>)).toList();
      return ApiResponse<List<ProjectModel>>(
        status: response.data[Constant.status],
        successMessage: response.data[Constant.successMessage],
        data: projects,
      );
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<List<ProjectModel>>.error(e.response!.data);
      } else {
        return ApiResponse(status: false, errorMessage: Constant.something_went_wrong_please_try_again);
      }
    }
  }

  Future<ApiResponse> addFeedback(String feedbackText) async {
    try {
      final response = await DioClient().sendRequest.post(
        ApiConstant.FEEDBACK,
        data: {Constant.customerId: Pref.getCustomerId(), Constant.feedbackText: feedbackText},
      );
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
