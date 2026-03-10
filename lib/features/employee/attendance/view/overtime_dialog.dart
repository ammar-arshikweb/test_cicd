import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:panamera_app/comman_widget/image_widgets.dart';
import 'package:panamera_app/features/employee/attendance/model/attendance_model/attendance_model.dart';
import 'package:panamera_app/features/employee/attendance/view_model/overtime_dialog_view_model.dart';
import 'package:panamera_app/l10n/app_localizations.dart';
import 'package:panamera_app/responsive/screen_size_config.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/global_tap.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/log_utils.dart';
import 'package:panamera_app/utils/snackbar_messages.dart';
import 'package:panamera_app/values/colors.dart';
import 'package:provider/provider.dart';

class OvertimeDialog extends StatefulWidget {
  final int attendanceId;
  final int? clockOutId;
  final OvertimeModel? overtimeData;
  final bool? isEmergency;
  final EmergencyModel? emergencyData;

  const OvertimeDialog({super.key, this.overtimeData, this.isEmergency = false, this.emergencyData, required this.attendanceId, this.clockOutId});

  @override
  State<OvertimeDialog> createState() => _OvertimeDialogState();
}

class _OvertimeDialogState extends State<OvertimeDialog> with TickerProviderStateMixin {
  late OverTimeDialogViewModel overTimeDialogViewModel;
  late TabController _tabController;
  int? _selectedOvertimeHours;

