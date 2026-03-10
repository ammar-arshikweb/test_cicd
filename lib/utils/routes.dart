import 'package:flutter/material.dart';
import 'package:panamera_app/features/customer/home/model/project_model.dart';
import 'package:panamera_app/features/customer/main_page/view/customer_main_page.dart';
import 'package:panamera_app/features/employee/amc/model/amc_model.dart';
import 'package:panamera_app/features/employee/amc/view/job_detail_screen.dart';
import 'package:panamera_app/features/employee/main_page/view/main_page.dart';
import 'package:panamera_app/features/login/view/forgot_password_screen.dart';
import 'package:panamera_app/features/login/view/guest_screen.dart';
import 'package:panamera_app/features/login/view/login_screen.dart';
import 'package:panamera_app/features/splash/view/splash_screen.dart';
import 'package:panamera_app/utils/constant.dart';

class Routes {
  static Route<dynamic> generateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case Constant.splashScreen:
        return MaterialPageRoute(builder: (BuildContext context) => const SplashScreen());
      case Constant.loginScreen:
        return MaterialPageRoute(builder: (BuildContext context) => const LoginScreen());
      case Constant.forgetPasswordScreen:
        return MaterialPageRoute(builder: (BuildContext context) => const ForgotPasswordScreen());
      case Constant.mainPage:
        return MaterialPageRoute(builder: (BuildContext context) => const MainPage());
      case Constant.customerMainPage:
        return MaterialPageRoute(builder: (BuildContext context) => const CustomerMainPage());
      case Constant.guestScreen:
        final projectImages = settings.arguments as List<ProjectModel>;
        return MaterialPageRoute(builder: (BuildContext context) => GuestScreen(projectImages: projectImages));
      case Constant.jobScreen:
        final job = settings.arguments as AmcJob;
        return MaterialPageRoute(builder: (BuildContext context) => JobDetailScreen(job: job));

      default:
        return MaterialPageRoute(
          builder: (_) {
            return const Scaffold(body: Center(child: Text('No route defined')));
          },
        );
    }
  }
}
