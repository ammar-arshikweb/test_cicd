import 'package:flutter/material.dart';
import 'package:panamera_app/comman_widget/custom_loader.dart';
import 'package:panamera_app/features/customer/home/model/customer_model.dart';
import 'package:panamera_app/features/customer/home/model/project_model.dart';
import 'package:panamera_app/features/customer/home/repository/customer_home_repo.dart';
import 'package:panamera_app/services/network_service.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/log_utils.dart';
import 'package:panamera_app/utils/snackbar_messages.dart';

class CustomerHomeViewModel extends ChangeNotifier {
  List<VillaModel> _villaList = [];
  List<ProjectModel> _projectImages = [];

  List<VillaModel> get villaList => _villaList;
  List<ProjectModel> get projectImages => _projectImages;

  initModel(BuildContext context) {
    getCustomerDetails(context, isFirstTime: true);
    getProjectImages(context, isFirstTime: true);
  }

  resetModel() {
    _villaList.clear();
  }

  getCustomerDetails(BuildContext context, {bool isFirstTime = false}) async {
    if (!NetworkStatusService().connectionStatus.value) {
      SnackBarMsg.showErrorMessage(context, Helper.getLocalization()?.no_internet_connection);
      return;
    }
    try {
      if (!isFirstTime) context.showLoader();
      final apiRes = await CustomerHomeRepo().getCustomerDetail();
      if (apiRes.successMessage != null && apiRes.data != null) {
        _villaList = apiRes.data!.villaList!;
      }
    } catch (e) {
      Log.e("Error in getCustomerDetails: $e");
      SnackBarMsg.showError(context);
    } finally {
      context.hideLoader();
      notifyListeners();
    }
  }

  getProjectImages(BuildContext context, {bool isFirstTime = false}) async {
    if (!NetworkStatusService().connectionStatus.value) {
      SnackBarMsg.showErrorMessage(context, Helper.getLocalization()?.no_internet_connection);
      return;
    }
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
