import 'package:panamera_app/utils/constant.dart';

class NotificationModel {
  final int notificationId;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({required this.notificationId, required this.title, required this.body, required this.isRead, required this.createdAt});

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json[Constant.notificationId],
      title: json[Constant.title],
      body: json[Constant.body],
      isRead: json[Constant.isRead],
      createdAt: DateTime.parse(json[Constant.createdAt]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      Constant.notificationId: notificationId,
      Constant.title: title,
      Constant.body: body,
      Constant.isRead: isRead,
      Constant.createdAt: createdAt.toIso8601String(),
    };
  }
}
