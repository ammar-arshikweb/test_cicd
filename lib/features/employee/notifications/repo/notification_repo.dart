import 'package:dio/dio.dart';
import 'package:panamera_app/features/employee/notifications/model/notification_model.dart';
import 'package:panamera_app/repositories/base_api_model.dart';
import 'package:panamera_app/services/api_constant.dart';
import 'package:panamera_app/services/dio_client.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/preference.dart';

class NotificationRepo {
  Future<ApiResponse<List<NotificationModel>>> getNotifications(bool isCustomer) async {
    try {
      final response = await DioClient().sendRequest.get(
        ApiConstant.NOTIFICATIONS,
        queryParameters: {if (isCustomer) Constant.customerId: Pref.getCustomerStringId()},
      );
      final List<dynamic> jsonList = response.data[Constant.data] ?? [];
      final items = jsonList.map((e) => NotificationModel.fromJson(e)).toList();

      return ApiResponse<List<NotificationModel>>(successMessage: response.data[Constant.successMessage], data: items);
    } on DioException catch (e) {
      if (e.response?.data != null) {
        return ApiResponse<List<NotificationModel>>.fromJson(e.response!.data, (_) => []);
      } else {
        return ApiResponse<List<NotificationModel>>(errorMessage: Constant.something_went_wrong_please_try_again, status: false);
      }
    }
  }
}
