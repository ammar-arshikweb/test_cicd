import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:panamera_app/comman_widget/audio_player_widget.dart';
import 'package:panamera_app/comman_widget/image_widgets.dart';
import 'package:panamera_app/features/employee/attendance/view/clock_in_dialog.dart';
import 'package:panamera_app/features/employee/attendance/view_model/emergency_view_model.dart';
import 'package:panamera_app/gen/assets.gen.dart';
import 'package:panamera_app/l10n/app_localizations.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/global_tap.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/snackbar_messages.dart';
import 'package:panamera_app/utils/time_utils.dart';
import 'package:panamera_app/values/colors.dart';
import 'package:provider/provider.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  late AppLocalizations strings;
  late EmergencyViewModel emergencyViewModel;

  @override
  void initState() {
    super.initState();
    emergencyViewModel = Provider.of<EmergencyViewModel>(context, listen: false);
    emergencyViewModel.initModel(context);
  }

  @override
  void dispose() {
    emergencyViewModel.resetModel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    strings = Helper.getLocalization()!;
    return Scaffold(
      backgroundColor: MColors.greyBackground,
      body: SafeArea(
        child: Consumer<EmergencyViewModel>(
          builder: (context, provider, child) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 50),
                    Text(
                      strings.emergency_check_in_out.toUpperCase(),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 50),
                    _buildClockView(provider),
                    const SizedBox(height: 20),
                    buildTextField(
                      provider,
                      strings.location,
                      TextEditingController(
                        text: provider.currentPosition != null ? '${provider.currentPosition!.latitude}, ${provider.currentPosition!.longitude}' : '',
                      ),
                      isEnabled: false,
                    ),
                    const SizedBox(height: 15),
                    buildTextField(provider, strings.emergency_reason, provider.reasonController, isEnabled: !provider.isBackButtonAvail),
                    const SizedBox(height: 15),
                    buildUploadPhotoView(strings),
                    const SizedBox(height: 16),
                    buildRecordAudioView(strings, context),
                    const SizedBox(height: 20),
                    if (provider.imageUrls.isEmpty && provider.voiceUrls.isEmpty) ...[
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
                                await provider.uploadEmergencyData(context, isOnlyMediaUpload: true);
                              }),
                              child: Text(
                                strings.confirm,
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
                                Navigator.pop(context);
                              }),
                              child: Text(
                                strings.cancel,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: MColors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: MColors.primaryGreen,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                              ),
                              onPressed: () => GlobalTap.safeTap(() {
                                Navigator.pop(context);
                              }),
                              child: Text(
                                strings.back,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: MColors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildTextField(EmergencyViewModel provider, String label, TextEditingController controller, {bool isEnabled = true}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label ${isEnabled ? '*' : ''}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MColors.black, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 5),
        TextField(
          enabled: isEnabled,
          controller: controller,
          style: Theme.of(context).textTheme.bodyMedium,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: MColors.black.withValues(alpha: 0.5), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: MColors.black.withValues(alpha: 0.5), width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: MColors.black.withValues(alpha: 0.5), width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: MColors.primaryGreen, width: 2),
            ),
            isDense: true,
          ),
        ),
      ],
    );
  }

  Widget _buildClockView(EmergencyViewModel provider) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          _buildClockCard(
            label: strings.clock_in.toUpperCase(),
            time:
                '${(provider.clockInTime?.hour ?? 0).toString().padLeft(2, '0')} : '
                '${(provider.clockInTime?.minute ?? 0).toString().padLeft(2, '0')} : '
                '${(provider.clockInTime?.second ?? 0).toString().padLeft(2, '0')}',
            icon: Assets.images.clockIn,
            onTap: () => GlobalTap.safeTap(() {
              if (provider.clockInTime != null) {
                return;
              }
              showClockInOutDialog(context, false);
            }),
          ),
          const SizedBox(width: 15),
          _buildClockCard(
            label: strings.clock_out.toUpperCase(),
            time:
                '${(provider.clockOutTime?.hour ?? 0).toString().padLeft(2, '0')} : '
                '${(provider.clockOutTime?.minute ?? 0).toString().padLeft(2, '0')} : '
                '${(provider.clockOutTime?.second ?? 0).toString().padLeft(2, '0')}',
            icon: Assets.images.clockOut,
            onTap: () => GlobalTap.safeTap(() {
              if (provider.clockOutTime != null) {
                return;
              }
              if (provider.clockInTime == null) {
                SnackBarMsg.showErrorMessage(context, strings.please_check_in_first);
                return;
              }
              if (provider.reasonController.text.trim().isEmpty) {
                SnackBarMsg.showErrorMessage(context, strings.please_enter_emergency_details_first);
                return;
              }
              showClockInOutDialog(context, true);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildClockCard({required String label, required String time, required String icon, VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: MColors.white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [BoxShadow(color: MColors.black12, blurRadius: 4)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(icon, height: 25, width: 25),
              const SizedBox(height: 1),
              Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 1),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [MColors.red, MColors.orange]),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MColors.white, fontWeight: FontWeight.w100, letterSpacing: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Consumer<EmergencyViewModel> buildRecordAudioView(AppLocalizations strings, BuildContext context) {
    return Consumer<EmergencyViewModel>(
      builder: (context, provider, child) {
        if (provider.isBackButtonAvail && provider.voiceUrls.isEmpty) {
          return SizedBox();
        }
        final hasMaxRecordings = provider.recordings.length + provider.voiceUrls.length >= Constant.AUDIO_LIMIT;
        return Flexible(
          child: Scrollbar(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!hasMaxRecordings && provider.voiceUrls.isEmpty)
                    InkWell(
                      onTap: () => GlobalTap.safeTap(() async {
                        if (!provider.isRecording) {
                          await provider.startRecording();
                        } else {
                          await provider.stopRecording();
                        }
                      }),
                      child: Container(
                        padding: provider.recordings.isEmpty && provider.voiceUrls.isEmpty
                            ? const EdgeInsets.symmetric(vertical: 40)
                            : const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: MColors.red, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: provider.recordings.isEmpty && provider.voiceUrls.isEmpty
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
                          child: AudioPlayerWidget(audioPath: provider.recordings[index], provider: provider),
                        );
                      },
                    ),
                  if (provider.voiceUrls.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: provider.voiceUrls.map((url) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AudioPlayerWidget(audioUrl: url, provider: provider),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Consumer<EmergencyViewModel> buildUploadPhotoView(AppLocalizations strings) {
    return Consumer<EmergencyViewModel>(
      builder: (context, provider, child) {
        if (provider.isBackButtonAvail && provider.imageUrls.isEmpty) {
          return SizedBox();
        }
        if (provider.imageUrls.isEmpty && provider.images.isEmpty) {
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
                      ...provider.imageUrls.map((url) {
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
                      ...provider.images.asMap().entries.map((entry) {
                        int index = entry.key;
                        var imageFile = entry.value;
                        return InkWell(
                          onTap: () => GlobalTap.safeTap(
                            () => ImageWidgets.showFileImageDialog(context, imageFile.path, provider.images.map((e) => e.path).toList()),
                          ),
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(File(imageFile.path), width: 50, height: 50, fit: BoxFit.cover),
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
                      if (provider.imageUrls.length + provider.images.length < Constant.IMAGE_LIMIT && provider.imageUrls.isEmpty)
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
                            width: 50,
                            height: 50,
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

  Future<void> showClockInOutDialog(BuildContext context, bool isClockOut) async {
    if (emergencyViewModel.currentPosition == null) {
      SnackBarMsg.showErrorMessage(context, Helper.getLocalization()!.please_allow_location);
      return;
    }
    emergencyViewModel.getLocationAndAddress(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      barrierColor: MColors.black.withValues(alpha: 0.4),
      builder: (BuildContext context) {
        return ClockInOutDialog(time: TimeUtils.getCurrentDateTime(), isClockOut: isClockOut, isEmergency: true);
      },
    );
  }
}
