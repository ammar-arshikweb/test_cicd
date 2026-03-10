import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:panamera_app/comman_widget/custom_loader.dart';
import 'package:panamera_app/features/customer/home/repository/customer_home_repo.dart';
import 'package:panamera_app/gen/assets.gen.dart';
import 'package:panamera_app/l10n/app_localizations.dart';
import 'package:panamera_app/utils/global_tap.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/log_utils.dart';
import 'package:panamera_app/utils/snackbar_messages.dart';
import 'package:panamera_app/utils/system_ui_manager.dart';
import 'package:panamera_app/values/colors.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> with SingleTickerProviderStateMixin {
  late AnimationController _lottieController;
  late AppLocalizations strings;
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemUIManager.setSystemUI(context: context, statusBarColor: MColors.green.withValues(alpha: 0.2));
    strings = Helper.getLocalization()!;
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [MColors.green.withValues(alpha: 0.2), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            child: GestureDetector(
              onTap: () => GlobalTap.safeTap(() => FocusScope.of(context).unfocus()), // Dismiss keyboard on tap outside
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  Text(strings.feedback.toUpperCase(), style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 50),
                  Text(strings.feedback_text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400, height: 1.5)),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _feedbackController,
                    maxLines: 12,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: MColors.white,
                      hintText: strings.enter_your_feedback_here,
                      hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MColors.grey),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 70),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(color: MColors.primaryGreen.withValues(alpha: 0.75), borderRadius: BorderRadius.circular(2)),
                          child: TextButton(
                            onPressed: () => GlobalTap.safeTap(() {
                              Navigator.of(context).pop();
                            }),
                            child: Text(
                              strings.back,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: MColors.white, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(color: MColors.lightGreen, borderRadius: BorderRadius.circular(2)),
                          child: TextButton(
                            onPressed: () => GlobalTap.safeTap(() {
                              getJobDetail(context);
                            }),
                            child: Text(
                              strings.submit,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: MColors.white, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> getJobDetail(BuildContext context) async {
    if(_feedbackController.text.trim().isEmpty){
      SnackBarMsg.showErrorMessage(context,strings.please_fill_all_fields);
      return;
    }
    try {
      context.showLoader();

      final apiRes = await CustomerHomeRepo().addFeedback(_feedbackController.text.trim());

      if (apiRes.status != false && apiRes.successMessage != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          barrierLabel: '',
          barrierColor: MColors.black.withValues(alpha: 0.4),
          builder: (BuildContext context) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
              child: Center(
                child: Dialog(
                  backgroundColor: MColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child:
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Lottie.asset(
                            controller: _lottieController,
                            Assets.animations.successful,
                            width: double.infinity,
                            height: 100,
                            onLoaded: (composition) {
                              _lottieController
                                ..duration = composition.duration
                                ..forward();
                            },
                          ),
                          const SizedBox(height: 40),
                          Center(
                            child: Text(
                              strings.feedback_sent,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900, color: MColors.dialogText),
                            ),
                          ),
                        ],
                      ),
                    )
                  ),
                ),
              ),
            );
          },
        );
      } else {
        SnackBarMsg.showErrorMessage(context, apiRes.errorMessage ?? strings.error_occurred_try_again);
      }
    } catch (e) {
      Log.e('Error adding feedback: $e');
    } finally {
      context.hideLoader();
    }
  }
}
