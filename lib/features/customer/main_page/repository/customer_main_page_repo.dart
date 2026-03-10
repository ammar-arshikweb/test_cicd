import 'package:dio/dio.dart';
import 'package:panamera_app/features/customer/home/model/customer_model.dart';
import 'package:panamera_app/features/employee/main_page/model/logout_model/logout_req.dart';
import 'package:panamera_app/features/employee/main_page/model/logout_model/logout_res.dart';
import 'package:panamera_app/repositories/base_api_model.dart';
import 'package:panamera_app/services/api_constant.dart';
import 'package:panamera_app/services/dio_client.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/preference.dart';

class CustomerMainPageRepo {
  Future<ApiResponse<LogoutRes>> logOut({required LogoutReq logoutReq}) async {
    try {
      final response = await DioClient().sendRequest.post(ApiConstant.CUSTOMER_LOGOUT, data: logoutReq.toMap());

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

  Future<ApiResponse> customerStoreFCMToken({required String fcmToken}) async {
    try {
      final response = await DioClient().sendRequest.post(ApiConstant.CUSTOMER_STORE_FCM_TOKEN, data: {Constant.fcmToken: fcmToken});

      return ApiResponse.fromJson(response.data, ((_) {}));
    } on DioException catch (e) {
      // If response has a valid body, still parse it
      if (e.response != null && e.response?.data != null) {
        return ApiResponse.fromJson(e.response?.data, ((_) {}));
      } else {
        // Re-throw or return a default ApiResponse
        return ApiResponse(status: false, errorMessage: Constant.something_went_wrong_please_try_again);
      }
    }
  }

  Future<ApiResponse<CustomerModel>> updateCustomer(CustomerModel customerData) async {
    try {
      final FormData formData = customerData.buildCustomerFormData(customerData);
      final response = await DioClient().sendRequest.put('${ApiConstant.CUSTOMER}/${Pref.getCustomerId()}', data: formData);

      return ApiResponse.fromJson(response.data, (json) => CustomerModel.fromMap(json));
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<CustomerModel>.error(e.response!.data);
      } else {
        return ApiResponse(errorMessage: Constant.something_went_wrong_please_try_again);
      }
    }
  }
}
