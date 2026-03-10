import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:panamera_app/comman_widget/confirmation_dialog.dart';
import 'package:panamera_app/features/employee/attendance/view_model/early_leave_dialog_view_model.dart';
import 'package:panamera_app/gen/assets.gen.dart';
import 'package:panamera_app/l10n/app_localizations.dart';
import 'package:panamera_app/utils/global_tap.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/values/colors.dart';
import 'package:provider/provider.dart';

class EarlyLeaveDialog extends StatefulWidget {
  final int attendanceId;
  final int? clockOutId;
  final String? reason;

  const EarlyLeaveDialog({super.key, required this.attendanceId, this.clockOutId, this.reason});

  @override
  State<EarlyLeaveDialog> createState() => _EarlyLeaveDialogState();
}

class _EarlyLeaveDialogState extends State<EarlyLeaveDialog> {
  late EarlyLeaveDialogViewModel earlyLeaveDialogViewModel;

  @override
  void initState() {
    super.initState();
    earlyLeaveDialogViewModel = Provider.of<EarlyLeaveDialogViewModel>(context, listen: false);
    earlyLeaveDialogViewModel.initModel(widget.attendanceId, widget.clockOutId, widget.reason);
  }

  @override
  void dispose() {
    super.dispose();
    earlyLeaveDialogViewModel.resetModel();
  }

  @override
  Widget build(BuildContext context) {
    var strings = Helper.getLocalization()!;
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
      child: MediaQuery(
        // Added MediaQuery to avoid keyboard issues
        data: MediaQuery.of(context).copyWith(viewInsets: EdgeInsets.zero),
        child: Center(
          child: Dialog(
            backgroundColor: MColors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: widget.reason != null ? buildEarlyLeaveApproval(strings, context) : buildGiveReasonForEarlyLeave(strings, context),
            ),
          ),
        ),
      ),
    );
  }

  Column buildGiveReasonForEarlyLeave(AppLocalizations strings, BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: Text(strings.give_reason_for_early_leave, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500))),
        const SizedBox(height: 20),
        Text(
          strings.early_leave_reason,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10, color: MColors.c9190A7, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: earlyLeaveDialogViewModel.reasonController,
          style: TextStyle(fontWeight: FontWeight.normal),
          maxLines: 5,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: MColors.c9190A7, width: 2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: MColors.c9190A7, width: 2)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: MColors.primaryGreen, width: 2)),
            isDense: true,
          ),
        ),
        const SizedBox(height: 24),
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MColors.primaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    ),
                    onPressed: () => GlobalTap.safeTap(() async {
                      await earlyLeaveDialogViewModel.uploadEarlyLeaveData(context);
                    }),
                    child: Text(strings.confirm, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: MColors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => GlobalTap.safeTap(() async {
                      await confirmationDialog(
                        context,
                        Assets.images.attendance,
                        strings.are_you_sure_you_dont_want_to_add_early_leave_reason,
                        Helper.getLocalization()!.yes,
                        DialogType.NEUTRAL,
                        () async {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                      );
                    }),
                    child: Text(strings.cancel, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: MColors.black)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Column buildEarlyLeaveApproval(AppLocalizations strings, BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(strings.early_leave_approval, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
            const Spacer(),
            IconButton(icon: Icon(Icons.close, color: MColors.red), onPressed: () => GlobalTap.safeTap(() => Navigator.pop(context))),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          strings.early_leave_reason,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10, color: MColors.c9190A7, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 5),
        Text(widget.reason!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500), maxLines: 5),
        const SizedBox(height: 24),
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MColors.primaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    ),
                    onPressed: () => GlobalTap.safeTap(() async {
                      await earlyLeaveDialogViewModel.updateEarlyLeaveStatus(context, true);
                    }),
                    child: Text(strings.approve, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: MColors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => GlobalTap.safeTap(() async {
                      await earlyLeaveDialogViewModel.updateEarlyLeaveStatus(context, false);
                    }),
                    child: Text(strings.reject, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: MColors.black)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
