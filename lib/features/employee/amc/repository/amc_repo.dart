import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:panamera_app/features/customer/home/model/task_model.dart';
import 'package:panamera_app/features/employee/amc/model/amc_job_data_model.dart';
import 'package:panamera_app/features/employee/amc/model/amc_model.dart';
import 'package:panamera_app/repositories/base_api_model.dart';
import 'package:panamera_app/services/api_constant.dart';
import 'package:panamera_app/services/dio_client.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/preference.dart';
import 'package:panamera_app/utils/time_utils.dart';

class AmcRepo {
  Future<ApiResponse<PaginatedData<AmcJob>>> getAmcJobs({int page = 1}) async {
    try {
      final response = await DioClient().sendRequest.get(
        ApiConstant.AMC_JOBS,
        queryParameters: {
          Constant.employeeId: Pref.getEmpId(),
          Constant.page: page,
          Constant.pageSize: Constant.paginationPageSize,
          Constant.startDate: DateFormat(Constant.yyyy_MM_dd).format(TimeUtils.getCurrentDateTime()),
          Constant.endDate: DateFormat(Constant.yyyy_MM_dd).format(TimeUtils.getCurrentDateTime()),
        },
      );

      return ApiResponse<PaginatedData<AmcJob>>.fromJson(response.data, (data) => PaginatedData<AmcJob>.fromJson(data, (e) => AmcJob.fromMap(e)));
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<PaginatedData<AmcJob>>.error(e.response!.data);
      } else {
        return ApiResponse<PaginatedData<AmcJob>>(errorMessage: Constant.something_went_wrong_please_try_again);
      }
    }
  }

  Future<ApiResponse<AmcJobDetail>> getJobDetail(int amcJobId) async {
    try {
      final response = await DioClient().sendRequest.get('${ApiConstant.AMC_JOB_DETAILS}/$amcJobId');

      return ApiResponse<AmcJobDetail>.fromJson(response.data, (data) => AmcJobDetail.fromMap(data));
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<AmcJobDetail>.error(e.response!.data);
      } else {
        return ApiResponse<AmcJobDetail>(errorMessage: Constant.something_went_wrong_please_try_again);
      }
    }
  }

  Future<ApiResponse> updateJobStatus(int amcId, int status, bool isStartWork) async {
    try {
      final response = await DioClient().sendRequest.put(
        '${ApiConstant.AMC_JOBS}/$amcId',
        data: {
          Constant.status: status,
          isStartWork ? Constant.startTime : Constant.endTime : DateFormat(Constant.yyyy_MM_dd_HH_mm_ss).format(TimeUtils.getCurrentDateTime()),
        },
      );

      return ApiResponse.fromJson(response.data, ((_) {}));
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse.fromJson(e.response!.data, ((_) {}));
      } else {
        return ApiResponse(errorMessage: Constant.something_went_wrong_please_try_again);
      }
    }
  }

  Future<ApiResponse> updateJobTaskStatus(int visitTaskId, int status) async {
    try {
      final response = await DioClient().sendRequest.put(
        '${ApiConstant.AMC_JOB_TASK_UPDATE}/$visitTaskId',
        data: {Constant.status: status, Constant.updatedBy: Pref.getEmpId()},
      );

      return ApiResponse.fromJson(response.data, ((_) {}));
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse.fromJson(e.response!.data, ((_) {}));
      } else {
        return ApiResponse(errorMessage: Constant.something_went_wrong_please_try_again);
      }
    }
  }

  Future<ApiResponse<AmcCommentModel>> getCommentsDetail(int amcJobId) async {
    try {
      final response = await DioClient().sendRequest.get('${ApiConstant.AMC_COMMENTS}/$amcJobId');

      return ApiResponse<AmcCommentModel>.fromJson(response.data, (data) => AmcCommentModel.fromMap(data));
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<AmcCommentModel>.error(e.response!.data);
      } else {
        return ApiResponse<AmcCommentModel>(errorMessage: Constant.something_went_wrong_please_try_again);
      }
    }
  }

  Future<ApiResponse<AmcCommentModel>> addCommentsDetail(int amcJobId, {required dynamic commentsData}) async {
    try {
      final response = await DioClient().sendRequest.post('${ApiConstant.AMC_COMMENTS}/$amcJobId', data: commentsData);

      return ApiResponse<AmcCommentModel>.fromJson(response.data, (data) => AmcCommentModel.fromMap(data));
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<AmcCommentModel>.error(e.response!.data);
      } else {
        return ApiResponse<AmcCommentModel>(errorMessage: Constant.something_went_wrong_please_try_again);
      }
    }
  }

  Future<ApiResponse<IssueRes>> addIssue(TaskModel task) async {
    try {
      final formData = await TaskModel().buildAmcIssueFormData(task);

      final response = await DioClient().sendRequest.post(ApiConstant.TASK_MANAGER, data: formData);
      return ApiResponse.fromJson(response.data, (data) => IssueRes.fromMap(data));
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<IssueRes>.error(e.response!.data);
      } else {
        return ApiResponse(status: false, errorMessage: Constant.something_went_wrong_please_try_again);
      }
    }
  }

  Future<ApiResponse<TaskModel>> getTask(int taskId) async {
    try {
      final response = await DioClient().sendRequest.get('${ApiConstant.TASK_MANAGER}/$taskId');
      return ApiResponse.fromJson(response.data, (data) => TaskModel.fromMap(data));
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<TaskModel>.error(e.response!.data);
      } else {
        return ApiResponse(status: false, errorMessage: Constant.something_went_wrong_please_try_again);
      }
    }
  }

  Future<ApiResponse> updateIssueStatus(int taskId, int status) async {
    try {
      final response = await DioClient().sendRequest.put('${ApiConstant.TASK_STATUS_UPDATE}/$taskId', data: {Constant.status: status});

      return ApiResponse.fromJson(response.data, ((_) {}));
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse.fromJson(e.response!.data, ((_) {}));
      } else {
        return ApiResponse(errorMessage: Constant.something_went_wrong_please_try_again);
      }
    }
  }
}
