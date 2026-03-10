import 'package:flutter/material.dart';
import 'package:panamera_app/features/login/view/math_captcha.dart';
import 'package:panamera_app/features/login/view_model/login_view_model.dart';
import 'package:panamera_app/gen/assets.gen.dart';
import 'package:panamera_app/l10n/app_localizations.dart';
import 'package:panamera_app/responsive/screen_size_config.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/global_tap.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/snackbar_messages.dart';
import 'package:panamera_app/utils/system_ui_manager.dart';
import 'package:panamera_app/values/colors.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late LoginViewModel loginViewModel;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loginViewModel = Provider.of<LoginViewModel>(context, listen: false);
    loginViewModel.initModel(context);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    loginViewModel.resetModel();
  }

  @override
  Widget build(BuildContext context) {
    var strings = Helper.getLocalization()!;

    // Set system UI for login screen - transparent status bar, default navigation bar
    SystemUIManager.setSystemUI(context: context, statusBarColor: MColors.transparent);

    return GestureDetector(
      onTap: () => GlobalTap.safeTap(() {
        FocusScope.of(context).unfocus();
      }),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Container(decoration: BoxDecoration(image: DecorationImage(image: AssetImage(Assets.images.loginBg.path), fit: BoxFit.cover))),
            Center(
              child: Consumer<LoginViewModel>(
                builder: (context, provider, child) {
                  return SizedBox(
                    height: ScreenSizeConfig.height * 0.95,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // SizedBox(height: ScreenSizeConfig.height * 0.1),
                        Expanded(flex: 3, child: Image.asset(Assets.images.logoIc.path, width: ScreenSizeConfig.width * 0.6)),
                        Container(
                          width: ScreenSizeConfig.width * 0.8,
                          decoration: BoxDecoration(color: MColors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(15)),
                          child: TabBar(
                            controller: _tabController,
                            indicator: BoxDecoration(color: MColors.primaryGreen, borderRadius: BorderRadius.circular(15)),
                            indicatorSize: TabBarIndicatorSize.tab,
                            dividerColor: Colors.transparent,
                            labelColor: MColors.white,
                            unselectedLabelColor: MColors.white,
                            labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
                            unselectedLabelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
                            tabs: [Tab(text: strings.employee), Tab(text: strings.customer)],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // SizedBox(height: ScreenSizeConfig.height * 0.15),
                        Expanded(
                          flex: 4,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildEmpLoginForm(provider, strings, context), // Employee Login Tab
                              _buildCstLoginForm(provider, strings, context), // Customer Login Tab
                            ],
                          ),
                        ),
                        // const SizedBox(height: 80),
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              Container(
                                height: 50,
                                decoration: BoxDecoration(color: MColors.primaryGreen, borderRadius: BorderRadius.circular(10)),
                                width: ScreenSizeConfig.width * 0.8,
                                child: TextButton(
                                  onPressed: () => GlobalTap.safeTap(() {
                                    FocusScope.of(context).unfocus();
                                    loginViewModel.signInButtonClick(context, _tabController.index);
                                  }),
                                  child: Text(
                                    strings.login,
                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: MColors.white, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                              SizedBox(height: ScreenSizeConfig.height * 0.04),
                              InkWell(
                                onTap: () => GlobalTap.safeTap(() => Navigator.pushNamed(context, Constant.guestScreen,arguments: provider.projectImages)),
                                child: Text(
                                  strings.continue_as_guest,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w500, decoration: TextDecoration.underline),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // SizedBox(
                        //   height: ScreenSizeConfig.height * 0.13,
                        // ),
                        Text(
                          strings.panamera_living_copyright_2026,
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: MColors.white, fontWeight: FontWeight.w600),
                        ),
                        // SizedBox(height: 20), // small spacing from bottom edge
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpLoginForm(LoginViewModel provider, AppLocalizations strings, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenSizeConfig.width * 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: provider.usernameController,
            maxLength: 20,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.person),
              hintText: strings.username,
              hintStyle: TextStyle(fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize, fontWeight: FontWeight.w600),
              filled: true,
              counterText: '',
              fillColor: MColors.white,
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: provider.passwordController,
            maxLength: 20,
            obscureText: !provider.isPasswordVisible,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                onPressed: () => GlobalTap.safeTap(() {
                  provider.togglePasswordVisibility();
                }),
                icon: Icon(!provider.isPasswordVisible ? Icons.visibility_off : Icons.visibility),
              ),
              hintText: strings.password,
              hintStyle: TextStyle(fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize, fontWeight: FontWeight.w600),
              filled: true,
              counterText: '',
              fillColor: MColors.white,
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
            child:
                provider.showCaptcha
                    ? MathCaptcha(
                      key: const ValueKey('captcha'),
                      onSuccess: () {
                        provider.captchaVerified();
                        SnackBarMsg.showSuccessMessage(context, strings.captcha_solved_successfully);
                      },
                      onEmpty: () {
                        SnackBarMsg.showErrorMessage(context, strings.please_solve_the_captcha_first);
                      },
                      onWrong: () {
                        SnackBarMsg.showErrorMessage(context, 'Incorrect answer, try again.');
                      },
                    )
                    : const SizedBox(key: ValueKey('empty')), // must have different key
          ),
        ],
      ),
    );
  }

  Widget _buildCstLoginForm(LoginViewModel provider, AppLocalizations strings, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenSizeConfig.width * 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: provider.customerEmailController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.mail_outline),
              hintText: strings.email,
              hintStyle: TextStyle(fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize, fontWeight: FontWeight.w600),
              filled: true,
              counterText: '',
              fillColor: MColors.white,
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: provider.customerPasswordController,
            maxLength: 20,
            obscureText: !provider.isPasswordVisible,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                onPressed: () => GlobalTap.safeTap(() {
                  provider.togglePasswordVisibility();
                }),
                icon: Icon(!provider.isPasswordVisible ? Icons.visibility_off : Icons.visibility),
              ),
              hintText: strings.password,
              hintStyle: TextStyle(fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize, fontWeight: FontWeight.w600),
              filled: true,
              counterText: '',
              fillColor: MColors.white,
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () => GlobalTap.safeTap(() {
                  Navigator.pushNamed(context, Constant.forgetPasswordScreen);
                }),
                child: Text(
                  '${strings.forgot_password}?',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
            child:
                provider.showCaptcha
                    ? MathCaptcha(
                      key: const ValueKey('captcha'),
                      onSuccess: () {
                        provider.captchaVerified();
                        SnackBarMsg.showSuccessMessage(context, strings.captcha_solved_successfully);
                      },
                      onEmpty: () {
                        SnackBarMsg.showErrorMessage(context, strings.please_solve_the_captcha_first);
                      },
                      onWrong: () {
                        SnackBarMsg.showErrorMessage(context, 'Incorrect answer, try again.');
                      },
                    )
                    : const SizedBox(key: ValueKey('empty')), // must have different key
          ),
        ],
      ),
    );
  }
}
