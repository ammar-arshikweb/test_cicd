import 'dart:io';
import 'package:flutter/material.dart';
import 'package:panamera_app/comman_widget/custom_loader.dart';
import 'package:panamera_app/features/customer/home/model/project_model.dart';
import 'package:panamera_app/features/customer/home/repository/customer_home_repo.dart';
import 'package:panamera_app/features/login/model/cst_login_req.dart';
import 'package:panamera_app/features/login/model/emp_login_req.dart';
import 'package:panamera_app/features/login/repository/login_repo.dart';
import 'package:panamera_app/services/network_service.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/log_utils.dart';
import 'package:panamera_app/utils/preference.dart';
import 'package:panamera_app/utils/snackbar_messages.dart';

class LoginViewModel with ChangeNotifier {
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _customerEmailController;
  late TextEditingController _customerPasswordController;
  bool _isPasswordVisible = false;
  List<ProjectModel> _projectImages = [];

  int _failedAttempts = 0;
  bool _isCaptchaVerified = false;

  TextEditingController get usernameController => _usernameController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get customerEmailController => _customerEmailController;
  TextEditingController get customerPasswordController => _customerPasswordController;
  bool get isPasswordVisible => _isPasswordVisible;
  List<ProjectModel> get projectImages => _projectImages;

  bool get showCaptcha => _failedAttempts >= 3 && !_isCaptchaVerified;

  Future<void> initModel(BuildContext context) async {
    _usernameController = TextEditingController(text: Pref.getEmpLoginId());
    _passwordController = TextEditingController(text: Pref.getEmpLoginPassword());
    _customerEmailController = TextEditingController(text: Pref.getCustomerLoginEmail());
    _customerPasswordController = TextEditingController(text: Pref.getCustomerLoginPassword());
    _failedAttempts = 0;
    _isCaptchaVerified = false;
    getProjectImages(context, isFirstTime: true);
  }

