import 'package:flutter/material.dart';
import 'package:panamera_app/comman_widget/custom_loader.dart';
import 'package:panamera_app/features/login/repository/login_repo.dart';
import 'package:panamera_app/gen/assets.gen.dart';
import 'package:panamera_app/responsive/screen_size_config.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/global_tap.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/log_utils.dart';
import 'package:panamera_app/utils/snackbar_messages.dart';
import 'package:panamera_app/utils/system_ui_manager.dart';
import 'package:panamera_app/values/colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _emailController.clear();
  }

  @override
  Widget build(BuildContext context) {
    SystemUIManager.setSystemUI(context: context, statusBarColor: MColors.transparent);
    var strings = Helper.getLocalization()!;
    return GestureDetector(
      onTap: () => GlobalTap.safeTap(() {
        FocusScope.of(context).unfocus();
      }),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Container(decoration: BoxDecoration(image: DecorationImage(image: AssetImage(Assets.images.loginBg.path), fit: BoxFit.cover))),
            Positioned(
              top: 30,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_outlined, color: MColors.black),
                onPressed: () => GlobalTap.safeTap(() {
                  Navigator.pop(context);
                }),
              ),
            ),
            Center(
              child: SizedBox(
                height: ScreenSizeConfig.height * 0.95,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // SizedBox(height: ScreenSizeConfig.height * 0.1),
                    Expanded(flex: 3, child: Image.asset(Assets.images.logoIc.path, width: ScreenSizeConfig.width * 0.6)),
                    // SizedBox(height: ScreenSizeConfig.height * 0.15),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        width: ScreenSizeConfig.width * 0.85,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.mail_outline),
                                hintText: strings.email,
                                hintStyle: TextStyle(fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize, fontWeight: FontWeight.w600),
                                filled: true,
                                counterText: '',
                                fillColor: MColors.white,
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // const SizedBox(height: 80),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Container(
                            height: 50,
                            decoration: BoxDecoration(color: MColors.primaryGreen, borderRadius: BorderRadius.circular(10)),
                            width: ScreenSizeConfig.width * 0.8,
                            child: TextButton(
                              onPressed: () => GlobalTap.safeTap(() {
                                FocusScope.of(context).unfocus();
                                forgotPasswordButtonClick(context);
                              }),
                              child: Text(
                                strings.forgot_password,
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: MColors.white, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // SizedBox(
                    //   height: ScreenSizeConfig.height * 0.13,
                    // ),
                    Expanded(
                      flex: 0,
                      child: Text(
                        strings.panamera_living_copyright_2026,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: MColors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                    // SizedBox(height: 20), // small spacing from bottom edge
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> forgotPasswordButtonClick(BuildContext context) async {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      SnackBarMsg.showErrorMessage(context, Helper.getLocalization()?.please_enter_email);
      return;
    }

    try {
      context.showLoader();
      final apiRes = await LoginRepo().forgotPassword(email: email);

      if (!context.mounted) {
        Log.e('Context is not mounted');
        return;
      }

      if (apiRes.successMessage != null && context.mounted) {
        SnackBarMsg.showSuccessMessage(context, apiRes.successMessage!);
        Navigator.pushNamedAndRemoveUntil(context, Constant.loginScreen, (route) => false);
      } else {
        SnackBarMsg.showErrorMessage(context, apiRes.errorMessage!);
      }
    } catch (e) {
      Log.e('Error during forgotPassword: $e');
      SnackBarMsg.showError(context);
    } finally {
      context.hideLoader();
      setState(() {});
    }
  }
}
