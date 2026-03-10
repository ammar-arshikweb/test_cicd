import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:panamera_app/comman_widget/confirmation_dialog.dart';
import 'package:panamera_app/features/customer/home/view/customer_home_screen.dart';
import 'package:panamera_app/features/customer/main_page/view/customer_profile_screen.dart';
import 'package:panamera_app/features/customer/main_page/view_model/customer_main_page_view_model.dart';
import 'package:panamera_app/features/employee/notifications/view/notification_screen.dart';
import 'package:panamera_app/gen/assets.gen.dart';
import 'package:panamera_app/l10n/app_localizations.dart';
import 'package:panamera_app/responsive/screen_size_config.dart';
import 'package:panamera_app/utils/global_tap.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/preference.dart';
import 'package:panamera_app/utils/system_ui_manager.dart';
import 'package:panamera_app/values/colors.dart';
import 'package:provider/provider.dart';

class CustomerMainPage extends StatefulWidget {
  const CustomerMainPage({super.key});

  @override
  State<CustomerMainPage> createState() => _CustomerMainPageState();
}

class _CustomerMainPageState extends State<CustomerMainPage> {
  late CustomerMainPageViewModel _homeViewModel;

  @override
  void initState() {
    super.initState();
    _homeViewModel = Provider.of<CustomerMainPageViewModel>(context, listen: false);
    _homeViewModel.initModel(context);
  }

  @override
  void dispose() {
    _homeViewModel.resetModel();
    super.dispose();
  }

  Widget _buildNavItem({required String iconAssetPath, required String activeIconAssetPath, required String label, required int itemIndex}) {
    return Consumer<CustomerMainPageViewModel>(
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
    SystemUIManager.setSystemUI(context: context, statusBarColor: MColors.green.withValues(alpha: 0.2));
    var strings = Helper.getLocalization()!;
    final List<Widget> pages = [const CustomerHomeScreen(), const NotificationScreen(isCustomer: true)];
    return Scaffold(
      body: SafeArea(
        child: Consumer<CustomerMainPageViewModel>(
          builder: (context, provider, child) {
            return Stack(children: [pages[provider.selectedIndex], buildHeader(context, strings, provider)]);
          },
        ),
      ),
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
            _buildNavItem(iconAssetPath: Assets.images.feed, activeIconAssetPath: Assets.images.feedActive, label: strings.home, itemIndex: 0),
            _buildNavItem(
              iconAssetPath: Assets.images.notification,
              activeIconAssetPath: Assets.images.notificationActive,
              label: strings.notifications,
              itemIndex: 1,
            ),
          ],
        ),
      ),
    );
  }

  Positioned buildHeader(BuildContext context, AppLocalizations strings, CustomerMainPageViewModel provider) {
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
              const Spacer(),
              PopupMenuButton(
                onSelected: (value) {
                  if (value == 1) {
                    confirmationDialog(context, Assets.images.logoutIc, strings.are_you_sure_you_want_to_logout, strings.logout, DialogType.RED, () {
                      provider.logoutButtonClick(context);
                    });
                  }
                  if (value == 0) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomerProfileScreen()));
                  }
                },
                itemBuilder: (BuildContext context) {
                  return <PopupMenuEntry>[
                    PopupMenuItem(
                      enabled: false,
                      padding: const EdgeInsets.only(left: 8.0),
                      height: 0,
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: MColors.grey,
                            radius: 20,
                            child: Text(
                              Pref.getCustomerName().substring(0, 1).toUpperCase(),
                              style: TextStyle(color: MColors.black, fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Pref.getCustomerName(),
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  Pref.getCustomerEmail(),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(color: MColors.grey, fontWeight: FontWeight.w500, overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      padding: EdgeInsets.all(8),
                      height: 0,
                      value: 0,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Icon(Icons.person, size: 18, color: MColors.black)),
                          Text(strings.account, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      padding: EdgeInsets.all(8),
                      height: 0,
                      value: 1,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(Icons.exit_to_app, size: 18, color: MColors.black),
                          ),
                          Text(strings.logout, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ];
                },
                child: CircleAvatar(
                  backgroundColor: MColors.grey,
                  radius: 25,
                  child: Text(
                    Pref.getCustomerName().substring(0, 1).toUpperCase(),
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
