import 'package:flutter/material.dart';
import 'package:panamera_app/comman_widget/custom_loader.dart';
import 'package:panamera_app/features/employee/amc/model/amc_job_data_model.dart';
import 'package:panamera_app/features/employee/amc/repository/amc_repo.dart';
import 'package:panamera_app/utils/log_utils.dart';

class JobDetailViewModel extends ChangeNotifier {
  AmcJobDetail? _jobData;
  bool _isStatusChanged = false;
  final AmcRepo _amcRepo = AmcRepo();

  AmcJobDetail? get jobData => _jobData;
  bool get isStatusChanged => _isStatusChanged;

  initModel(BuildContext context, int amcJobId) async {
    _isStatusChanged = false;
    getJobDetail(context, amcJobId);
  }

  resetModel() {
    _jobData = null;
  }

  Future<void> getJobDetail(BuildContext context, int amcJobId, {bool isFirstTime = false}) async {
    try {
      if (!isFirstTime) context.showLoader();

      final apiRes = await _amcRepo.getJobDetail(amcJobId);

      if (apiRes.status != false) {
        _jobData = apiRes.data;
        Log.e('Job data fetched successfully: ${_jobData?.amcJobId}');
      } else {
        Log.e('Failed to fetch job data: ${apiRes.errorMessage}');
      }
    } catch (e) {
      Log.e('Error fetching job data: $e');
    } finally {
      context.hideLoader();
      notifyListeners();
    }
  }

  Future<void> updateJobStatus(BuildContext context, int status, bool isStartWork) async {
    try {
      context.showLoader();

      final apiRes = await _amcRepo.updateJobStatus(_jobData!.amcJobId, status, isStartWork);

      if (apiRes.status != false) {
        _isStatusChanged = true;
        await getJobDetail(context, _jobData!.amcJobId);
        Log.e('Job data fetched successfully: ${_jobData?.amcJobId}');
        notifyListeners();
      } else {
        Log.e('Failed to fetch job data: ${apiRes.errorMessage}');
      }
    } catch (e) {
      Log.e('Error fetching job data: $e');
    } finally {
      Navigator.of(context).pop();
      context.hideLoader();
    }
  }
}
