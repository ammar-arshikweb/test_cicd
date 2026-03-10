import 'package:dio/dio.dart';
import 'package:panamera_app/app_initializer.dart';
import 'package:panamera_app/comman_widget/custom_loader.dart';
import 'package:panamera_app/features/employee/main_page/model/auth_refresh_res.dart';
import 'package:panamera_app/main.dart';
import 'package:panamera_app/services/api_constant.dart';
import 'package:panamera_app/services/database_service.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/log_utils.dart';
import 'package:panamera_app/utils/preference.dart';

class DioClient {
  late final Dio _dio;
  static const int timeout = 60 * 1000;
  bool _isRefreshing = false;
  final List<Function()> _retryQueue = [];

  DioClient({Dio? dio}) {
    _dio =
        dio ?? Dio()
          ..options = BaseOptions(
            receiveTimeout: const Duration(milliseconds: timeout),
            connectTimeout: const Duration(milliseconds: timeout),
            sendTimeout: const Duration(milliseconds: timeout),
            validateStatus: (status) => status != null && (status >= 200 && status < 300),
            baseUrl:
                isLive
                    ? ApiConstant.BASEURL_LIVE
                    : isDev
                    ? Pref.getDevelopmentUrl() ?? ApiConstant.BASEURL_DEV
                    : Pref.getLocalUrl() ?? ApiConstant.BASEURL_LOCAL,
          )
          ..interceptors.add(_interceptor());
  }

  // Add a single interceptor for logging, token management, and response time tracking.
  InterceptorsWrapper _interceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        addAuthorizationHeader(options);
        options.extra['startTime'] = DateTime.now();
        handler.next(options);
      },
      onResponse: (response, handler) {
        final startTime = response.requestOptions.extra['startTime'] as DateTime?;
        if (startTime != null) {
          final duration = DateTime.now().difference(startTime);
          final dataSizeMB = (response.data.toString().length / 1048576).toStringAsFixed(2);
          Log.d('${response.statusCode} ${response.requestOptions.uri} took ${duration.inMilliseconds}ms with $dataSizeMB MB');
        }
        Log.w('Response Data from ${response.requestOptions.uri}: ${response.data}');
        handler.next(response);
      },
      onError: (DioException error, handler) async {
        if (error.requestOptions.path.contains(ApiConstant.LOGIN) || error.requestOptions.path.contains(ApiConstant.CUSTOMER_LOGIN)) {
          handleError(error);
          handler.next(error);
          return;
        }

        if (error.response?.statusCode == Constant.response_401) {
          final requestOptions = error.requestOptions;

          // Queue the request while refreshing token
          retry() async {
            final newAccessToken = Pref.getJwt();
            requestOptions.headers[Constant.Authorization] = '${Constant.Bearer} $newAccessToken';
            try {
              final response = await _dio.fetch(requestOptions);
              handler.resolve(response);
            } catch (e) {
              handler.reject(error);
            }
          }

          _retryQueue.add(retry);

          if (!_isRefreshing) {
            _isRefreshing = true;
            final refreshed = await _refreshToken();
            _isRefreshing = false;

            if (refreshed) {
              for (final retryFunc in _retryQueue) {
                await retryFunc();
              }
            } else {
              Log.e('Refresh token failed or unauthorized. Logging out user.');
              logoutUser(); // Handle application logout
            }

            _retryQueue.clear();
          }
        } else {
          handleError(error);
          handler.next(error);
        }
      },
    );
  }

  void addAuthorizationHeader(RequestOptions options) {
    const excludedEndpoints = {
      ApiConstant.LOGIN,
      ApiConstant.CUSTOMER_LOGIN,
      ApiConstant.FORGOT_PASSWORD,
      ApiConstant.REFRESH,
      ApiConstant.PROJECT_IMAGES,
      ApiConstant.CHECK_APP_VERSION,
    };
    if (!excludedEndpoints.any((endpoint) => options.path.contains(endpoint))) {
      options.headers[Constant.Authorization] = '${Constant.Bearer} ${Pref.getJwt()}';
    }

    options.headers[Constant.xDeviceType] = Constant.Mobile;
    options.headers[Constant.xAppVersion] = '${AppInitializer.packageInfo?.version}.${AppInitializer.packageInfo?.buildNumber}';
    options.headers[Constant.xMacId] = AppInitializer.osInfo;

    Log.w('Request: ${options.method} ${options.uri}');
    Log.w('Headers: ${options.headers}');
    Log.w('Request Body: ${options.data}');
    if (options.data is FormData) {
      final formData = options.data as FormData;
      final fields = formData.fields.map((e) => "${e.key}: ${e.value}").join(", ");
      final files = formData.files.map((e) => e.key).join(", ");

      Log.w("Request Body (FormData): Fields=[$fields], Files=[$files]");
    } else {
      Log.w("Request Body: ${options.data}");
    }

    Log.w('Query Parameters: ${options.queryParameters}');
  }

  void handleError(DioException error) {
    Log.e('Dio Error: ${error.message}');
    Log.e('Response Data: ${error.response?.data}');
  }

  Future<bool> _refreshToken() async {
    final refreshToken = Pref.getRefreshToken();
    if (refreshToken.isEmpty) return false;

    try {
      final response = await _dio.post(
        ApiConstant.REFRESH,
        data: {Constant.refreshToken: refreshToken},
        options: Options(validateStatus: (_) => true),
      );

      if (response.statusCode == Constant.response_200) {
        final responseData = AuthRefreshRes.fromMap(response.data);
        Pref.setJwt(responseData.jwt!);
        Pref.setRefreshToken(responseData.refreshToken!);

        Log.i('Token refreshed successfully.');
        return true;
      } else if (response.statusCode == Constant.response_401) {
        Log.e('Refresh token expired (401). Logging out.');
        return false;
      } else {
        Log.e('Token refresh failed: ${response.statusCode} ${response.data}');
        return false;
      }
    } catch (e) {
      Log.e('Token refresh error: $e');
      return false;
    }
  }

  Future<void> logoutUser() async {
    await DatabaseService.clearAllDatabaseEntries();
    Pref.clearAllPreferences(); // Clear all user-related data
    Log.w('User has been logged out due to token expiration.');
    navigatorKey.currentState?.context.hideLoader();
    // Redirect to login screen and remove all previous routes
    navigatorKey.currentState?.pushNamedAndRemoveUntil(Constant.loginScreen, (route) => false);
  }

  Dio get sendRequest => _dio;
}
