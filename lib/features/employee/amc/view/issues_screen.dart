import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:panamera_app/comman_widget/custom_loader.dart';
import 'package:panamera_app/features/employee/amc/model/amc_job_data_model.dart';
import 'package:panamera_app/features/employee/amc/repository/amc_repo.dart';
import 'package:panamera_app/features/employee/amc/view/add_issue_screen.dart';
import 'package:panamera_app/l10n/app_localizations.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/global_tap.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/log_utils.dart';
import 'package:panamera_app/utils/system_ui_manager.dart';
import 'package:panamera_app/utils/time_utils.dart';
import 'package:panamera_app/values/colors.dart';

class IssuesScreen extends StatefulWidget {
  final List<AmcIssueModel> issuesList;
  final String amcJobName;
  final String gardenTeamLeader;
  final String poolTeamLeader;
  final String supervisorId;
  final int amcJobId;
  final int status;

  const IssuesScreen({
    super.key,
    required this.issuesList,
    required this.amcJobName,
    required this.gardenTeamLeader,
    required this.poolTeamLeader,
    required this.amcJobId,
    required this.status,
    required this.supervisorId,
  });

  @override
  State<IssuesScreen> createState() => _IssuesScreenState();
}

class _IssuesScreenState extends State<IssuesScreen> {
  @override
  Widget build(BuildContext context) {
    AppLocalizations strings = Helper.getLocalization()!;
    SystemUIManager.setSystemUI(context: context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(true);
      },
      child: Scaffold(
        backgroundColor: MColors.greyBackground,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, color: MColors.black, size: 30),
            onPressed: () => GlobalTap.safeTap(() => Navigator.of(context).pop(true)),
          ),
          backgroundColor: MColors.white,
          actions: [
            if (widget.status != Constant.AMC_JOB_COMPLETED)
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: MColors.black, size: 25),
                onPressed:
                    () => GlobalTap.safeTap(() {
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder:
                                  (BuildContext context) => AddIssueScreen(
                                    gardenTeamLeader: widget.gardenTeamLeader,
                                    poolTeamLeader: widget.poolTeamLeader,
                                    amcJobId: widget.amcJobId,
                                    supervisorId: widget.supervisorId,
                                  ),
                            ),
                          )
                          .then((v) {
                            if (v != null) {
                              widget.issuesList.add(v);
                              setState(() {}); // Refresh the issues list after adding a new issue
                            }
                          });
                    }),
              ),
          ],
          actionsPadding: const EdgeInsets.only(right: 10),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(strings.issues, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 15),
                      Text(
                        widget.amcJobName,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: MColors.textDarkGrey, fontWeight: FontWeight.w600),
                      ),
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
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Expanded(
                  child:
                      widget.issuesList.isEmpty
                          ? Center(child: Text(strings.no_data_found))
                          : ListView.builder(
                            itemCount: widget.issuesList.length,
                            itemBuilder: (context, index) {
                              return _buildTask(strings, widget.issuesList[index], () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (BuildContext context) => AddIssueScreen(
                                          gardenTeamLeader: widget.gardenTeamLeader,
                                          poolTeamLeader: widget.poolTeamLeader,
                                          amcJobId: widget.amcJobId,
                                          issue: widget.issuesList[index],
                                          supervisorId: widget.supervisorId,
                                        ),
                                  ),
                                );
                              });
                            },
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTask(AppLocalizations strings, AmcIssueModel issue, VoidCallback onTap) {
    return InkWell(
      onTap: () => GlobalTap.safeTap(onTap),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(color: MColors.white),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          title: Text(issue.title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          trailing: InkWell(
            onTap:
                () => GlobalTap.safeTap(() async {
                  if (widget.status == Constant.AMC_JOB_COMPLETED) return;
                  if (issue.status == Constant.AMC_JOB_TASK_CLOSED) return;
                  await showStatusPickerDialog(
                    context: context,
                    strings: strings,
                    selectedStatus: issue.status, // current status
                    onStatusSelected: (newStatus) {
                      updateIssueStatus(context, issue.issueId, newStatus, issue);
                    },
                  );
                }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Helper.convertStatus(module: Constant.taskManager, number: issue.status)?.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(backgroundColor: Helper.convertStatus(module: Constant.taskManager, number: issue.status)?.color, radius: 4),
                  SizedBox(width: 6),
                  Text(
                    Helper.convertStatus(module: Constant.taskManager, number: issue.status)?.label ?? '',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Helper.convertStatus(module: Constant.taskManager, number: issue.status)?.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> updateIssueStatus(BuildContext context, int issueId, int status, AmcIssueModel issue) async {
    try {
      context.showLoader();

      final apiRes = await AmcRepo().updateIssueStatus(issueId, status);

      if (apiRes.status == true) {
        setState(() {
          issue.status = status;
        });
        Log.e('task status updated successfully: $issueId');
      } else {
        Log.e('Failed to update task status: ${apiRes.errorMessage}');
      }
    } catch (e) {
      Log.e('Error updating task status: $e');
    } finally {
      Navigator.of(context).pop();
      context.hideLoader();
    }
  }

  Future<void> showStatusPickerDialog({
    required BuildContext context,
    required AppLocalizations strings,
    required int selectedStatus,
    required ValueChanged<int> onStatusSelected,
  }) async {
    // Original order mapping (index must remain same)
    final statuses = [
      "Open", // 0
      "Closed", // 1
      "On Hold", // 2
      "In-Progress", // 3
      "Awaiting Gate Pass", // 4
    ];

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
