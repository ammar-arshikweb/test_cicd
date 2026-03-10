import 'dart:io';
import 'package:collection/collection.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:panamera_app/comman_widget/audio_player_widget.dart';
import 'package:panamera_app/comman_widget/custom_dropdown.dart';
import 'package:panamera_app/comman_widget/image_widgets.dart';
import 'package:panamera_app/features/employee/amc/model/amc_job_data_model.dart';
import 'package:panamera_app/features/employee/amc/view_model/add_issue_view_model.dart';
import 'package:panamera_app/features/login/model/emp_login_res.dart';
import 'package:panamera_app/l10n/app_localizations.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/global_tap.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/system_ui_manager.dart';
import 'package:panamera_app/utils/time_utils.dart';
import 'package:panamera_app/values/colors.dart';
import 'package:provider/provider.dart';

class AddIssueScreen extends StatefulWidget {
  final int amcJobId;
  final String gardenTeamLeader;
  final String poolTeamLeader;
  final String supervisorId;
  final AmcIssueModel? issue;

  const AddIssueScreen({
    super.key,
    required this.gardenTeamLeader,
    required this.poolTeamLeader,
    required this.amcJobId,
    this.issue,
    required this.supervisorId,
  });

  @override
  State<AddIssueScreen> createState() => _AddIssueScreenState();
}

class _AddIssueScreenState extends State<AddIssueScreen> {
  late AddIssueViewModel _addIssueViewModel;

  @override
  void initState() {
    super.initState();
    _addIssueViewModel = Provider.of<AddIssueViewModel>(context, listen: false);
    _addIssueViewModel.initModel(context, widget.issue);
  }

