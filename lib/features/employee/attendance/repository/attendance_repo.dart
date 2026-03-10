import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:panamera_app/features/employee/attendance/model/attendance_model/attendance_model.dart';
import 'package:panamera_app/features/employee/attendance/model/break_in_model/break_in_req.dart';
import 'package:panamera_app/features/employee/attendance/model/break_in_model/break_in_res.dart';
import 'package:panamera_app/features/employee/attendance/model/break_out_model/break_out_req.dart';
import 'package:panamera_app/features/employee/attendance/model/break_out_model/break_out_res.dart';
import 'package:panamera_app/features/employee/attendance/model/clock_in_model/clock_in_req.dart';
import 'package:panamera_app/features/employee/attendance/model/clock_in_model/clock_in_res.dart';
import 'package:panamera_app/features/employee/attendance/model/clock_in_out_status_model/clock_in_out_status_req.dart';
import 'package:panamera_app/features/employee/attendance/model/clock_in_out_status_model/clock_in_out_status_res.dart';
import 'package:panamera_app/features/employee/attendance/model/clock_out_model/clock_out_req.dart';
import 'package:panamera_app/features/employee/attendance/model/clock_out_model/clock_out_res.dart';
import 'package:panamera_app/features/employee/attendance/model/early_leave_model/early_leave_req.dart';
import 'package:panamera_app/features/employee/attendance/model/early_leave_model/early_leave_res.dart';
import 'package:panamera_app/features/employee/attendance/model/emergency_check_in_out_status.dart';
import 'package:panamera_app/features/employee/attendance/model/erarly_leave_status/early_leave_status_req.dart';
import 'package:panamera_app/features/employee/attendance/model/erarly_leave_status/early_leave_status_res.dart';
import 'package:panamera_app/features/employee/attendance/model/leave_model.dart';
import 'package:panamera_app/features/employee/attendance/model/overtime_details_model/overtime_details_res.dart';
import 'package:panamera_app/features/employee/attendance/model/overtime_status/overtime_status_req.dart';
import 'package:panamera_app/features/employee/attendance/model/overtime_status/overtime_status_res.dart';
import 'package:panamera_app/repositories/base_api_model.dart';
import 'package:panamera_app/services/api_constant.dart';
import 'package:panamera_app/services/dio_client.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/preference.dart';

