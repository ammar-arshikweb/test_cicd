import 'package:panamera_app/features/customer/home/view_model/customer_home_view_model.dart';
import 'package:panamera_app/features/customer/home/view_model/home_maintenance_view_model.dart';
import 'package:panamera_app/features/customer/main_page/view_model/customer_main_page_view_model.dart';
import 'package:panamera_app/features/employee/amc/view_model/add_issue_view_model.dart';
import 'package:panamera_app/features/employee/amc/view_model/admin_amc_view_model.dart';
import 'package:panamera_app/features/employee/amc/view_model/amc_view_model.dart';
import 'package:panamera_app/features/employee/amc/view_model/comments_photo_view_model.dart';
import 'package:panamera_app/features/employee/amc/view_model/job_detail_view_model.dart';
import 'package:panamera_app/features/employee/attendance/view_model/attendance_view_model.dart';
import 'package:panamera_app/features/employee/attendance/view_model/early_leave_dialog_view_model.dart';
import 'package:panamera_app/features/employee/attendance/view_model/emergency_view_model.dart';
import 'package:panamera_app/features/employee/attendance/view_model/leave_view_model.dart';
import 'package:panamera_app/features/employee/attendance/view_model/overtime_dialog_view_model.dart';
import 'package:panamera_app/features/employee/home/view_model/all_tasks_issues_view_model.dart';
import 'package:panamera_app/features/employee/home/view_model/home_view_model.dart';
import 'package:panamera_app/features/employee/home/view_model/issue_view_model.dart';
import 'package:panamera_app/features/employee/main_page/view_model/main_page_view_model.dart';
import 'package:panamera_app/features/login/view_model/login_view_model.dart';
import 'package:panamera_app/features/employee/notifications/view_model/notification_view_model.dart';
import 'package:panamera_app/features/splash/view_model/splash_view_model.dart';
import 'package:panamera_app/providers/app_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

final List<SingleChildWidget> appProviders = [
  ChangeNotifierProvider(create: (_) => AppProvider()),
  ChangeNotifierProvider(create: (_) => SplashViewModel()),
  ChangeNotifierProvider(create: (_) => LoginViewModel()),
  ChangeNotifierProvider(create: (_) => MainPageViewModel()),
  ChangeNotifierProvider(create: (_) => AttendanceViewModel()),
  ChangeNotifierProvider(create: (_) => OverTimeDialogViewModel()),
  ChangeNotifierProvider(create: (_) => AmcViewModel()),
  ChangeNotifierProvider(create: (_) => EarlyLeaveDialogViewModel()),
  ChangeNotifierProvider(create: (_) => NotificationViewModel()),
  ChangeNotifierProvider(create: (_) => CommentsPhotoViewModel()),
  ChangeNotifierProvider(create: (_) => AddIssueViewModel()),
  ChangeNotifierProvider(create: (_) => IssueViewModel()),
  ChangeNotifierProvider(create: (_) => JobDetailViewModel()),
  ChangeNotifierProvider(create: (_) => CustomerMainPageViewModel()),
  ChangeNotifierProvider(create: (_) => CustomerHomeViewModel()),
  ChangeNotifierProvider(create: (_) => AllTasksIssuesViewModel()),
  ChangeNotifierProvider(create: (_) => HomeViewModel()),
  ChangeNotifierProvider(create: (_) => HomeMaintenanceViewModel()),
  ChangeNotifierProvider(create: (_) => AdminAmcViewModel()),
  ChangeNotifierProvider(create: (_) => EmergencyViewModel()),
  ChangeNotifierProvider(create: (_) => LeaveViewModel()),
];
