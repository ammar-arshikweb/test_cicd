import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:panamera_app/comman_widget/audio_player_widget.dart';
import 'package:panamera_app/comman_widget/image_widgets.dart';
import 'package:panamera_app/features/employee/amc/model/amc_job_data_model.dart';
import 'package:panamera_app/features/employee/amc/view_model/comments_photo_view_model.dart';
import 'package:panamera_app/l10n/app_localizations.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/global_tap.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/system_ui_manager.dart';
import 'package:panamera_app/utils/time_utils.dart';
import 'package:panamera_app/values/colors.dart';
import 'package:provider/provider.dart';

class CommentsPhotoScreen extends StatefulWidget {
  final int amcJobId;
  final AmcCommentModel amcCommentDetail;
  final String gardenTeamLeader;
  final String poolTeamLeader;
  final int status;

  const CommentsPhotoScreen({
    super.key,
    required this.amcJobId,
    required this.amcCommentDetail,
    required this.gardenTeamLeader,
    required this.status,
    required this.poolTeamLeader,
  });

  @override
  State<CommentsPhotoScreen> createState() => _CommentsPhotoScreenState();
}

class _CommentsPhotoScreenState extends State<CommentsPhotoScreen> {
  late CommentsPhotoViewModel _commentsPhotoViewModel;

  @override
  void initState() {
    super.initState();
    _commentsPhotoViewModel = Provider.of<CommentsPhotoViewModel>(context, listen: false);
    _commentsPhotoViewModel.initModel(context, widget.amcJobId, widget.amcCommentDetail);
  }

  @override
  void dispose() {
    super.dispose();
    _commentsPhotoViewModel.resetModel();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations strings = Helper.getLocalization()!;
    SystemUIManager.setSystemUI(context: context);
    return Scaffold(
      backgroundColor: MColors.greyBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: MColors.black, size: 30),
          onPressed: () => GlobalTap.safeTap(() => Navigator.of(context).pop()),
        ),
        backgroundColor: MColors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: SingleChildScrollView(
            child: Consumer<CommentsPhotoViewModel>(
              builder: (context, provider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(strings.comments_and_photos, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Text(
                          strings.date,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MColors.textDarkGrey, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(width: 20),
                        Text(
                          TimeUtils.getCurrentDateTimeInLocal(Constant.dd_MM_yyyy_slash),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    if (widget.gardenTeamLeader.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        '${strings.garden} TL : ${widget.gardenTeamLeader}',
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                      ),
                    ],
                    if (widget.poolTeamLeader.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        '${strings.pool} TL : ${widget.poolTeamLeader}',
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                      ),
                    ],
                    const SizedBox(height: 15),
                    Divider(color: MColors.textDarkGrey, thickness: 0.5),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(color: MColors.white, borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(strings.comment, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 5),
                          TextField(
                            readOnly: widget.status == Constant.AMC_JOB_COMPLETED,
                            controller: provider.commentController,
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                      decoration: BoxDecoration(color: MColors.white, borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [buildUploadPhotoView(strings), const SizedBox(height: 16), buildRecordAudioView(strings, context)],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (widget.status != Constant.AMC_JOB_COMPLETED)
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: MColors.primaryGreen,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                ),
                                onPressed:
                                    () => GlobalTap.safeTap(() async {
                                      await _commentsPhotoViewModel.addCommentDetails(context, widget.amcJobId);
                                    }),
                                child: Text(
                                  strings.confirm,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: MColors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Consumer<CommentsPhotoViewModel> buildRecordAudioView(AppLocalizations strings, BuildContext context) {
    return Consumer<CommentsPhotoViewModel>(
      builder: (context, provider, child) {
        final hasMaxRecordings = provider.recordings.length + provider.voiceUrls.length >= Constant.AUDIO_LIMIT;
        return Flexible(
          child: Scrollbar(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!hasMaxRecordings)
                    InkWell(
                      onTap:
                          () => GlobalTap.safeTap(() async {
                            if (widget.status == Constant.AMC_JOB_COMPLETED) {
                              return;
                            }
                            if (!provider.isRecording) {
                              await provider.startRecording();
                            } else {
                              await provider.stopRecording();
                            }
                          }),
                      child: Container(
                        padding:
                            provider.recordings.isEmpty && provider.voiceUrls.isEmpty
                                ? const EdgeInsets.symmetric(vertical: 40)
                                : const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        decoration: BoxDecoration(border: Border.all(color: MColors.red, width: 2), borderRadius: BorderRadius.circular(12)),
                        child:
                            provider.recordings.isEmpty && provider.voiceUrls.isEmpty
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
                      children:
                          provider.voiceUrls.map((url) {
                            return Padding(padding: const EdgeInsets.only(bottom: 8), child: AudioPlayerWidget(audioUrl: url, provider: provider));
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

  Consumer<CommentsPhotoViewModel> buildUploadPhotoView(AppLocalizations strings) {
    return Consumer<CommentsPhotoViewModel>(
      builder: (context, provider, child) {
        if (provider.imageUrls.isEmpty && provider.images.isEmpty) {
          return InkWell(
            onTap:
                () => GlobalTap.safeTap(() {
                  if (widget.status == Constant.AMC_JOB_COMPLETED) {
                    return;
                  }
                  showCupertinoModalPopup(
                    context: context,
                    builder:
                        (ctx) => CupertinoActionSheet(
                          actions: [
                            CupertinoActionSheetAction(
                              child: Text(strings.gallery),
                              onPressed:
                                  () => GlobalTap.safeTap(() {
                                    Navigator.of(ctx).pop();
                                    provider.pickFromGallery(context, false);
                                  }),
                            ),
                            CupertinoActionSheetAction(
                              child: Text(strings.camera),
                              onPressed:
                                  () => GlobalTap.safeTap(() {
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
              decoration: BoxDecoration(border: Border.all(color: MColors.primaryGreen, width: 2), borderRadius: BorderRadius.circular(8)),
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
            decoration: BoxDecoration(border: Border.all(color: MColors.primaryGreen, width: 2), borderRadius: BorderRadius.circular(8)),
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
                            child: ClipRRect(borderRadius: BorderRadius.circular(8), child: CachedNetworkImage(imageUrl: url, fit: BoxFit.cover)),
                          ),
                        );
                      }).toList(),
                      ...provider.images.asMap().entries.map((entry) {
                        int index = entry.key;
                        var imageFile = entry.value;
                        return InkWell(
                          onTap:
                              () => GlobalTap.safeTap(
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
                      if (provider.imageUrls.length + provider.images.length < Constant.IMAGE_LIMIT)
                        GestureDetector(
                          onTap:
                              () => GlobalTap.safeTap(() {
                                if (widget.status == Constant.AMC_JOB_COMPLETED) {
                                  return;
                                }
                                showCupertinoModalPopup(
                                  context: context,
                                  builder:
                                      (ctx) => CupertinoActionSheet(
                                        actions: [
                                          CupertinoActionSheetAction(
                                            child: Text(strings.gallery),
                                            onPressed:
                                                () => GlobalTap.safeTap(() {
                                                  Navigator.of(ctx).pop();
                                                  provider.pickFromGallery(context, false);
                                                }),
                                          ),
                                          CupertinoActionSheetAction(
                                            child: Text(strings.camera),
                                            onPressed:
                                                () => GlobalTap.safeTap(() {
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
                  Align(alignment: Alignment.centerLeft, child: Text(strings.max_20_images, style: TextStyle(color: MColors.grey))),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
