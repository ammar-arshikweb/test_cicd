import 'dart:async';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:lottie/lottie.dart';
import 'package:panamera_app/app_initializer.dart';
import 'package:panamera_app/features/app_update/view/app_update_dialog.dart';
import 'package:panamera_app/gen/assets.gen.dart';
import 'package:panamera_app/l10n/app_localizations.dart';
import 'package:panamera_app/providers/app_provider.dart';
import 'package:panamera_app/providers/provider_list.dart';
import 'package:panamera_app/responsive/screen_size_config.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/routes.dart';
import 'package:panamera_app/utils/system_ui_manager.dart';
import 'package:panamera_app/values/colors.dart';
import 'package:panamera_app/values/styles.dart';
import 'package:provider/provider.dart';
import 'utils/log_utils.dart';

bool isLive = false; //TODO : Set this based on your environment (Dev or Live)
bool isDev = true; //TODO : Set this based on your environment (Dev or local)

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInitializer.initialize();
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Check for updates on app launch - delay to ensure MaterialApp and all screens are built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted && navigatorKey.currentContext != null) {
          AppUpdatePopupHandler.checkAndShowUpdatePopup(navigatorKey.currentContext!);
        } else {
          Log.e('App  Update Check (Launch): Context not mounted or navigator context is null');
        }
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Check for updates when app resumes from background - with delay to ensure build is complete
    if (state == AppLifecycleState.resumed) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && navigatorKey.currentContext != null) {
          AppUpdatePopupHandler.checkAndShowUpdatePopup(navigatorKey.currentContext!);
        } else {
          Log.e(' App Update Check (Resume): Context not mounted or navigator context is null');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return MultiProvider(
      providers: appProviders,
      child: Consumer<AppProvider>(
        builder: (context, provider, child) {
          ScreenSizeConfig.init(context: context); // Initialize screen size for getting screen height and width.

          // Apply default system UI styling for main app (white in light mode, black in dark mode)
          SystemUIManager.setSystemUI(context: context);

          return GlobalLoaderOverlay(
            overlayColor: MColors.progressBack,
            overlayWidgetBuilder: (_) => _buildLoader(),
            child: Stack(
              children: [
                MaterialApp(
                  navigatorKey: navigatorKey,
                  localizationsDelegates: [
                    CountryLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    ...AppLocalizations.localizationsDelegates,
                  ],
                  supportedLocales: AppLocalizations.supportedLocales,
                  debugShowCheckedModeBanner: false,
                  theme: buildThemeData(widget, provider.isDark),
                  initialRoute: Constant.splashScreen,
                  // initialRoute: Constant.homePage,
                  onGenerateRoute: Routes.generateRoutes,
                ),
                if (!isLive)
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Material(
                      color: MColors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: Text(
                          'v: ${AppInitializer.packageInfo?.version ?? ''}(${AppInitializer.packageInfo?.buildNumber ?? ''}) - ${isLive
                              ? 'P'
                              : isDev
                              ? 'D'
                              : 'L'}',
                          style: TextStyle(color: MColors.textDarkGrey, fontSize: 8),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Custom Loading Overlay
  Widget _buildLoader() {
    return Center(child: Padding(padding: const EdgeInsets.all(100), child: Lottie.asset(Assets.animations.loader, repeat: true)));
  }
}
