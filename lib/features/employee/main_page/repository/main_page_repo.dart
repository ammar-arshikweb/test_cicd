import 'package:dio/dio.dart';
import 'package:panamera_app/features/employee/main_page/model/logout_model/logout_req.dart';
import 'package:panamera_app/features/employee/main_page/model/logout_model/logout_res.dart';
import 'package:panamera_app/features/login/model/emp_login_res.dart';
import 'package:panamera_app/repositories/base_api_model.dart';
import 'package:panamera_app/services/api_constant.dart';
import 'package:panamera_app/services/dio_client.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/preference.dart';

class MainPageRepo {
  Future<ApiResponse<LogoutRes>> logOut({required LogoutReq logoutReq}) async {
    try {
      final response = await DioClient().sendRequest.post(ApiConstant.LOGOUT, data: logoutReq.toMap());

      return ApiResponse<LogoutRes>.fromJson(response.data, (json) => LogoutRes.fromJson(json));
    } on DioException catch (e) {
      // If response has a valid body, still parse it
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<LogoutRes>.error(e.response!.data);
      } else {
        // Re-throw or return a default ApiResponse
        return ApiResponse<LogoutRes>(errorMessage: Constant.something_went_wrong_please_try_again, data: null, status: false);
      }
    }
  }

  Future<ApiResponse> storeFCMToken({required String fcmToken}) async {
    try {
      final response = await DioClient().sendRequest.post(
        ApiConstant.STORE_FCM_TOKEN,
        data: {Constant.fcmToken: fcmToken, if (Pref.getIsCustomer()) Constant.customerId: Pref.getCustomerId()},
      );

      return ApiResponse.fromJson(response.data, (json) => LogoutRes.fromJson(json));
    } on DioException catch (e) {
      // If response has a valid body, still parse it
      if (e.response != null && e.response?.data != null) {
        return ApiResponse.fromJson(e.response!.data, (json) => LogoutRes.fromJson(json));
      } else {
        // Re-throw or return a default ApiResponse
        return ApiResponse<LogoutRes>(errorMessage: Constant.something_went_wrong_please_try_again, data: null, status: false);
      }
    }
  }

  Future<ApiResponse> markNotificationsRead({required List<int> notificationIds}) async {
    try {
      final response = await DioClient().sendRequest.post(ApiConstant.MARK_NOTIFICATIONS_READ, data: {Constant.notificationId: notificationIds});

      return ApiResponse.fromJson(response.data, (json) => LogoutRes.fromJson(json));
    } on DioException catch (e) {
      // If response has a valid body, still parse it
      if (e.response != null && e.response?.data != null) {
        return ApiResponse.fromJson(e.response!.data, (json) => LogoutRes.fromJson(json));
      } else {
        // Re-throw or return a default ApiResponse
        return ApiResponse<LogoutRes>(errorMessage: Constant.something_went_wrong_please_try_again, data: null, status: false);
      }
    }
  }

  Future<ApiResponse<EmployeeModel>> getEmployee() async {
    try {
      final response = await DioClient().sendRequest.get('${ApiConstant.EMPLOYEE}/${Pref.getUserId()}');

      return ApiResponse<EmployeeModel>.fromJson(response.data, (json) => EmployeeModel.fromJson(json));
    } on DioException catch (e) {
      // If response has a valid body, still parse it
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<EmployeeModel>.error(e.response!.data);
      } else {
        // Re-throw or return a default ApiResponse
        return ApiResponse<EmployeeModel>(errorMessage: Constant.something_went_wrong_please_try_again, data: null, status: false);
      }
    }
  }

  Future<ApiResponse> updateEmployee(EmployeeModel emp) async {
    try {
      final response = await DioClient().sendRequest.put('${ApiConstant.EMPLOYEE}/${Pref.getUserId()}',data: emp.toJsonUpdateProfile());

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