  @override
  void dispose() {
    super.dispose();
    _addIssueViewModel.resetModel();
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Consumer<AddIssueViewModel>(
              builder: (context, provider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.issue == null) ...[
                      Text(strings.add_new_issue, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 15),
                    ],
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
                      child: Row(
                        children: [
                          Text(strings.priority, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w600)),
                          Spacer(),
                          if (widget.issue == null) ...[
                            SizedBox(
                              width: 150,
                              child: MCustomDropdown<int>(
                                label: null,
                                labelStyle: null,
                                initialItem: provider.priority,
                                showSearch: false,
                                items: [0, 1, 2],
                                headerBuilder:
                                    (context, item, isSelected) => Text(
                                      item == 0
                                          ? strings.low
                                          : item == 1
                                          ? strings.medium
                                          : strings.high,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MColors.black, fontWeight: FontWeight.w500),
                                    ),
                                listItemBuilder: (context, item, isSelected, onItemSelect) {
                                  final theme = Theme.of(context);
                                  return GestureDetector(
                                    onTap: () => GlobalTap.safeTap(onItemSelect),
                                    child: Container(
                                      color: Colors.transparent,
                                      child: Text(
                                        item == 0
                                            ? strings.low
                                            : item == 1
                                            ? strings.medium
                                            : strings.high,
                                        style: theme.textTheme.bodyMedium?.copyWith(color: MColors.black, fontWeight: FontWeight.normal),
                                      ),
                                    ),
                                  );
                                },
                                onChanged: (value) {
                                  if (value != null) {
                                    provider.setPriority(value);
                                  }
                                },
                              ),
                            ),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    widget.issue!.priority == 0
                                        ? MColors.green.withValues(alpha: 0.2)
                                        : widget.issue!.priority == 1
                                        ? MColors.lightOrange.withValues(alpha: 0.2)
                                        : MColors.red.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                        widget.issue!.priority == 0
                                            ? MColors.green
                                            : widget.issue!.priority == 1
                                            ? MColors.lightOrange
                                            : MColors.red,
                                    radius: 4,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    widget.issue!.priority == 0
                                        ? strings.low.toUpperCase()
                                        : widget.issue!.priority == 1
                                        ? strings.medium.toUpperCase()
                                        : strings.high.toUpperCase(),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color:
                                          widget.issue!.priority == 0
                                              ? MColors.green
                                              : widget.issue!.priority == 1
                                              ? MColors.lightOrange
                                              : MColors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(color: MColors.white, borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${strings.issue_title} *', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 5),
                          TextField(
                            controller: provider.issueTitleController,
                            style: TextStyle(fontWeight: FontWeight.normal),
                            readOnly: widget.issue != null,
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
                              focusedBorder:
                                  (widget.issue != null)
                                      ? OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: MColors.c9190A7, width: 2),
                                      )
                                      : OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: MColors.primaryGreen, width: 2),
                                      ),
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${strings.issue_description} *',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 5),
                          TextField(
                            controller: provider.issueDescController,
                            style: TextStyle(fontWeight: FontWeight.normal),
                            maxLines: 2,
                            textInputAction: TextInputAction.done,
                            readOnly: widget.issue != null,
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
                              focusedBorder:
                                  (widget.issue != null)
                                      ? OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: MColors.c9190A7, width: 2),
                                      )
                                      : OutlineInputBorder(
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
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      decoration: BoxDecoration(color: MColors.white, borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          Text(strings.supervisor, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(width: 15),
                          Expanded(
                            child: MCustomDropdown<EmployeeModel>(
                              enabled: widget.issue == null,
                              label: null,
                              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MColors.white, fontWeight: FontWeight.w600),
                              showSearch: false,
                              hintText: strings.select_supervisor,
                              initialItem:
                                  provider.selectedSupervisor ??
                                  provider.allSupervisorList?.firstWhereOrNull((element) => element.employeeId.toString() == widget.supervisorId),
                              items: provider.allSupervisorList ?? [],
                              onChanged: (supervisor) => provider.setSupervisor(supervisor),
                              headerBuilder: (context, item, isSelected) {
                                return Container(
                                  color: Colors.transparent,
                                  child: Text(
                                    item.toString(),
                                    maxLines: 2,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MColors.black),
                                  ),
                                );
                              },
                              listItemBuilder: (context, item, isSelected, onItemSelect) {
                                return GestureDetector(
                                  onTap: () => GlobalTap.safeTap(onItemSelect),
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Text(
                                      item.toString(),
                                      maxLines: 2,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MColors.black),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                      decoration: BoxDecoration(color: MColors.white, borderRadius: BorderRadius.circular(10)),
                      child:
                          (widget.issue == null) ? buildAddPhotoAudio(strings, context, provider) : buildViewPhotoAudio(strings, context, provider),
                    ),
                    const SizedBox(height: 20),
                    if (widget.issue == null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: MColors.primaryGreen.withValues(alpha: 0.75),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                              ),
                              onPressed:
                                  () => GlobalTap.safeTap(() {
                                    Navigator.of(context).pop();
                                  }),
                              child: Text(
                                strings.cancel,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: MColors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: MColors.lightGreen,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                              ),
                              onPressed:
                                  () => GlobalTap.safeTap(() async {
                                    await _addIssueViewModel.addIssueDetails(context, widget.amcJobId, widget.supervisorId);
                                  }),
                              child: Text(
                                strings.update,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: MColors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Column buildAddPhotoAudio(AppLocalizations strings, BuildContext context, AddIssueViewModel provider) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [buildUploadPhotoView(strings, provider), const SizedBox(height: 16), buildRecordAudioView(strings, context, provider)],
    );
  }

  Column buildViewPhotoAudio(AppLocalizations strings, BuildContext context, AddIssueViewModel provider) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Builder(
          builder: (context) {
            final hasImages = provider.imageUrls.isNotEmpty;
            final hasVoices = provider.voiceUrls.isNotEmpty;

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
                if (hasImages)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          provider.imageUrls.map((url) {
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
                    ),
                  ),
                if (hasImages) const SizedBox(height: 16),

                if (hasVoices)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        provider.voiceUrls.map((url) {
                          return Padding(padding: const EdgeInsets.only(bottom: 8), child: AudioPlayerWidget(audioUrl: url, provider: null));
                        }).toList(),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget buildRecordAudioView(AppLocalizations strings, BuildContext context, AddIssueViewModel provider) {
    final hasMaxRecordings = provider.recordings.length >= Constant.AUDIO_LIMIT;
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
                        if (!provider.isRecording) {
                          await provider.startRecording();
                        } else {
                          await provider.stopRecording();
                        }
                      }),
                  child: Container(
                    padding:
                        provider.recordings.isEmpty
                            ? const EdgeInsets.symmetric(vertical: 40)
                            : const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    decoration: BoxDecoration(border: Border.all(color: MColors.red, width: 2), borderRadius: BorderRadius.circular(12)),
                    child:
                        provider.recordings.isEmpty
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
            ],
          ),
        ),
      ),
    );
  }

  Widget buildUploadPhotoView(AppLocalizations strings, AddIssueViewModel provider) {
    return Builder(
      builder: (context) {
        if (provider.images.isEmpty) {
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
                      ...provider.images.asMap().entries.map((entry) {
                        int index = entry.key;
                        var imageFile = entry.value;
                        return InkWell(
                          onTap:
                              () => GlobalTap.safeTap(
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
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(color: MColors.primaryGreen.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                            child: Icon(Icons.add, color: MColors.primaryGreen, size: 30),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
