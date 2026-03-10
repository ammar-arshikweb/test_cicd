import 'dart:async';
import 'package:flutter/material.dart';
import 'package:panamera_app/comman_widget/custom_loader.dart';
import 'package:panamera_app/features/employee/attendance/model/early_leave_model/early_leave_req.dart';
import 'package:panamera_app/features/employee/attendance/model/erarly_leave_status/early_leave_status_req.dart';
import 'package:panamera_app/features/employee/attendance/repository/attendance_repo.dart';
import 'package:panamera_app/features/employee/attendance/view_model/attendance_view_model.dart';
import 'package:panamera_app/services/database_service.dart';
import 'package:panamera_app/services/network_service.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/log_utils.dart';
import 'package:panamera_app/utils/snackbar_messages.dart';
import 'package:provider/provider.dart';

class EarlyLeaveDialogViewModel extends ChangeNotifier {
  late int _attendanceId;
  int? clockOutId;
  final TextEditingController _reasonController = TextEditingController();

  TextEditingController get reasonController => _reasonController;

  initModel(int attendanceId, int? clockOut, String? reasonText) async {
    clockOutId = clockOut;
    _attendanceId = attendanceId;
    if (reasonText != null) {
      _reasonController.text = reasonText;
    }
  }

  void resetModel() {
    _reasonController.clear();
  }

  Future<void> uploadEarlyLeaveData(BuildContext context) async {
    try {
      context.showLoader();

      if (_reasonController.text.trim().isEmpty) {
        SnackBarMsg.showErrorMessage(context, Helper.getLocalization()!.please_fill_all_fields);
        return;
      }

      if (!NetworkStatusService().connectionStatus.value) {
        if (clockOutId == null) {
          SnackBarMsg.showErrorMessage(context, Helper.getLocalization()!.clock_out_not_found);
          return;
        }

        await DatabaseService.addEarlyReason(clockOutId: clockOutId!, earlyReason: _reasonController.text.trim());
        SnackBarMsg.showSuccessMessage(context, Helper.getLocalization()!.early_reason_request_saved);
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        return;
      }

      EarlyLeaveReq earlyLeaveReq = EarlyLeaveReq(attendanceRecordId: _attendanceId, earlyReason: _reasonController.text.trim());

      final apiRes = await AttendanceRepo().earlyLeaveReason(earlyLeaveReq: earlyLeaveReq);

      if (apiRes.successMessage != null && context.mounted) {
        SnackBarMsg.showSuccessMessage(context, apiRes.successMessage);

        if (apiRes.data == null) {
          Log.e('apiRes.data is null');
          SnackBarMsg.showError(context);
        } else {
          Navigator.of(context).pop();
        }
      } else {
        SnackBarMsg.showErrorMessage(context, apiRes.errorMessage!);
      }
    } catch (e) {
      Log.e('Error uploading overtime data: $e');
    } finally {
      context.hideLoader();
      notifyListeners();
    }
  }

  Future<void> updateEarlyLeaveStatus(BuildContext context, bool isApproved) async {
    try {
      context.showLoader();

      EarlyLeaveStatusReq earlyLeaveStatusReq = EarlyLeaveStatusReq(
        attendanceId: _attendanceId,
        status: isApproved ? Constant.APPROVED : Constant.REJECTED,
      );

      final apiRes = await AttendanceRepo().uploadEarlyLeaveStatus(earlyLeaveStatusReq: earlyLeaveStatusReq);

      if (apiRes.successMessage != null && context.mounted) {
        SnackBarMsg.showSuccessMessage(context, apiRes.successMessage);
        await Provider.of<AttendanceViewModel>(context, listen: false).getTeamAttendance(context);
        Navigator.of(context).pop();
      } else {
        SnackBarMsg.showErrorMessage(context, apiRes.errorMessage!);
      }
    } catch (e) {
      Log.e('Error uploading overtime data: $e');
    } finally {
      context.hideLoader();
      notifyListeners();
    }
  }
}
