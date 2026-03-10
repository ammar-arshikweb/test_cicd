import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:panamera_app/features/splash/view_model/splash_view_model.dart';
import 'package:panamera_app/gen/assets.gen.dart';
import 'package:panamera_app/responsive/screen_size_config.dart';
import 'package:panamera_app/utils/system_ui_manager.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late SplashViewModel _splashViewModel;

  @override
  void initState() {
    super.initState();
    _splashViewModel = Provider.of<SplashViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _splashViewModel.initModel(context: context);
    });
  }

  @override
  void dispose() {
    _splashViewModel.resetModel();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set system UI for splash screen - transparent status bar, default navigation bar
    SystemUIManager.setSystemUI(
      context: context,
      statusBarColor: Colors.transparent,
    );

    return LayoutBuilder(
      builder: (_, constraints) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(Assets.images.loginBg.path),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Center(
                child: SizedBox(
                  height: ScreenSizeConfig.height * 0.90,
                  child: Image.asset(
                    Assets.images.logoIc.path,
                    width: ScreenSizeConfig.width * 0.6,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
