import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:panamera_app/features/employee/notifications/model/notification_model.dart';
import 'package:panamera_app/features/employee/notifications/view_model/notification_view_model.dart';
import 'package:panamera_app/l10n/app_localizations.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/system_ui_manager.dart';
import 'package:panamera_app/values/colors.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatefulWidget {
  final bool isCustomer;
  const NotificationScreen({super.key, required this.isCustomer});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late AppLocalizations strings;
  late NotificationViewModel notificationViewModel;

  @override
  void initState() {
    super.initState();
    notificationViewModel = Provider.of<NotificationViewModel>(context, listen: false);
    notificationViewModel.initModel(context, widget.isCustomer);
  }

  @override
  void dispose() {
    notificationViewModel.resetModel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemUIManager.setSystemUI(context: context,statusBarColor: MColors.white);
    strings = Helper.getLocalization()!;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: MColors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Consumer<NotificationViewModel>(
              builder: (context, provider, child) {
                final notifications = provider.notificationList;

                return Column(
                  children: [
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 5),
                      width: constraints.maxWidth,
                      child: Text(strings.notifications, style: const TextStyle(color: MColors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 10),
                    notifications.isEmpty
                        ? Expanded(child: Center(child: Text(strings.no_notification)))
                        : Expanded(
                          child: ListView.builder(
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              final item = notifications[index];
                              return buildNotificationItem(item);
                            },
                          ),
                        ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget buildNotificationItem(NotificationModel item) {
    final formattedDate = DateFormat(Constant.ddMMyyyy_hh_mm_a).format(item.createdAt);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MColors.white,
        border: Border.all(color: MColors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: MColors.grey.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Icon(item.isRead ? Icons.notifications_none : Icons.notifications_active, color: item.isRead ? MColors.grey : MColors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(item.body, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                const SizedBox(height: 6),
                Text(formattedDate, style: TextStyle(fontSize: 12, color: MColors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
