import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:panamera_app/comman_widget/confirmation_dialog.dart';
import 'package:panamera_app/features/employee/amc/model/amc_model.dart';
import 'package:panamera_app/features/employee/amc/view/comments_photo_screen.dart';
import 'package:panamera_app/features/employee/amc/view/issues_screen.dart';
import 'package:panamera_app/features/employee/amc/view/maintenance_screen.dart';
import 'package:panamera_app/features/employee/amc/view_model/job_detail_view_model.dart';
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

class JobDetailScreen extends StatefulWidget {
  final AmcJob job;

  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  late JobDetailViewModel _jobDetailViewModel;

  @override
  void initState() {
    super.initState();
    _jobDetailViewModel = Provider.of<JobDetailViewModel>(context, listen: false);
    _jobDetailViewModel.initModel(context, widget.job.amcJobId);
  }

  @override
  void dispose() {
    super.dispose();
    _jobDetailViewModel.resetModel();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations strings = Helper.getLocalization()!;
    SystemUIManager.setSystemUI(context: context);
    List<JobCategory> categories = [
      if (widget.job.visitType == Constant.VISIT_TYPE_GARDEN) JobCategory(iconPath: Assets.images.garden, title: strings.garden_maintenance),
      if (widget.job.visitType == Constant.VISIT_TYPE_POOL) JobCategory(iconPath: Assets.images.pool, title: strings.pool_maintenance),
      JobCategory(iconPath: Assets.images.photo, title: strings.comments_and_photos),
      JobCategory(iconPath: Assets.images.issue, title: strings.issues),
    ];

    return Consumer<JobDetailViewModel>(
      builder: (context, provider, child) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            Navigator.of(context).pop(provider.isStatusChanged);
          },
          child: Scaffold(
            backgroundColor: MColors.greyBackground,
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.chevron_left, color: MColors.black, size: 30),
                onPressed: () => GlobalTap.safeTap(() => Navigator.of(context).pop(provider.isStatusChanged)),
              ),
              backgroundColor: MColors.white,
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(widget.job.amcJobName, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    if (provider.jobData != null) ...[
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 5,
                            backgroundColor: Helper.convertStatus(module: Constant.amcJobs, number: provider.jobData!.amcJobStatus)?.color,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            Helper.convertStatus(module: Constant.amcJobs, number: provider.jobData!.amcJobStatus)?.label ?? '',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MColors.textDarkGrey, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (widget.job.visitType == Constant.VISIT_TYPE_GARDEN) ...[
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(border: Border.all(color: MColors.grey, width: 1), borderRadius: BorderRadius.circular(5)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(strings.garden, style: TextStyle(color: MColors.green)),
                                    SizedBox(height: 2),
                                    Text(
                                      'SV- ${provider.jobData!.gardenSupervisorName}',
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.copyWith(color: MColors.textDarkGrey, fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      'TL- ${provider.jobData!.gardenTeamLeaderName}',
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.copyWith(color: MColors.textDarkGrey, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                          ],
                          if (widget.job.visitType == Constant.VISIT_TYPE_POOL)
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(border: Border.all(color: MColors.grey, width: 1), borderRadius: BorderRadius.circular(5)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(strings.pool, style: TextStyle(color: MColors.blue)),
                                    SizedBox(height: 2),
                                    Text(
                                      'SV- ${provider.jobData!.poolSupervisorName}',
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.copyWith(color: MColors.textDarkGrey, fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      'TL- ${provider.jobData!.poolTeamLeaderName}',
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.copyWith(color: MColors.textDarkGrey, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (provider.jobData != null && provider.jobData!.amcJobStatus == 0)
                      _buildBigButton(
                        text: strings.start_work,
                        onPressed:
                            () => GlobalTap.safeTap(() {
                              simpleConfirmationDialog(
                                context: context,
                                title: strings.are_you_sure_you_want_to_start_work,
                                strings: strings,
                                onConfirm: () {
                                  _jobDetailViewModel.updateJobStatus(context, 1, true);
                                },
                              );
                            }),
                      ),
                    SizedBox(height: ScreenSizeConfig.height * 0.04),
                    Container(
                      decoration: BoxDecoration(color: MColors.white, borderRadius: BorderRadius.circular(5)),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          return _JobItem(
                            category: categories[index],
                            onTap:
                                () => GlobalTap.safeTap(() {
                                  final jobData = _jobDetailViewModel.jobData!;
                                  if (_jobDetailViewModel.jobData == null) {
                                    return;
                                  }
                                  if (jobData.amcJobStatus == 0) {
                                    SnackBarMsg.showErrorMessage(context, strings.please_start_work_to_go_ahead);
                                    return;
                                  }
                                  if (index == 1) {
                                    Navigator.of(context)
                                        .push(
                                          MaterialPageRoute(
                                            builder:
                                                (BuildContext context) => CommentsPhotoScreen(
                                                  amcJobId: jobData.amcJobId,
                                                  amcCommentDetail: jobData.comments,
                                                  gardenTeamLeader: jobData.gardenTeamLeaderName,
                                                  poolTeamLeader: jobData.poolTeamLeaderName,
                                                  status: jobData.amcJobStatus,
                                                ),
                                          ),
                                        )
                                        .then((v) {
                                          if (v != null && v == true) {
                                            _jobDetailViewModel.getJobDetail(context, widget.job.amcJobId);
                                          }
                                        });
                                  } else if (index == 2) {
                                    var supervisorId;
                                    if (widget.job.visitType == Constant.VISIT_TYPE_GARDEN) {
                                      supervisorId = provider.jobData!.gardenSupervisorId;
                                    } else {
                                      supervisorId = provider.jobData!.poolSupervisorId;
                                    }
                                    Navigator.of(context)
                                        .push(
                                          MaterialPageRoute(
                                            builder:
                                                (BuildContext context) => IssuesScreen(
                                                  issuesList: jobData.issues,
                                                  amcJobName: jobData.amcJobName,
                                                  gardenTeamLeader: jobData.gardenTeamLeaderName,
                                                  poolTeamLeader: jobData.poolTeamLeaderName,
                                                  amcJobId: jobData.amcJobId,
                                                  status: jobData.amcJobStatus,
                                                  supervisorId: supervisorId,
                                                ),
                                          ),
                                        )
                                        .then((v) {
                                          if (v != null && v == true) {
                                            _jobDetailViewModel.getJobDetail(context, widget.job.amcJobId, isFirstTime: true);
                                          }
                                        });
                                  } else {
                                    final isGarden = widget.job.visitType == Constant.VISIT_TYPE_GARDEN;
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder:
                                            (BuildContext context) => MaintenanceScreen(
                                              tasksList: isGarden ? jobData.gardenTask : jobData.poolTask,
                                              title: categories[index].title,
                                              status: jobData.amcJobStatus,
                                              isGarden: isGarden,
                                            ),
                                      ),
                                    );
                                  }
                                }),
                          );
                        },
                        separatorBuilder: (context, index) => Divider(height: 1, color: MColors.grey.withValues(alpha: 0.5), indent: 8, endIndent: 8),
                      ),
                    ),
                    SizedBox(height: ScreenSizeConfig.height * 0.08),
                    if (provider.jobData != null && provider.jobData!.amcJobStatus == 1)
                      _buildBigButton(
                        text: strings.end_work,
                        onPressed:
                            () => GlobalTap.safeTap(() {
                              final tasks =
                                  widget.job.visitType == Constant.VISIT_TYPE_GARDEN ? provider.jobData!.gardenTask : provider.jobData!.poolTask;
                              final hasCompletedTask = tasks.any((t) => t.status == 1);
                              final hasPhotos = provider.jobData!.comments.imageUrls.isNotEmpty;

                              if (!hasCompletedTask || !hasPhotos) {
                                return SnackBarMsg.showErrorMessage(context, strings.please_complete_task_or_update_photos_to_end_work);
                              }
                              simpleConfirmationDialog(
                                context: context,
                                title: strings.are_you_sure_you_want_to_end_work,
                                strings: strings,
                                onConfirm: () {
                                  _jobDetailViewModel.updateJobStatus(context, 2, false);
                                },
                              );
                            }),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBigButton({required String text, required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(color: MColors.primaryGreen, borderRadius: BorderRadius.circular(8)),
      child: TextButton(
        onPressed: onPressed,
        child: Text(text, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: MColors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _JobItem extends StatelessWidget {
  final JobCategory category;
  final VoidCallback? onTap;

  const _JobItem({required this.category, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      leading: SvgPicture.asset(category.iconPath, height: 30, width: 30),
      title: Text(category.title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
    );
  }
}
