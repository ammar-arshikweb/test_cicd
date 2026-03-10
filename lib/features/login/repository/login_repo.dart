import 'package:dio/dio.dart';
import 'package:panamera_app/features/login/model/cst_login_req.dart';
import 'package:panamera_app/features/login/model/cst_login_res.dart';
import 'package:panamera_app/features/login/model/emp_login_req.dart';
import 'package:panamera_app/features/login/model/emp_login_res.dart';
import 'package:panamera_app/repositories/base_api_model.dart';
import 'package:panamera_app/services/api_constant.dart';
import 'package:panamera_app/services/dio_client.dart';
import 'package:panamera_app/utils/constant.dart';

class LoginRepo {
  Future<ApiResponse<EmpLoginRes>> empLogin({required EmpLoginReq loginReq}) async {
    try {
      final response = await DioClient().sendRequest.post(ApiConstant.LOGIN, data: loginReq.toMap());

      return ApiResponse<EmpLoginRes>.fromJson(response.data, (json) => EmpLoginRes.fromJson(json));
    } on DioException catch (e) {
      // If response has a valid body, still parse it
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<EmpLoginRes>.error(e.response!.data);
      } else {
        // Re-throw or return a default ApiResponse
        return ApiResponse<EmpLoginRes>(errorMessage: Constant.something_went_wrong_please_try_again, data: null, status: false);
      }
    }
  }

  Future<ApiResponse<CstLoginRes>> cstLogin({required CstLoginReq cstLoginReq}) async {
    try {
      final response = await DioClient().sendRequest.post(ApiConstant.CUSTOMER_LOGIN, data: cstLoginReq.toMap());

      return ApiResponse<CstLoginRes>.fromJson(response.data, (json) => CstLoginRes.fromJson(json));
    } on DioException catch (e) {
      // If response has a valid body, still parse it
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<CstLoginRes>.error(e.response!.data);
      } else {
        // Re-throw or return a default ApiResponse
        return ApiResponse<CstLoginRes>(errorMessage: Constant.something_went_wrong_please_try_again, data: null, status: false);
      }
    }
  }

  Future<ApiResponse> forgotPassword({required String email}) async {
    try {
      final response = await DioClient().sendRequest.post(ApiConstant.FORGOT_PASSWORD, data: {Constant.email : email});

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
