import 'package:connectivity_plus/connectivity_plus.dart';

class NetUtils {
  static Future<bool> checkNetworkStatus() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return !connectivityResult.contains(ConnectivityResult.none);
    } catch (e) {
      return false;
    }
  }
}