  void resetModel() {
    _usernameController.clear();
    _passwordController.clear();
    _customerEmailController.clear();
    _customerPasswordController.clear();
    _failedAttempts = 0;
    _isCaptchaVerified = false;
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void captchaVerified() {
    _isCaptchaVerified = true;
    notifyListeners();
  }

  Future<void> signInButtonClick(BuildContext context,int tabIndex) async {
    if (showCaptcha) {
      SnackBarMsg.showErrorMessage(context, Helper.getLocalization()?.please_solve_the_captcha_first);
      return;
    }
    if (!NetworkStatusService().connectionStatus.value) {
      SnackBarMsg.showErrorMessage(context, Helper.getLocalization()?.you_cannot_login_in_offline_mode_please_try_again_in_online_mode);
      return;
    }

    if (tabIndex == 0) {
      await employeeLogin(context);
    } else {
      await customerLogin(context);
    }
  }

  Future<void> employeeLogin(BuildContext context) async {
    String userName = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (userName.isEmpty || password.isEmpty) {
      SnackBarMsg.showErrorMessage(context, Helper.getLocalization()?.please_fill_all_fields);
      return;
    }

    EmpLoginReq loginReq = EmpLoginReq(userName: userName, password: password);

    try {
      context.showLoader();
      final apiRes = await LoginRepo().empLogin(loginReq: loginReq);

      if (!context.mounted) {
        Log.e('Context is not mounted');
        return;
      }

      if (apiRes.successMessage != null && context.mounted) {
        if (apiRes.data != null) {
          final keys = apiRes.data?.employeeData.functionalityKeys;

          if (!(keys?.contains(Constant.MOBILE_LOGIN) ?? false)) {
            SnackBarMsg.showErrorMessage(context, Helper.getLocalization()?.you_are_not_authorized);
            return;
          }

          //  Success → Reset attempts & captcha
          _failedAttempts = 0;
          _isCaptchaVerified = false;

          SnackBarMsg.showSuccessMessage(context, apiRes.successMessage);
          Pref.setEmpLoginId(userName);
          Pref.setEmpLoginPassword(password);
          Pref.setJwt(apiRes.data!.jwt);
          Pref.setRefreshToken(apiRes.data!.refreshToken);
          Pref.setUserId(apiRes.data!.employeeData.id!);
          Pref.setEmpId(apiRes.data!.employeeData.employeeId!);
          Pref.setUserName(apiRes.data!.employeeData.userName!);
          Pref.setEmpName(apiRes.data!.employeeData.fullName!);
          Pref.setReportingToName(apiRes.data!.employeeData.reportingToName!);
          Pref.setRoleId(apiRes.data!.employeeData.roleId!);
          Pref.setRoleOrderId(apiRes.data!.employeeData.roleOrderId!);
          Pref.setGroupNumber(apiRes.data!.employeeData.groupNumber!);
          Pref.setDepartment(apiRes.data!.employeeData.department!);
          Pref.setShiftUpdateTime(apiRes.data!.employeeData.shiftUpdateTime ?? '');
          Pref.setIsTeamLeader(apiRes.data!.employeeData.isTeamLeader ?? false);
          Pref.setFunctionality(keys ?? []);
          Pref.setIsCustomer(false);
          Navigator.pushReplacementNamed(context, Constant.mainPage);
          // if (Platform.isIOS) {
          //   await AppTrackTransparency.requestTrackingAfterLogin();
          // }
        }
      } else {
        // Failed login → increase attempts
        _failedAttempts++;
        if (_failedAttempts >= 3) {
          _isCaptchaVerified = false;
        }

        SnackBarMsg.showErrorMessage(context, apiRes.errorMessage!);
      }
    } catch (e) {
      Log.e('Error during login: $e');
      SnackBarMsg.showError(context);
    } finally {
      context.hideLoader();
      notifyListeners();
    }
  }

  Future<void> customerLogin(BuildContext context) async {
    String email = _customerEmailController.text.trim();
    String password = _customerPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      SnackBarMsg.showErrorMessage(context, Helper.getLocalization()?.please_fill_all_fields);
      return;
    }

    CstLoginReq cstLoginReq = CstLoginReq(emailId: email, password: password);

    try {
      context.showLoader();
      final apiRes = await LoginRepo().cstLogin(cstLoginReq: cstLoginReq);

      if (!context.mounted) {
        Log.e('Context is not mounted');
        return;
      }

      if (apiRes.successMessage != null && context.mounted) {
        if (apiRes.data != null) {
          //  Success → Reset attempts & captcha
          _failedAttempts = 0;
          _isCaptchaVerified = false;

          SnackBarMsg.showSuccessMessage(context, apiRes.successMessage);
          Pref.setCustomerLoginEmail(email);
          Pref.setCustomerLoginPassword(password);
          Pref.setJwt(apiRes.data!.jwt);
          Pref.setRefreshToken(apiRes.data!.refreshToken);
          Pref.setCustomerId(apiRes.data!.customerData.id!);
          Pref.setCustomerStringId(apiRes.data!.customerData.customerId!);
          Pref.setCustomerName(apiRes.data!.customerData.customerName!);
          Pref.setCustomerEmail(apiRes.data!.customerData.email!);
          Pref.setCustomerContactNumber(apiRes.data!.customerData.contactNumber!);
          Pref.setCustomerEmirate(apiRes.data!.customerData.emirate!);
          Pref.setIsCustomer(true);
          Navigator.pushReplacementNamed(context, Constant.customerMainPage);
          // if (Platform.isIOS) {
          //   await AppTrackTransparency.requestTrackingAfterLogin();
          // }
        }
      } else {
        // Failed login → increase attempts
        _failedAttempts++;
        if (_failedAttempts >= 3) {
          _isCaptchaVerified = false;
        }

        SnackBarMsg.showErrorMessage(context, apiRes.errorMessage!);
      }
    } catch (e) {
      Log.e('Error during login: $e');
      SnackBarMsg.showError(context);
    } finally {
      context.hideLoader();
      notifyListeners();
    }
  }

  getProjectImages(BuildContext context, {bool isFirstTime = false}) async {
    try {
      if (!isFirstTime) context.showLoader();
      final apiRes = await CustomerHomeRepo().getProjectImages();
      if (apiRes.successMessage != null && apiRes.data != null) {
        _projectImages = apiRes.data!;
      }
    } catch (e) {
      Log.e("Error in getProjectImages: $e");
      SnackBarMsg.showError(context);
    } finally {
      context.hideLoader();
      notifyListeners();
    }
  }
}
