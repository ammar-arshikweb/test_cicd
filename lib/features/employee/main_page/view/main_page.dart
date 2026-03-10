import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:panamera_app/comman_widget/confirmation_dialog.dart';
import 'package:panamera_app/features/employee/amc/view/admin_amc_screen.dart';
import 'package:panamera_app/features/employee/amc/view/amc_screen.dart';
import 'package:panamera_app/features/employee/attendance/view/attendance_screen.dart';
import 'package:panamera_app/features/employee/attendance/view/emergency_screen.dart';
import 'package:panamera_app/features/employee/attendance/view/leave_screen.dart';
import 'package:panamera_app/features/employee/attendance/view_model/attendance_view_model.dart';
import 'package:panamera_app/features/employee/home/view/home_screen.dart';
import 'package:panamera_app/features/employee/main_page/view/employee_profile_screen.dart';
import 'package:panamera_app/features/employee/main_page/view_model/main_page_view_model.dart';
import 'package:panamera_app/features/employee/notifications/view/notification_screen.dart';
import 'package:panamera_app/gen/assets.gen.dart';
import 'package:panamera_app/l10n/app_localizations.dart';
import 'package:panamera_app/responsive/screen_size_config.dart';
import 'package:panamera_app/services/network_service.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/global_tap.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/preference.dart';
import 'package:panamera_app/utils/snackbar_messages.dart';
import 'package:panamera_app/utils/system_ui_manager.dart';
import 'package:panamera_app/values/colors.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late MainPageViewModel _homeViewModel;

  @override
  void initState() {
    super.initState();
    _homeViewModel = Provider.of<MainPageViewModel>(context, listen: false);
    _homeViewModel.initModel(context);
  }

  @override
  void dispose() {
    _homeViewModel.resetModel();
    super.dispose();
  }

  Widget _buildNavItem({required String iconAssetPath, required String activeIconAssetPath, required String label, required int itemIndex}) {
    return Consumer<MainPageViewModel>(
      builder: (context, provider, child) {
        bool isSelected = provider.selectedIndex == itemIndex;

        return InkWell(
          onTap: () => GlobalTap.safeTap(() => provider.setIndex(itemIndex)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  activeIconAssetPath,
                  colorFilter: ColorFilter.mode(isSelected ? Color(0xFF180940) : MColors.white, BlendMode.srcIn),
                  width: 24,
                  height: 24,
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Color(0xFF180940) : MColors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var strings = Helper.getLocalization()!;

    // Set system UI for main page with primary green navigation bar
    SystemUIManager.setSystemUI(context: context, statusBarColor: MColors.primaryGreen);

    final List<Widget> pages = [
      const HomeScreen(),
      const AttendanceScreen(),
      const AmcScreen(),
      const AdminAmcScreen(),
      const Center(child: Text('Projects Page Content')),
      const NotificationScreen(isCustomer: false),
    ];
    return Consumer<MainPageViewModel>(
      builder: (context, provider, child) {
        has(String id) => Pref.getFunctionality()?.contains(id) ?? false;
        return Scaffold(
          // body: Stack(children: [pages[provider.selectedIndex], if (provider.selectedIndex != 4) buildHeader(context, strings, provider)]),
          body: SafeArea(child: Stack(children: [pages[provider.selectedIndex], buildHeader(context, strings, provider)])),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(color: MColors.primaryGreen),
            padding: EdgeInsets.only(
              top: 6,
              bottom: 6 + MediaQuery.of(context).padding.bottom, // Add bottom system padding
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center, // align items to center
              children: [
                if (has(Constant.MOBILE_FEED))
                  _buildNavItem(iconAssetPath: Assets.images.feed, activeIconAssetPath: Assets.images.feedActive, label: strings.home, itemIndex: 0),
                if (has(Constant.MOBILE_ATTENDANCE))
                  _buildNavItem(
                    iconAssetPath: Assets.images.attendance,
                    activeIconAssetPath: Assets.images.attendanceActive,
                    label: strings.attendance,
                    itemIndex: 1,
                  ),
                if (has(Constant.MOBILE_AMC))
                  _buildNavItem(iconAssetPath: Assets.images.amc, activeIconAssetPath: Assets.images.amcActive, label: strings.amc, itemIndex: 2),
                if (has(Constant.MOBILE_AMC_HISTORY))
                  _buildNavItem(
                    iconAssetPath: Assets.images.amc,
                    activeIconAssetPath: Assets.images.amcActive,
                    label: strings.amc_history,
                    itemIndex: 3,
                  ),
                if (has(Constant.MOBILE_PROJECTS))
                  _buildNavItem(
                    iconAssetPath: Assets.images.project,
                    activeIconAssetPath: Assets.images.projectActive,
                    label: strings.projects,
                    itemIndex: 4,
                  ),
                if (has(Constant.MOBILE_NOTIFICATION))
                  _buildNavItem(
                    iconAssetPath: Assets.images.notification,
                    activeIconAssetPath: Assets.images.notificationActive,
                    label: strings.notifications,
                    itemIndex: 5,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Positioned buildHeader(BuildContext context, AppLocalizations strings, MainPageViewModel provider) {
    return Positioned(
      top: 20,
      left: 0,
      child: SizedBox(
        width: ScreenSizeConfig.width,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (provider.selectedIndex != 4)
                ValueListenableBuilder<bool>(
                  valueListenable: NetworkStatusService().connectionStatus,
                  builder: (context, isConnected, _) {
                    return Image.asset(isConnected ? Assets.images.online.path : Assets.images.offline.path, height: 20, width: 60, fit: BoxFit.fill);
                  },
                ),
              const Spacer(),
              PopupMenuButton(
                onSelected: (value) {
                  if (value == 1) {
                    confirmationDialog(context, Assets.images.logoutIc, strings.are_you_sure_you_want_to_logout, strings.logout, DialogType.RED, () {
                      provider.logoutButtonClick(context);
                    });
                  }
                  if (value == 0) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const EmployeeProfileScreen()));
                  }
                  if (value == 2) {
                    if (Provider.of<AttendanceViewModel>(context, listen: false).clockOutTime == null) {
                      return SnackBarMsg.showErrorMessage(context, strings.please_complete_your_regular_shift);
                    }
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const EmergencyScreen()));
                  }
                  if (value == 3) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LeaveScreen()));
                  }
                },
                itemBuilder: (BuildContext context) {
                  return <PopupMenuEntry>[
                    PopupMenuItem(
                      padding: EdgeInsets.all(8),
                      height: 0,
                      value: 0,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(Icons.person, size: 18, color: MColors.black),
                          ),
                          Text(strings.account, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                    if (provider.selectedIndex == 1 && (Pref.getFunctionality()?.contains(Constant.MOBILE_ATTENDANCE_MY_ATTENDANCE) ?? false)) ...[
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        padding: EdgeInsets.all(8),
                        height: 0,
                        value: 2,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Icon(Icons.emergency, size: 18, color: MColors.black),
                            ),
                            Text('Emergency Check-In', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ],
                    if (Pref.getFunctionality()?.contains(Constant.MOBILE_LEAVE_APPLICATION) ?? false) ...[
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        padding: EdgeInsets.zero,
                        height: 0,
                        value: 3,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0, right: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Icon(Icons.edit_calendar, size: 18, color: MColors.black),
                              ),
                              Text(strings.leave_application, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      padding: EdgeInsets.zero,
                      height: 0,
                      value: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0, right: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Icon(Icons.logout, size: 18, color: MColors.black),
                            ),
                            Text(strings.logout, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                child: CircleAvatar(
                  backgroundColor: MColors.grey,
                  radius: 25,
                  child: Text(
                    Pref.getEmpName().substring(0, 1).toUpperCase(),
                    style: TextStyle(color: MColors.black, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