class AttendanceRepo {
  Future<ApiResponse<ClockInRes>> clockIn({required ClockInReq clockInReq, bool isOfflineData = false}) async {
    try {
      final response = await DioClient().sendRequest.post(ApiConstant.CLOCK_IN, data: clockInReq.toMap(isOfflineData: isOfflineData));

      return ApiResponse<ClockInRes>.fromJson(response.data, (json) => ClockInRes.fromMap(json));
    } on DioException catch (e) {
      // If response has a valid body, still parse it
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<ClockInRes>.error(e.response!.data);
      } else {
        // Re-throw or return a default ApiResponse
        return ApiResponse<ClockInRes>(errorMessage: Constant.something_went_wrong_please_try_again, data: null, status: false);
      }
    }
  }

  Future<ApiResponse<ClockOutRes>> clockOut({required ClockOutReq clockOutReq, bool isOfflineData = false}) async {
    try {
      final response = await DioClient().sendRequest.post(ApiConstant.CLOCK_OUT, data: clockOutReq.toMap(isOfflineData: isOfflineData));

      return ApiResponse<ClockOutRes>.fromJson(response.data, (json) => ClockOutRes.fromMap(json));
    } on DioException catch (e) {
      // If response has a valid body, still parse it
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<ClockOutRes>.error(e.response!.data);
      } else {
        // Re-throw or return a default ApiResponse
        return ApiResponse<ClockOutRes>(errorMessage: Constant.something_went_wrong_please_try_again, data: null, status: false);
      }
    }
  }

  Future<ApiResponse<BreakInRes>> breakIn({required BreakInReq breakInReq, bool isOfflineData = false}) async {
    try {
      final response = await DioClient().sendRequest.post(ApiConstant.BREAK_IN, data: breakInReq.toMap());

      return ApiResponse<BreakInRes>.fromJson(response.data, (json) => BreakInRes.fromMap(json));
    } on DioException catch (e) {
      // If response has a valid body, still parse it
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<BreakInRes>.error(e.response!.data);
      } else {
        // Re-throw or return a default ApiResponse
        return ApiResponse<BreakInRes>(errorMessage: Constant.something_went_wrong_please_try_again, data: null, status: false);
      }
    }
  }

  Future<ApiResponse<BreakOutRes>> breakOut({required BreakOutReq breakOutReq, bool isOfflineData = false}) async {
    try {
      final response = await DioClient().sendRequest.post(ApiConstant.BREAK_OUT, data: breakOutReq.toMap());

      return ApiResponse<BreakOutRes>.fromJson(response.data, (json) => BreakOutRes.fromMap(json));
    } on DioException catch (e) {
      // If response has a valid body, still parse it
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<BreakOutRes>.error(e.response!.data);
      } else {
        // Re-throw or return a default ApiResponse
        return ApiResponse<BreakOutRes>(errorMessage: Constant.something_went_wrong_please_try_again, data: null, status: false);
      }
    }
  }

  Future<ApiResponse<ClockInOutStatusRes>> clockInOutStatus({required ClockInOutStatusReq clockInOutStatusReq}) async {
    try {
      final response = await DioClient().sendRequest.get(ApiConstant.CLOCK_IN_OUT_STATUS, data: clockInOutStatusReq.toMap());

      return ApiResponse<ClockInOutStatusRes>.fromJson(response.data, (json) => ClockInOutStatusRes.fromMap(json));
    } on DioException catch (e) {
      // If response has a valid body, still parse it
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<ClockInOutStatusRes>.error(e.response!.data);
      } else {
        // Re-throw or return a default ApiResponse
        return ApiResponse<ClockInOutStatusRes>(errorMessage: Constant.something_went_wrong_please_try_again, data: null, status: false);
      }
    }
  }

  Future<ApiResponse<OvertimeDetailsRes>> uploadOvertimeDetails({required dynamic overtimeDetailsReq}) async {
    try {
      final response = await DioClient().sendRequest.post(ApiConstant.UPLOAD_OVERTIME_DETAILS, data: overtimeDetailsReq);

      return ApiResponse<OvertimeDetailsRes>.fromJson(response.data, (json) => OvertimeDetailsRes.fromMap(json));
    } on DioException catch (e) {
      // If response has a valid body, still parse it
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<OvertimeDetailsRes>.error(e.response!.data);
      } else {
        // Re-throw or return a default ApiResponse
        return ApiResponse<OvertimeDetailsRes>(errorMessage: Constant.something_went_wrong_please_try_again, data: null, status: false);
      }
    }
  }

  Future<ApiResponse<OvertimeStatusRes>> uploadOvertimeStatus({required OvertimeStatusReq overtimeStatusReq}) async {
    try {
      final response = await DioClient().sendRequest.post(ApiConstant.UPLOAD_OVERTIME_STATUS, data: overtimeStatusReq.toMap());

      return ApiResponse<OvertimeStatusRes>.fromJson(response.data, (json) => OvertimeStatusRes.fromMap(json));
    } on DioException catch (e) {
      // If response has a valid body, still parse it
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<OvertimeStatusRes>.error(e.response!.data);
      } else {
        // Re-throw or return a default ApiResponse
        return ApiResponse<OvertimeStatusRes>(errorMessage: Constant.something_went_wrong_please_try_again, data: null, status: false);
      }
    }
  }

  Future<ApiResponse<EarlyLeaveStatusRes>> uploadEarlyLeaveStatus({required EarlyLeaveStatusReq earlyLeaveStatusReq}) async {
    try {
      final response = await DioClient().sendRequest.post(ApiConstant.UPLOAD_EARLY_REASON_STATUS, data: earlyLeaveStatusReq.toMap());

      return ApiResponse<EarlyLeaveStatusRes>.fromJson(response.data, (json) => EarlyLeaveStatusRes.fromMap(json));
    } on DioException catch (e) {
      // If response has a valid body, still parse it
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<EarlyLeaveStatusRes>.error(e.response!.data);
      } else {
        // Re-throw or return a default ApiResponse
        return ApiResponse<EarlyLeaveStatusRes>(errorMessage: Constant.something_went_wrong_please_try_again, data: null, status: false);
      }
    }
  }

  Future<ApiResponse<PaginatedData<AttendanceModel>>> getAttendance({
    int page = 1,
    int pageSize = Constant.paginationPageSize,
    DateTimeRange? dateRange,
    int? reportingToId,
  }) async {
    try {
      final response = await DioClient().sendRequest.get(
        ApiConstant.ATTENDANCE_LIST,
        queryParameters: {
          Constant.filterByReportingToId: reportingToId ?? Pref.getUserId(),
          Constant.startDate: DateFormat(Constant.yyyy_MM_dd).format(dateRange!.start),
          Constant.endDate: DateFormat(Constant.yyyy_MM_dd).format(dateRange.end),
          Constant.page: page,
          Constant.pageSize: Constant.paginationPageSize,
        },
      );

      return ApiResponse<PaginatedData<AttendanceModel>>.fromJson(
        response.data,
        (data) => PaginatedData<AttendanceModel>.fromJson(data, (e) => AttendanceModel.fromMap(e)),
      );
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<PaginatedData<AttendanceModel>>.error(e.response!.data);
      } else {
        return ApiResponse<PaginatedData<AttendanceModel>>(errorMessage: Constant.something_went_wrong_please_try_again, status: false);
      }
    }
  }

  Future<ApiResponse<EarlyLeaveRes>> earlyLeaveReason({required EarlyLeaveReq earlyLeaveReq, bool isOfflineData = false}) async {
    try {
      final response = await DioClient().sendRequest.post(ApiConstant.EARLY_LEAVE_REASON, data: earlyLeaveReq.toMap());

      return ApiResponse<EarlyLeaveRes>.fromJson(response.data, (json) => EarlyLeaveRes.fromMap(json));
    } on DioException catch (e) {
      // If response has a valid body, still parse it
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<EarlyLeaveRes>.error(e.response!.data);
      } else {
        // Re-throw or return a default ApiResponse
        return ApiResponse<EarlyLeaveRes>(errorMessage: Constant.something_went_wrong_please_try_again, data: null, status: false);
      }
    }
  }

  Future<ApiResponse> emergencyClockIn({required ClockInReq clockInReq, bool isOfflineData = false}) async {
    try {
      final response = await DioClient().sendRequest.post(ApiConstant.EMERGENCY_CLOCK_IN, data: clockInReq.toMap(isOfflineData: isOfflineData));

      return ApiResponse.fromJson(response.data, ((_) {}));
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse.fromJson(e.response!.data, (_) {});
      } else {
        return ApiResponse(status: false, errorMessage: Constant.something_went_wrong_please_try_again);
      }
    }
  }

  Future<ApiResponse<EmergencyClockOutRes>> emergencyClockOut({required ClockOutReq clockOutReq, bool isOfflineData = false}) async {
    try {
      final response = await DioClient().sendRequest.post(ApiConstant.EMERGENCY_CLOCK_OUT, data: clockOutReq.toMap(isOfflineData: isOfflineData));

      return ApiResponse<EmergencyClockOutRes>.fromJson(response.data, (json) => EmergencyClockOutRes.fromMap(json));
    } on DioException catch (e) {
      // If response has a valid body, still parse it
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<EmergencyClockOutRes>.error(e.response!.data);
      } else {
        // Re-throw or return a default ApiResponse
        return ApiResponse<EmergencyClockOutRes>(errorMessage: Constant.something_went_wrong_please_try_again, data: null, status: false);
      }
    }
  }

  Future<ApiResponse<EmergencyCheckInOutStatus>> emergencyClockInOutStatus({required ClockInOutStatusReq clockInOutStatusReq}) async {
    try {
      final response = await DioClient().sendRequest.get(ApiConstant.EMERGENCY_CLOCK_IN_OUT_STATUS, data: clockInOutStatusReq.toMap());

      return ApiResponse<EmergencyCheckInOutStatus>.fromJson(response.data, (json) => EmergencyCheckInOutStatus.fromMap(json));
    } on DioException catch (e) {
      // If response has a valid body, still parse it
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<EmergencyCheckInOutStatus>.error(e.response!.data);
      } else {
        // Re-throw or return a default ApiResponse
        return ApiResponse<EmergencyCheckInOutStatus>(errorMessage: Constant.something_went_wrong_please_try_again, data: null, status: false);
      }
    }
  }

  Future<ApiResponse> uploadEmergencyDetails({required dynamic emergencyDetailsReq}) async {
    try {
      final response = await DioClient().sendRequest.post(ApiConstant.EMERGENCY_MEDIA_UPLOAD, data: emergencyDetailsReq);

      return ApiResponse.fromJson(response.data, ((_) {}));
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse.fromJson(e.response!.data, (_) {});
      } else {
        return ApiResponse(status: false, errorMessage: Constant.something_went_wrong_please_try_again);
      }
    }
  }

  Future<ApiResponse<PaginatedData<LeaveModel>>> getLeaveApplications({
    int page = 1,
    int pageSize = Constant.paginationPageSize,
    required int activeIndex,
  }) async {
    try {
      final response = await DioClient().sendRequest.get(
        ApiConstant.LEAVE_APPLICATION,
        queryParameters: {
          Constant.page: page,
          Constant.pageSize: Constant.paginationPageSize,
          activeIndex == 0 ? Constant.employeeId : Constant.filterByReportingToId: Pref.getUserId(),
        },
      );

      return ApiResponse<PaginatedData<LeaveModel>>.fromJson(
        response.data,
        (data) => PaginatedData<LeaveModel>.fromJson(data, (e) => LeaveModel.fromMap(e)),
      );
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<PaginatedData<LeaveModel>>.error(e.response!.data);
      } else {
        return ApiResponse<PaginatedData<LeaveModel>>(errorMessage: Constant.something_went_wrong_please_try_again, status: false);
      }
    }
  }

  Future<ApiResponse> uploadLeaveApplication({required dynamic leaveDetailsReq}) async {
    try {
      final response = await DioClient().sendRequest.post(ApiConstant.LEAVE_APPLICATION, data: leaveDetailsReq);

      return ApiResponse.fromJson(response.data, ((_) {}));
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse.fromJson(e.response!.data, (_) {});
      } else {
        return ApiResponse(status: false, errorMessage: Constant.something_went_wrong_please_try_again);
      }
    }
  }

  Future<ApiResponse> uploadPendingCertificate({required int leaveId, required dynamic leaveDetailsReq}) async {
    try {
      final response = await DioClient().sendRequest.put('${ApiConstant.LEAVE_APPLICATION}/$leaveId', data: leaveDetailsReq);

      return ApiResponse.fromJson(response.data, ((_) {}));
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse.fromJson(e.response!.data, (_) {});
      } else {
        return ApiResponse(status: false, errorMessage: Constant.something_went_wrong_please_try_again);
      }
    }
  }

  Future<ApiResponse> updateLeaveStatus({required int leaveId, required int status}) async {
    try {
      final response = await DioClient().sendRequest.put('${ApiConstant.LEAVE_APPLICATION}/$leaveId', data: {Constant.leaveStatus:status});

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
