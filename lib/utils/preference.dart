import 'dart:convert';

import 'package:panamera_app/services/environment_repo.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Pref {
  static late SharedPreferences _prefs;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static void setValue(String key, String value) {
    _prefs.setString(key, value);
  }

  static String getValue(String key) {
    return _prefs.getString(key) ?? '';
  }

  static void setUpdateLaterClickedTime(String value) => _prefs.setString(Constant.updateLaterClickedTime, value);
  static String? getUpdateLaterClickedTime() => _prefs.getString(Constant.updateLaterClickedTime);

  static void setAppTracking(bool value) => _prefs.setBool(Constant.appTrackingTransparency, value);
  static bool? getAppTracking() => _prefs.getBool(Constant.appTrackingTransparency);

  static void setFcmToken(String value) => _prefs.setString(Constant.fcmToken, value);
  static String? getFcmToken() => _prefs.getString(Constant.fcmToken);

  static void setJwt(String value) => _prefs.setString(Constant.jwt, value);
  static String? getJwt() => _prefs.getString(Constant.jwt);

  static void setRefreshToken(String value) => _prefs.setString(Constant.refreshToken, value);
  static String getRefreshToken() => _prefs.getString(Constant.refreshToken) ?? '';

  static void setUserId(int value) => _prefs.setInt(Constant.userId, value);
  static int getUserId() => _prefs.getInt(Constant.userId) ?? 0;

  static void setEmpId(String value) => _prefs.setString(Constant.employeeId, value);
  static String getEmpId() => _prefs.getString(Constant.employeeId) ?? '';

  static void setUserName(String value) => _prefs.setString(Constant.userName, value);
  static String getUserName() => _prefs.getString(Constant.userName) ?? '';

  static void setEmpName(String value) => _prefs.setString(Constant.name, value);
  static String getEmpName() => _prefs.getString(Constant.name) ?? ' ';

  static void setReportingToName(String value) => _prefs.setString(Constant.reportingToName, value);
  static String getReportingToName() => _prefs.getString(Constant.reportingToName) ?? ' ';

  static void setRoleId(int value) => _prefs.setInt(Constant.roleId, value);
  static int getRoleId() => _prefs.getInt(Constant.roleId) ?? 0;

  static void setRoleOrderId(int value) => _prefs.setInt(Constant.roleOrderId, value);
  static int getRoleOrderId() => _prefs.getInt(Constant.roleOrderId) ?? 0;

  static void setGroupNumber(int value) => _prefs.setInt(Constant.groupNumber, value);
  static int getGroupNumber() => _prefs.getInt(Constant.groupNumber) ?? 0;

  static void setIsTeamLeader(bool value) => _prefs.setBool(Constant.isTeamLeader, value);
  static bool getIsTeamLeader() => _prefs.getBool(Constant.isTeamLeader) ?? false;

  static void setDepartment(String value) => _prefs.setString(Constant.department, value);
  static String getDepartment() => _prefs.getString(Constant.department) ?? ' ';

  static void setShiftUpdateTime(String value) => _prefs.setString(Constant.shiftUpdateTime, value);
  static String getShiftUpdateTime() => _prefs.getString(Constant.shiftUpdateTime) ?? '';

  static void setCustomerId(int value) => _prefs.setInt(Constant.customerId, value);
  static int getCustomerId() => _prefs.getInt(Constant.customerId) ?? 0;

  static void setCustomerName(String value) => _prefs.setString(Constant.customerName, value);
  static String getCustomerName() => _prefs.getString(Constant.customerName) ?? '';

  static void setCustomerStringId(String value) => _prefs.setString(Constant.customerStringId, value);
  static String getCustomerStringId() => _prefs.getString(Constant.customerStringId) ?? '';

  static void setCustomerEmail(String value) => _prefs.setString(Constant.email, value);
  static String getCustomerEmail() => _prefs.getString(Constant.email) ?? '';

  static void setCustomerContactNumber(String value) => _prefs.setString(Constant.contactNumber, value);
  static String getCustomerContactNumber() => _prefs.getString(Constant.contactNumber) ?? '';

  static void setCustomerEmirate(String value) => _prefs.setString(Constant.emirate, value);
  static String getCustomerEmirate() => _prefs.getString(Constant.emirate) ?? '';

  static void setIsCustomer(bool value) => _prefs.setBool(Constant.isCustomer, value);
  static bool getIsCustomer() => _prefs.getBool(Constant.isCustomer) ?? false;

  static void setEmpLoginId(String value) => _prefs.setString(Constant.empLoginId, value);
  static String getEmpLoginId() => _prefs.getString(Constant.empLoginId) ?? '';

  static void setEmpLoginPassword(String value) => _prefs.setString(Constant.empLoginPassword, value);
  static String getEmpLoginPassword() => _prefs.getString(Constant.empLoginPassword) ?? '';

  static void setCustomerLoginEmail(String value) => _prefs.setString(Constant.customerLoginEmail, value);
  static String getCustomerLoginEmail() => _prefs.getString(Constant.customerLoginEmail) ?? '';

  static void setCustomerLoginPassword(String value) => _prefs.setString(Constant.customerLoginPassword, value);
  static String getCustomerLoginPassword() => _prefs.getString(Constant.customerLoginPassword) ?? '';

  // Store a list of FunctionalityModel
  static void setFunctionality(List<String> value) {
    String userDetailsJson = jsonEncode(value);
    _prefs.setString(Constant.functionality, userDetailsJson);
  }

  // Retrieve a list of FunctionalityModel
  static List<String>? getFunctionality() {
    String? userDetailsJson = _prefs.getString(Constant.functionality);
    if (userDetailsJson == null) {
      return null;
    }
    List<dynamic> functionalityList = jsonDecode(userDetailsJson);
    return functionalityList.map((e) => e.toString()).toList();
  }

  static Future<void> setEnvironmentUrls(EnvironmentUrls urls) async {
    _prefs.setString(Constant.developmentUrl, urls.development);
    _prefs.setString(Constant.localUrl, urls.local);
  }

  static String? getDevelopmentUrl() => _prefs.getString(Constant.developmentUrl);
  static String? getLocalUrl() => _prefs.getString(Constant.localUrl);

  // Clear all preferences
  static void clearAllPreferences() {
    final empId = getEmpLoginId();
    final empPassword = getEmpLoginPassword();
    final customerEmail = getCustomerLoginEmail();
    final customerPassword = getCustomerLoginPassword();
    _prefs.clear();
    setEmpLoginId(empId);
    setEmpLoginPassword(empPassword);
    setCustomerLoginEmail(customerEmail);
    setCustomerLoginPassword(customerPassword);
  }
}
