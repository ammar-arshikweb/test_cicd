import 'package:flutter/material.dart';
import 'package:panamera_app/comman_widget/custom_loader.dart';
import 'package:panamera_app/features/employee/amc/model/amc_model.dart';
import 'package:panamera_app/features/employee/amc/repository/amc_repo.dart';
import 'package:panamera_app/services/network_service.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/log_utils.dart';
import 'package:panamera_app/utils/snackbar_messages.dart';

class AmcViewModel extends ChangeNotifier {
  final List<AmcJob> _jobList = [];
  int _currentPage = 1;
  int _totalPages = 1;

  List<AmcJob> get jobList => _jobList;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  initModel(BuildContext context) async {
    getJobs(context,isFirstTime: true);
  }

  resetModel() {
    _jobList.clear();
    _currentPage = 1;
    _totalPages = 1;
  }

  void goToNextPage(BuildContext context) {
    if (_currentPage < _totalPages) {
      _currentPage++;
      getJobs(context);
    }
  }

  void goToPrevPage(BuildContext context) {
    if (_currentPage > 1) {
      _currentPage--;
      getJobs(context);
    }
  }

  Future<void> getJobs(BuildContext context,{bool isFirstTime = false}) async {
    if (!NetworkStatusService().connectionStatus.value) {
      SnackBarMsg.showErrorMessage(context, Helper.getLocalization()?.no_internet_connection);
      return;
    }

    if (!isFirstTime) context.showLoader();
    try {
      final apiRes = await AmcRepo().getAmcJobs(page: _currentPage);

      if (!context.mounted) {
        Log.e('Context is not mounted');
        return;
      }

      if (apiRes.data != null && apiRes.status!) {
        _jobList
          ..clear()
          ..addAll(apiRes.data!.results);
        _totalPages = apiRes.data!.pagination.totalPages;
        Log.d('Fetched ${_jobList.length} jobs');
      } else {
        SnackBarMsg.showErrorMessage(context, apiRes.errorMessage ?? Helper.getLocalization()!.error_occurred_try_again);
      }
    } catch (e) {
      Log.e('Error while fetching jobs: $e');
      SnackBarMsg.showError(context);
    } finally {
      context.hideLoader(); // Always hide loader
      notifyListeners();
    }
  }
}
