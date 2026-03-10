import 'package:dio/dio.dart';
import 'package:panamera_app/features/app_update/model/app_update_model.dart';
import 'package:panamera_app/repositories/base_api_model.dart';
import 'package:panamera_app/services/api_constant.dart';
import 'package:panamera_app/services/dio_client.dart';
import 'package:panamera_app/utils/constant.dart';

class AppUpdateRepo {
  Future<ApiResponse<AppUpdateModel>> getAppUpdate() async {
    try {
      final response = await DioClient().sendRequest.get(ApiConstant.CHECK_APP_VERSION);
      return ApiResponse.fromJson(response.data, (data) => AppUpdateModel.fromMap(data));
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<AppUpdateModel>.error(e.response!.data);
      } else {
        return ApiResponse(status: false, errorMessage: Constant.something_went_wrong_please_try_again);
      }
    }
  }
}
