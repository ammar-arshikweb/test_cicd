import 'package:flutter/cupertino.dart';
import 'package:panamera_app/comman_widget/custom_loader.dart';
import 'package:panamera_app/features/employee/main_page/repository/main_page_repo.dart';
import 'package:panamera_app/features/employee/notifications/model/notification_model.dart';
import 'package:panamera_app/features/employee/notifications/repo/notification_repo.dart';
import 'package:panamera_app/services/network_service.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/log_utils.dart';
import 'package:panamera_app/utils/snackbar_messages.dart';

class NotificationViewModel with ChangeNotifier {
  final NotificationRepo _notificationRepo = NotificationRepo();
  final List<NotificationModel> _notificationList = [];

  List<NotificationModel> get notificationList => _notificationList;

  void initModel(BuildContext context, bool isCustomer) async {
    getNotificationList(context, isCustomer, isFirstTime: true);
  }

  void resetModel() async {
    _notificationList.clear();
  }

  Future<void> getNotificationList(BuildContext context, bool isCustomer, {bool isFirstTime = false}) async {
    if (!NetworkStatusService().connectionStatus.value) {
      SnackBarMsg.showErrorMessage(context, Helper.getLocalization()?.no_internet_connection);
      return;
    }

    if (!isFirstTime) context.showLoader();
    try {
      final apiRes = await _notificationRepo.getNotifications(isCustomer);

      if (!context.mounted) {
        Log.e('Context is not mounted');
        return;
      }

      if (apiRes.data != null) {
        _notificationList
          ..clear()
          ..addAll(apiRes.data!);
        markAllNotificationsAsRead(context);
      } else {
        SnackBarMsg.showErrorMessage(context, apiRes.errorMessage ?? Helper.getLocalization()!.error_occurred_try_again);
      }
    } catch (e) {
      Log.e('Error getNotificationList: $e');
      SnackBarMsg.showError(context);
    } finally {
      context.hideLoader();
      notifyListeners();
    }
  }

  void markAllNotificationsAsRead(BuildContext context) {
    try {
      if (_notificationList.isEmpty) {
        Log.e("No notifications to mark as read.");
        return;
      }

      final unreadIds = _notificationList.where((notification) => !notification.isRead).map((e) => e.notificationId).toList();

      if (unreadIds.isEmpty) {
        Log.e("All notifications are already read.");
        return;
      }

      MainPageRepo()
          .markNotificationsRead(notificationIds: unreadIds)
          .then((apiRes) {
            if (apiRes.successMessage != null) {
              // No need to change anything in the UI
            } else {
              Log.e("Error marking notifications as read: ${apiRes.errorMessage}");
            }
          })
          .catchError((error) {
            Log.e("Catch error: $error");
          });
    } catch (e) {
      Log.e('Error markAllNotificationsAsRead: $e');
      SnackBarMsg.showError(context);
    }
  }
}
