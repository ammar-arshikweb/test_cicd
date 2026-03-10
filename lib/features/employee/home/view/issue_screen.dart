import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:panamera_app/comman_widget/audio_player_widget.dart';
import 'package:panamera_app/comman_widget/image_widgets.dart';
import 'package:panamera_app/features/customer/home/model/task_model.dart';
import 'package:panamera_app/features/employee/home/view_model/issue_view_model.dart';
import 'package:panamera_app/l10n/app_localizations.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/global_tap.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/system_ui_manager.dart';
import 'package:panamera_app/utils/time_utils.dart';
import 'package:panamera_app/values/colors.dart';
import 'package:provider/provider.dart';

class IssueScreen extends StatefulWidget {
  final TaskModel task;
  const IssueScreen({super.key, required this.task});

  @override
  State<IssueScreen> createState() => _IssueScreenState();
}

class _IssueScreenState extends State<IssueScreen> {
  AppLocalizations strings = Helper.getLocalization()!;
  late IssueViewModel _taskViewModel;

  @override
  void initState() {
    super.initState();
    _taskViewModel = Provider.of<IssueViewModel>(context, listen: false);
    _taskViewModel.initModel(widget.task);
  }

  @override
  void dispose() {
    _taskViewModel.resetModel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemUIManager.setSystemUI(context: context);
    return Scaffold(
      backgroundColor: MColors.greyBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: MColors.black, size: 30),
          onPressed: () => GlobalTap.safeTap(() => Navigator.of(context).pop()),
        ),
        backgroundColor: MColors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Consumer<IssueViewModel>(
            builder: (context, provider, child) {
              return Column(children: [_buildIssueHeaderSection(provider), _buildCommentsSection(context, provider)]);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildIssueHeaderSection(IssueViewModel provider) {
    return Container(
      width: double.infinity,
      color: MColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          Text(widget.task.taskName ?? '', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w600)),
          if (widget.task.amcJobName != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Text('${strings.amc_job}: ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                Text(widget.task.amcJobName ?? '', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ],
          if (widget.task.villaName != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Text('${strings.villa}: ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                Text(widget.task.villaName ?? '', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ],
          const SizedBox(height: 15),
          Row(
            children: [
              Text('${strings.priority}: ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
              const SizedBox(width: 15),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Helper.convertStatus(module: Constant.taskManagerPriority, number: widget.task.priority)?.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      backgroundColor: Helper.convertStatus(module: Constant.taskManagerPriority, number: widget.task.priority)?.color,
                      radius: 3,
                    ),
                    SizedBox(width: 6),
                    Text(
                      Helper.convertStatus(module: Constant.taskManagerPriority, number: widget.task.priority)?.label ?? '',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Helper.convertStatus(module: Constant.taskManagerPriority, number: widget.task.priority)?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildDueDateChip(),
          const SizedBox(height: 10),
          _buildStatusChip(provider),
          const SizedBox(height: 15),
          _buildIssueDescriptionSection(provider),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildDueDateChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: MColors.green.withValues(alpha: 0.1), border: Border.all(color: MColors.green, width: 0.5)),
      child: Text(
        '${strings.due_date} : ${DateFormat(Constant.dd_MM_yyyy).format(DateTime.parse(widget.task.dueDate ?? ''))}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildStatusChip(IssueViewModel provider) {
    int status = provider.currentTaskStatus;
    return InkWell(
      onTap:
          () => GlobalTap.safeTap(() async {
            if (status == Constant.AMC_JOB_TASK_CLOSED) return;
            await showStatusPickerDialog(
              context: context,
              strings: strings,
              selectedStatus: status, // current status
              onStatusSelected: (newStatus) {
                _taskViewModel.updateIssueStatus(context, widget.task.id!, newStatus, widget.task);
              },
            );
          }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 4),
        decoration: BoxDecoration(
          color: Helper.convertStatus(module: Constant.taskManager, number: status)?.color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: Helper.convertStatus(module: Constant.taskManager, number: status)?.color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              Helper.convertStatus(module: Constant.taskManager, number: status)?.label ?? '',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIssueDescriptionSection(IssueViewModel provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(strings.description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: MColors.cF7F7F7,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: MColors.cCACACA.withValues(alpha: 0.3)),
          ),
          child: Text(widget.task.notes ?? '', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MColors.black)),
        ),
        const SizedBox(height: 10),
        buildViewPhotoAudio(strings, context, provider),
      ],
    );
  }

  Column buildViewPhotoAudio(AppLocalizations strings, BuildContext context, IssueViewModel provider) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Builder(
          builder: (context) {
            final hasImages = provider.taskImageUrls.isNotEmpty;
            final hasVoices = provider.taskVoiceUrls.isNotEmpty;

            if (!hasImages && !hasVoices) {
              return Center(
                child: Text(
                  strings.no_media_attached,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w400, color: MColors.red),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasVoices)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        provider.taskVoiceUrls.map((url) {
                          return Padding(padding: const EdgeInsets.only(bottom: 8), child: AudioPlayerWidget(audioUrl: url, provider: null));
                        }).toList(),
                  ),
                if (hasVoices) const SizedBox(height: 10),
                if (hasImages) ...[
                  Text(strings.images, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 5),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          provider.taskImageUrls.map((url) {
                            return InkWell(
                              onTap: () => GlobalTap.safeTap(() => ImageWidgets.showImageDialog(context, url, provider.taskImageUrls)),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 50,
                                height: 50,
                                child: ClipRRect(borderRadius: BorderRadius.circular(8), child: CachedNetworkImage(imageUrl: url, fit: BoxFit.cover)),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildCommentsSection(BuildContext context, IssueViewModel provider) {
    return Container(
      color: MColors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(strings.comments, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            _buildCommentsAudioSection(context, provider),
            const SizedBox(height: 10),
            buildCommentsImageSection(provider),
            if (provider.images.isNotEmpty || provider.recordings.isNotEmpty) ...[
              const SizedBox(height: 15),
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
                              await provider.addComments(context, widget.task.id!);
                            }),
                        child: Text(
                          strings.update,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: MColors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsAudioSection(BuildContext context, IssueViewModel provider) {
    final hasMaxRecordings = provider.recordings.length + provider.comments.where((c) => c.attachmentType == 1).length >= Constant.AUDIO_LIMIT;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!hasMaxRecordings && provider.currentTaskStatus != 1)
            InkWell(
              onTap:
                  () => GlobalTap.safeTap(() async {
                    if (!provider.isRecording) {
                      await provider.startRecording();
                    } else {
                      await provider.stopRecording();
                    }
                  }),
              child: Container(
                padding:
                    provider.recordings.isEmpty && provider.comments.where((c) => c.attachmentType == 1).isEmpty
                        ? const EdgeInsets.symmetric(vertical: 40)
                        : const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                decoration: BoxDecoration(border: Border.all(color: MColors.red, width: 2), borderRadius: BorderRadius.circular(12)),
                child:
                    provider.recordings.isEmpty && provider.comments.where((c) => c.attachmentType == 1).isEmpty
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
          const SizedBox(height: 5),
          if (provider.recordings.isNotEmpty)
            ListView.builder(
              itemCount: provider.recordings.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final timestamp = DateTime.now();
                final formattedTime = TimeUtils.convertDateTimeTo(timestamp.toString(), Constant.dd_MM_yyyy_hh_mm_a);
                return AudioPlayerWithTitleWidget(audioPath: provider.recordings[index], provider: provider, title: 'You', timestamp: formattedTime);
              },
            ),
          if (provider.comments.where((c) => c.attachmentType == 1).isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  provider.comments.where((c) => c.attachmentType == 1).map((comment) {
                    final formattedTime = TimeUtils.convertDateTimeTo(comment.createdAt, Constant.dd_MM_yyyy_hh_mm_a);
                    return AudioPlayerWithTitleWidget(
                      audioUrl: comment.path,
                      provider: provider,
                      title: comment.employeeName ?? '',
                      timestamp: formattedTime,
                    );
                  }).toList(),
            ),
        ],
      ),
    );
  }

  Widget buildCommentsImageSection(IssueViewModel provider) {
    final imageUrls = provider.comments.where((c) => c.attachmentType == 0).map((c) => c.path!).toList();
    return Builder(
      builder: (context) {
        if (provider.comments.where((c) => c.attachmentType == 0).isEmpty && provider.images.isEmpty && provider.currentTaskStatus != 1) {
          return InkWell(
            onTap:
                () => GlobalTap.safeTap(() {
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
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.images, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      ...provider.comments.where((c) => c.attachmentType == 0).map((url) {
                        return InkWell(
                          onTap: () => GlobalTap.safeTap(() => ImageWidgets.showImageDialog(context, url.path!, imageUrls)),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 50,
                            height: 50,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(imageUrl: url.path!, fit: BoxFit.cover),
                            ),
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
                      if (provider.comments.where((c) => c.attachmentType == 0).length + provider.images.length < Constant.IMAGE_LIMIT &&
                          provider.currentTaskStatus != 1)
                        GestureDetector(
                          onTap:
                              () => GlobalTap.safeTap(() {
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

  Future<void> showStatusPickerDialog({
    required BuildContext context,
    required AppLocalizations strings,
    required int selectedStatus,
    required ValueChanged<int> onStatusSelected,
  }) async {
    // New chronology order (but storing original index along with label)
    final reordered = [
      {"label": "Open", "index": 0},
      {"label": "In-Progress", "index": 3},
      {"label": "Awaiting Gate Pass", "index": 4},
      {"label": "On Hold", "index": 2},
      {"label": "Closed", "index": 1},
    ];

    // Find current position in reordered list
    int tempSelectedIndex = reordered.indexWhere((e) => e["index"] == selectedStatus);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
          child: Dialog(
            backgroundColor: MColors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.update_task_status,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: MColors.black),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${strings.note}: ${strings.comments_cannot_be_added_after_the_status_is_closed}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MColors.black),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 150,
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(initialItem: tempSelectedIndex),
                          itemExtent: 40,
                          onSelectedItemChanged: (index) {
                            setState(() {
                              tempSelectedIndex = index;
                            });
                          },
                          children:
                              reordered
                                  .map((status) => Center(child: Text(status["label"] as String, style: const TextStyle(fontSize: 18))))
                                  .toList(),
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
                                backgroundColor:
                                    reordered[tempSelectedIndex]["index"] == selectedStatus
                                        ? MColors.grey.withValues(alpha: 0.5)
                                        : MColors.primaryGreen,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed:
                                  reordered[tempSelectedIndex]["index"] == selectedStatus
                                      ? null
                                      : () => GlobalTap.safeTap(() {
                                        onStatusSelected(reordered[tempSelectedIndex]["index"] as int);
                                      }),
                              child: Text(
                                strings.update.toUpperCase(),
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: MColors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
