import 'package:dio/dio.dart';
import 'package:panamera_app/repositories/base_api_model.dart';
import 'package:panamera_app/services/api_constant.dart';

class EnvironmentRepo {
  final Dio _dio = Dio();

  Future<ApiResponse<EnvironmentUrls>> getEnvironmentUrls() async {
    try {
      final response = await _dio.get(ApiConstant.ENVIRONMENT_URLS);

      // Extract data manually from the JSON structure
      final Map<String, dynamic> json = response.data;
      final List dataList = json['data'] ?? [];
      final envJson = dataList.isNotEmpty ? dataList.first['environment_urls'] : null;

      return ApiResponse<EnvironmentUrls>(
        status: json['status'] ?? false,
        successMessage: json['successMessage'],
        errorMessage: json['errorMessage'],
        data: envJson != null ? EnvironmentUrls.fromJson(envJson) : null,
      );
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<EnvironmentUrls>.error(e.response!.data);
      } else {
        return ApiResponse<EnvironmentUrls>(errorMessage: 'Failed to fetch environment URLs');
      }
    } catch (e) {
      return ApiResponse<EnvironmentUrls>(errorMessage: 'Unexpected error occurred: $e');
    }
  }
}

class EnvironmentUrls {
  final String production;
  final String development;
  final String local;

  EnvironmentUrls({required this.production, required this.development, required this.local});

  factory EnvironmentUrls.fromJson(Map<String, dynamic> json) {
    return EnvironmentUrls(
      production: json['production'] ?? '',
      development: json['development'] ?? '',
      local: json['local'] ?? '',
    );
  }
}