  @override
  void initState() {
    super.initState();
    overTimeDialogViewModel = Provider.of<OverTimeDialogViewModel>(context, listen: false);
    overTimeDialogViewModel.initModel(widget.attendanceId, widget.overtimeData, widget.emergencyData, widget.clockOutId);
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    overTimeDialogViewModel.resetModel();
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
              child: widget.overtimeData != null ? buildOvertimeApproval(strings, context) : buildGiveReasonForOvertime(strings, context),
            ),
          ),
        ),
      ),
    );
  }

  Column buildGiveReasonForOvertime(AppLocalizations strings, BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(strings.give_reason_for_overtime, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
        ),
        const SizedBox(height: 20),
        Text(
          strings.overtime_reason,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10, color: MColors.c9190A7, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: overTimeDialogViewModel.reasonController,
          style: TextStyle(fontWeight: FontWeight.normal),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: MColors.c9190A7, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: MColors.c9190A7, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: MColors.primaryGreen, width: 2),
            ),
            isDense: true,
          ),
        ),
        const SizedBox(height: 16),
        buildUploadPhotoView(strings),
        const SizedBox(height: 16),
        buildRecordAudioView(strings, context),
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
                      await overTimeDialogViewModel.uploadOvertimeData(context);
                    }),
                    child: Text(
                      strings.confirm,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: MColors.white),
                    ),
                  ),
                ),
              ],
            ),
            // const SizedBox(height: 10),
            // Row(
            //   children: [
            //     Expanded(
            //       child: TextButton(
            //         onPressed: () => GlobalTap.safeTap(() {
            //           showDialog(
            //             context: context,
            //             barrierDismissible: false,
            //             barrierLabel: '',
            //             barrierColor: MColors.black.withValues(alpha: 0.4),
            //             builder: (BuildContext context) {
            //               return confirmationDialog(context, strings);
            //             },
            //           );
            //         }),
            //         child: Text(
            //           strings.cancel,
            //           style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: MColors.black),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ],
    );
  }

  Widget buildOvertimeApproval(AppLocalizations strings, BuildContext context) {
    if (widget.isEmergency ?? false) {
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(strings.overtime_approval, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: MColors.red),
                  onPressed: () => GlobalTap.safeTap(() => Navigator.pop(context)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Theme(
              data: Theme.of(context).copyWith(tabBarTheme: TabBarThemeData(overlayColor: WidgetStateProperty.all(Colors.transparent))),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                dividerColor: MColors.transparent,
                labelColor: MColors.primaryGreen,
                unselectedLabelColor: MColors.textDarkGrey,
                indicatorColor: MColors.primaryGreen,
                tabAlignment: TabAlignment.center,
                labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                unselectedLabelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                tabs: [
                  Tab(child: Text(strings.overtime)),
                  Tab(child: Text(strings.emergency)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: ScreenSizeConfig.height * 0.45),
              child: TabBarView(
                controller: _tabController,
                children: [
                  SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Overtime hours: ${widget.overtimeData?.formattedOverTimeHours ?? ''}",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          strings.overtime_reason,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10, color: MColors.c9190A7, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          (widget.overtimeData?.reason.trim().isNotEmpty ?? false) ? widget.overtimeData!.reason : strings.no_reason_provided,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 16),
                        Consumer<OverTimeDialogViewModel>(
                          builder: (context, provider, child) {
                            final hasImages = provider.imageUrls.isNotEmpty;
                            final hasVoices = provider.voiceUrls.isNotEmpty;

                            if (!hasImages && !hasVoices) {
                              return Center(
                                child: Text(
                                  strings.media_unavailable,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w400, color: MColors.red),
                                ),
                              );
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (hasImages)
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: provider.imageUrls.map((url) {
                                        return InkWell(
                                          onTap: () => GlobalTap.safeTap(() => ImageWidgets.showImageDialog(context, url, provider.imageUrls)),
                                          child: Container(
                                            margin: const EdgeInsets.only(right: 8),
                                            width: 50,
                                            height: 50,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: CachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                if (hasImages) const SizedBox(height: 16),

                                if (hasVoices)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: provider.voiceUrls.map((url) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: AudioPlayerWidget(audioUrl: url),
                                      );
                                    }).toList(),
                                  ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Emergency hours: ${widget.emergencyData?.formattedEmergencyHours ?? ''}",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  border: Border.all(color: MColors.grey.shade400, width: 1),
                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                ),
                                child: Column(
                                  crossAxisAlignment: .start,
                                  children: [
                                    Text(
                                      strings.emergency_reason,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.copyWith(fontSize: 10, color: MColors.c9190A7, fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      (widget.emergencyData?.emergencyReason?.trim().isNotEmpty ?? false)
                                          ? widget.emergencyData?.emergencyReason ?? ''
                                          : strings.no_reason_provided,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Consumer<OverTimeDialogViewModel>(
                          builder: (context, provider, child) {
                            final hasImages = provider.emergencyImageUrls.isNotEmpty;
                            final hasVoices = provider.emergencyVoiceUrls.isNotEmpty;

                            if (!hasImages && !hasVoices) {
                              return Center(
                                child: Text(
                                  strings.media_unavailable,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w400, color: MColors.red),
                                ),
                              );
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (hasImages)
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: provider.emergencyImageUrls.map((url) {
                                        return InkWell(
                                          onTap: () =>
                                              GlobalTap.safeTap(() => ImageWidgets.showImageDialog(context, url, provider.emergencyImageUrls)),
                                          child: Container(
                                            margin: const EdgeInsets.only(right: 8),
                                            width: 50,
                                            height: 50,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: CachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                if (hasImages) const SizedBox(height: 16),

                                if (hasVoices)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: provider.emergencyVoiceUrls.map((url) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: AudioPlayerWidget(audioUrl: url),
                                      );
                                    }).toList(),
                                  ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: .start,
              children: [
                const SizedBox(height: 16),
                Text('Overtime Hours', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFCAE1D4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        ),
                        onPressed: () => GlobalTap.safeTap(() {
                          showHourPickerDialog(
                            context: context,
                            strings: strings,
                            emergencyHours: widget.emergencyData?.formattedEmergencyHours,
                            selectedHour: _selectedOvertimeHours ?? widget.overtimeData!.overtimeHours.toInt(),
                            onHourSelected: (selectedHour) {
                              setState(() => _selectedOvertimeHours = selectedHour);
                            },
                          );
                        }),
                        child: Text(
                          '${_selectedOvertimeHours ?? widget.overtimeData!.overtimeHours.toInt()} Hour${(_selectedOvertimeHours ?? widget.overtimeData!.overtimeHours.toInt()) > 1 ? 's' : ''}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
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
                          await overTimeDialogViewModel.updateOvertimeStatus(
                            context,
                            true,
                            _selectedOvertimeHours ?? widget.overtimeData!.overtimeHours.toInt(),
                          );
                        }),
                        child: Text(
                          strings.approve,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: MColors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => GlobalTap.safeTap(() {
                          overTimeDialogViewModel.updateOvertimeStatus(context, false, null);
                        }),
                        child: Text(
                          strings.reject,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: MColors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(strings.overtime_approval, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: MColors.red),
                  onPressed: () => GlobalTap.safeTap(() => Navigator.pop(context)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              strings.overtime_reason,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10, color: MColors.c9190A7, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 5),
            Text(
              (widget.overtimeData?.reason.trim().isNotEmpty ?? false) ? widget.overtimeData!.reason : strings.no_reason_provided,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Consumer<OverTimeDialogViewModel>(
              builder: (context, provider, child) {
                final hasImages = provider.imageUrls.isNotEmpty;
                final hasVoices = provider.voiceUrls.isNotEmpty;

                if (!hasImages && !hasVoices) {
                  return Center(
                    child: Text(
                      strings.media_unavailable,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w400, color: MColors.red),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasImages)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: provider.imageUrls.map((url) {
                            return InkWell(
                              onTap: () => GlobalTap.safeTap(() => ImageWidgets.showImageDialog(context, url, provider.imageUrls)),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 50,
                                height: 50,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    if (hasImages) const SizedBox(height: 16),

                    if (hasVoices)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: provider.voiceUrls.map((url) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: AudioPlayerWidget(audioUrl: url),
                          );
                        }).toList(),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Text('Overtime Hours', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFCAE1D4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    ),
                    onPressed: () => GlobalTap.safeTap(() {
                      showHourPickerDialog(
                        context: context,
                        strings: strings,
                        emergencyHours: widget.emergencyData?.formattedEmergencyHours,
                        selectedHour: _selectedOvertimeHours ?? widget.overtimeData!.overtimeHours.toInt(),
                        onHourSelected: (selectedHour) {
                          setState(() => _selectedOvertimeHours = selectedHour);
                        },
                      );
                    }),
                    child: Text(
                      '${_selectedOvertimeHours ?? widget.overtimeData!.overtimeHours.toInt()} Hour${(_selectedOvertimeHours ?? widget.overtimeData!.overtimeHours.toInt()) > 1 ? 's' : ''}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
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
                          await overTimeDialogViewModel.updateOvertimeStatus(
                            context,
                            true,
                            _selectedOvertimeHours ?? widget.overtimeData!.overtimeHours.toInt(),
                          );
                        }),
                        child: Text(
                          strings.approve,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: MColors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => GlobalTap.safeTap(() {
                          overTimeDialogViewModel.updateOvertimeStatus(context, false, null);
                        }),
                        child: Text(
                          strings.reject,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: MColors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  Consumer<OverTimeDialogViewModel> buildRecordAudioView(AppLocalizations strings, BuildContext context) {
    return Consumer<OverTimeDialogViewModel>(
      builder: (context, provider, child) {
        final hasMaxRecordings = provider.recordings.length >= Constant.AUDIO_LIMIT;
        return Flexible(
          child: Scrollbar(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!hasMaxRecordings)
                    InkWell(
                      onTap: () => GlobalTap.safeTap(() async {
                        if (!provider.isRecording) {
                          await provider.startRecording();
                        } else {
                          await provider.stopRecording();
                        }
                      }),
                      child: Container(
                        padding: provider.recordings.isEmpty
                            ? const EdgeInsets.symmetric(vertical: 40)
                            : const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: MColors.red, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: provider.recordings.isEmpty
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: MColors.red,
                                    radius: 25,
                                    child: Icon(provider.isRecording ? Icons.stop : Icons.mic, color: MColors.white, size: 28),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    provider.isRecording ? '${strings.recording}...' : strings.record_your_voice_note,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: MColors.red,
                                    radius: 20,
                                    child: Icon(provider.isRecording ? Icons.stop : Icons.mic, color: MColors.white, size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      provider.isRecording ? '${strings.recording}...' : strings.record_your_voice_note,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  if (provider.recordings.isNotEmpty)
                    ListView.builder(
                      itemCount: provider.recordings.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                          child: AudioPlayerWidget(audioPath: provider.recordings[index]),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Consumer<OverTimeDialogViewModel> buildUploadPhotoView(AppLocalizations strings) {
    return Consumer<OverTimeDialogViewModel>(
      builder: (context, provider, child) {
        if (provider.images.isEmpty) {
          return InkWell(
            onTap: () => GlobalTap.safeTap(() {
              showCupertinoModalPopup(
                context: context,
                builder: (ctx) => CupertinoActionSheet(
                  actions: [
                    CupertinoActionSheetAction(
                      child: Text(strings.gallery),
                      onPressed: () => GlobalTap.safeTap(() {
                        Navigator.of(ctx).pop();
                        provider.pickFromGallery(context, false);
                      }),
                    ),
                    CupertinoActionSheetAction(
                      child: Text(strings.camera),
                      onPressed: () => GlobalTap.safeTap(() {
                        Navigator.of(ctx).pop();
                        provider.pickFromGallery(context, true);
                      }),
                    ),
                  ],
                ),
              );
            }),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                border: Border.all(color: MColors.primaryGreen, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(Icons.camera_alt, color: MColors.primaryGreen, size: 32),
                  SizedBox(height: 8),
                  Text(strings.upload_photo, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 5),
                  Text(strings.max_20_images, style: TextStyle(color: MColors.grey)),
                ],
              ),
            ),
          );
        } else {
          return Container(
            width: double.infinity,
            height: 150,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: MColors.primaryGreen, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      ...provider.images.asMap().entries.map((entry) {
                        int index = entry.key;
                        var imageFile = entry.value;
                        return InkWell(
                          onTap: () => GlobalTap.safeTap(
                            () => ImageWidgets.showFileImageDialog(context, imageFile.path, provider.images.map((e) => e.path).toList()),
                          ),
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(File(imageFile.path), width: 40, height: 40, fit: BoxFit.cover),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => GlobalTap.safeTap(() => provider.removeImage(index)),
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(color: MColors.red, shape: BoxShape.circle),
                                      child: const Icon(Icons.close, size: 14, color: MColors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      if (provider.images.length < Constant.IMAGE_LIMIT)
                        GestureDetector(
                          onTap: () => GlobalTap.safeTap(() {
                            showCupertinoModalPopup(
                              context: context,
                              builder: (ctx) => CupertinoActionSheet(
                                actions: [
                                  CupertinoActionSheetAction(
                                    child: Text(strings.gallery),
                                    onPressed: () => GlobalTap.safeTap(() {
                                      Navigator.of(ctx).pop();
                                      provider.pickFromGallery(context, false);
                                    }),
                                  ),
                                  CupertinoActionSheetAction(
                                    child: Text(strings.camera),
                                    onPressed: () => GlobalTap.safeTap(() {
                                      Navigator.of(ctx).pop();
                                      provider.pickFromGallery(context, true);
                                    }),
                                  ),
                                ],
                              ),
                            );
                          }),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(color: MColors.primaryGreen.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                            child: Icon(Icons.add, color: MColors.primaryGreen, size: 30),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(strings.max_20_images, style: TextStyle(color: MColors.grey)),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget confirmationDialog(BuildContext context, AppLocalizations strings) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
      child: Center(
        child: Dialog(
          backgroundColor: MColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  strings.are_you_sure_you_dont_want_to_add_overtime_details,
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
                        onPressed: () => GlobalTap.safeTap(() {
                          Navigator.pop(context);
                          Navigator.pop(context); // Close the dialog and the parent dialog
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

  Future<void> showHourPickerDialog({
    required BuildContext context,
    required AppLocalizations strings,
    required int selectedHour,
    String? emergencyHours,
    required ValueChanged<int> onHourSelected,
  }) async {
    int tempSelectedIndex = selectedHour - 1;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
          child: Dialog(
            backgroundColor: MColors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    strings.overtime_duration,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: MColors.black),
                  ),
                  const SizedBox(height: 16),
                  if (emergencyHours != null) ...[
                    Text(
                      "${strings.emergency_hours}: $emergencyHours",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MColors.black),
                    ),
                    const SizedBox(height: 16),
                  ],
                  SizedBox(
                    height: 150,
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(initialItem: tempSelectedIndex),
                      itemExtent: 40,
                      onSelectedItemChanged: (index) {
                        tempSelectedIndex = index;
                      },
                      children: List.generate(5, (index) {
                        final hour = index + 1;
                        return Center(child: Text("$hour hour${hour > 1 ? 's' : ''}", style: const TextStyle(fontSize: 18)));
                      }),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => GlobalTap.safeTap(() => Navigator.of(ctx).pop()),
                          child: Text(
                            strings.cancel.toUpperCase(),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: MColors.black, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MColors.primaryGreen,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => GlobalTap.safeTap(() {
                            Navigator.of(ctx).pop();
                            onHourSelected(tempSelectedIndex + 1);
                          }),
                          child: Text(
                            strings.approve.toUpperCase(),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: MColors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class AudioPlayerWidget extends StatefulWidget {
  final String? audioUrl;
  final String? audioPath;

  const AudioPlayerWidget({super.key, this.audioUrl, this.audioPath});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late final AudioPlayer _audioPlayer;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;
  bool _isSeeking = false;
  bool _audioLoadError = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.playerStateStream.listen((state) {
      final playing = state.playing;
      if (mounted) {
        setState(() {
          _isPlaying = playing;
          if (state.processingState == ProcessingState.completed) {
            _audioPlayer.seek(Duration.zero);
            _audioPlayer.pause();
          }
        });
      } else {
        Log.e(' Overtime Dialog Audio Player: Context not mounted (playerStateStream)');
      }
    });
    _audioPlayer.durationStream.listen((d) {
      if (mounted)
        setState(() => _duration = d ?? Duration.zero);
      else
        Log.e(' Overtime Dialog Audio Player: Context not mounted (durationStream)');
    });
    _audioPlayer.positionStream.listen((p) {
      if (mounted && !_isSeeking)
        setState(() => _position = p);
      else
        Log.e(' Overtime Dialog Audio Player: Context not mounted (positionStream)');
    });
    if (widget.audioUrl != null) {
      _audioPlayer.setUrl(widget.audioUrl!).catchError((e) {
        setState(() => _audioLoadError = true);
        Log.e('Error loading audio: $e');
        SnackBarMsg.showErrorMessage(context, Helper.getLocalization()!.error_loading_audio);
      });
    }
    if (widget.audioPath != null) {
      _audioPlayer.setFilePath(widget.audioPath!).catchError((e) {
        setState(() => _audioLoadError = true);
        Log.e('Error loading audio file: $e');
        SnackBarMsg.showErrorMessage(context, Helper.getLocalization()!.error_loading_audio_file);
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  String _formatDuration(Duration d) {
    twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    if (_audioLoadError && (widget.audioUrl != null && (context.findAncestorWidgetOfExactType<OvertimeDialog>()?.overtimeData != null))) {
      final strings = Helper.getLocalization()!;
      return Container(
        padding: const EdgeInsets.all(16),
        child: Text(
          strings.media_unavailable,
          style: const TextStyle(color: MColors.red, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      );
    }
    final fileName = widget.audioPath != null ? widget.audioPath!.split('/').last : widget.audioUrl!.split('/').last;
    return Card(
      color: MColors.white,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fileName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle, color: MColors.primaryGreen, size: 25),
                  onPressed: () => GlobalTap.safeTap(_togglePlayPause),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
                      overlayShape: RoundSliderOverlayShape(overlayRadius: 14.0),
                    ),
                    child: Slider(
                      activeColor: MColors.primaryGreen,
                      thumbColor: MColors.primaryGreen,
                      value: _position.inMilliseconds.toDouble().clamp(0.0, _duration.inMilliseconds.toDouble()),
                      min: 0.0,
                      max: _duration.inMilliseconds.toDouble() > 0 ? _duration.inMilliseconds.toDouble() : 1.0,
                      onChanged: (value) {
                        if (mounted) {
                          setState(() {
                            _position = Duration(milliseconds: value.round());
                            _isSeeking = true;
                          });
                        } else {
                          Log.e(' Overtime Dialog Audio Player: Context not mounted (Slider onChanged)');
                        }
                      },
                      onChangeEnd: (value) {
                        _audioPlayer.seek(Duration(milliseconds: value.round()));
                        if (mounted)
                          setState(() => _isSeeking = false);
                        else
                          Log.e(' Overtime Dialog Audio Player: Context not mounted (Slider onChangeEnd)');
                      },
                    ),
                  ),
                ),
                Text('${_formatDuration(_position)} / ${_formatDuration(_duration)}', style: Theme.of(context).textTheme.bodyMedium),
                if (widget.audioPath != null)
                  IconButton(
                    icon: Icon(Icons.delete, color: MColors.red, size: 25),
                    onPressed: () => GlobalTap.safeTap(() {
                      Provider.of<OverTimeDialogViewModel>(context, listen: false).deleteRecording(widget.audioPath!);
                    }),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
