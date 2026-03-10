import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:panamera_app/features/employee/attendance/view_model/attendance_view_model.dart';
import 'package:panamera_app/features/employee/attendance/view_model/emergency_view_model.dart';
import 'package:panamera_app/gen/assets.gen.dart';
import 'package:panamera_app/utils/global_tap.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/time_utils.dart';
import 'package:panamera_app/values/colors.dart';
import 'package:provider/provider.dart';

class ClockInOutDialog extends StatefulWidget {
  final DateTime time;
  final bool isClockOut;
  final bool? isEmergency;

  const ClockInOutDialog({super.key, required this.time, required this.isClockOut, this.isEmergency = false});

  @override
  State<ClockInOutDialog> createState() => _ClockInOutDialogState();
}

class _ClockInOutDialogState extends State<ClockInOutDialog> with SingleTickerProviderStateMixin {
  bool isSubmitted = false;
  late AnimationController _lottieController;
  late AttendanceViewModel attendanceViewModel;

  @override
  void initState() {
    super.initState();
    attendanceViewModel = Provider.of<AttendanceViewModel>(context, listen: false);
    _lottieController = AnimationController(vsync: this);
    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var strings = Helper.getLocalization()!;
    String time = TimeUtils.formatTimeOfToAMPM(TimeOfDay(hour: widget.time.hour, minute: widget.time.minute));

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
      child: Center(
        child: Dialog(
          backgroundColor: MColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child:
                isSubmitted
                    ? Padding(
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
                              widget.isClockOut ? strings.check_out_successful : strings.check_in_successful,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900, color: MColors.dialogText),
                            ),
                          ),
                        ],
                      ),
                    )
                    : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: double.infinity,
                          color: MColors.greyBackground,
                          padding: EdgeInsets.symmetric(vertical: 50),
                          child: Center(
                            child: Text(
                              time,
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.w900, color: MColors.dialogText),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          widget.isClockOut ? strings.are_you_sure_you_want_to_check_out : strings.are_you_sure_you_want_to_check_in,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700, color: MColors.dialogText),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => GlobalTap.safeTap(() => Navigator.pop(context)),
                                child: Text(strings.no, style: TextStyle(fontSize: 16, color: MColors.black)),
                              ),
                            ),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: MColors.primaryGreen,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                ),
                                onPressed:
                                    () => GlobalTap.safeTap(() async {
                                      int isSuccess = 0;
                                      if (widget.isClockOut) {
                                        isSuccess =
                                            widget.isEmergency!
                                                ? await Provider.of<EmergencyViewModel>(context, listen: false).setTime(context, widget.time, true)
                                                : await attendanceViewModel.setTime(context, widget.time, true);
                                      } else {
                                        isSuccess =
                                            widget.isEmergency!
                                                ? await Provider.of<EmergencyViewModel>(context, listen: false).setTime(context, widget.time, false)
                                                : await attendanceViewModel.setTime(context, widget.time, false);
                                      }
                                      if (isSuccess == 1) {
                                        setState(() {
                                          isSubmitted = true;
                                        });
                                      } else if (isSuccess == 2) {
                                      } else {
                                        Navigator.pop(context);
                                      }
                                    }),
                                child: Text(strings.yes, style: const TextStyle(color: MColors.white, fontSize: 16)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }
}
