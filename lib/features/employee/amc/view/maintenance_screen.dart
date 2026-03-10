import 'package:flutter/material.dart';
import 'package:panamera_app/comman_widget/custom_loader.dart';
import 'package:panamera_app/comman_widget/confirmation_dialog.dart';
import 'package:panamera_app/features/employee/amc/model/amc_job_data_model.dart';
import 'package:panamera_app/features/employee/amc/repository/amc_repo.dart';
import 'package:panamera_app/l10n/app_localizations.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/global_tap.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/log_utils.dart';
import 'package:panamera_app/utils/system_ui_manager.dart';
import 'package:panamera_app/values/colors.dart';

class MaintenanceScreen extends StatefulWidget {
  final List<AmcTaskModel> tasksList;
  final String title;
  final int status;
  final bool isGarden;
  const MaintenanceScreen({super.key, required this.tasksList, required this.title, required this.status, required this.isGarden});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Map<String, List<AmcTaskModel>> categorizedTasks;
  late List<String> categories;

  @override
  void initState() {
    super.initState();
    if (widget.isGarden) _categorizeTasks();
    if (widget.isGarden) _tabController = TabController(length: categories.length, vsync: this);
  }

  @override
  void dispose() {
    if (widget.isGarden) _tabController.dispose();
    super.dispose();
  }

  void _categorizeTasks() {
    categorizedTasks = <String, List<AmcTaskModel>>{};

    // Define the order of categories
    const List<String> categoryOrder = ['Daily', 'Weekly', 'Monthly', 'Seasonal', 'Special'];

    // Initialize empty lists for each category
    for (String category in categoryOrder) {
      categorizedTasks[category] = <AmcTaskModel>[];
    }

    // Group tasks by category
    for (AmcTaskModel task in widget.tasksList) {
      String category = task.category;
      if (categorizedTasks.containsKey(category)) {
        categorizedTasks[category]!.add(task);
      } else {
        // If category doesn't exist in predefined list, add it
        categorizedTasks[category] = [task];
      }
    }

    // Remove empty categories and create final list
    categories = categorizedTasks.entries.where((entry) => entry.value.isNotEmpty).map((entry) => entry.key).toList();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations strings = Helper.getLocalization()!;
    SystemUIManager.setSystemUI(context: context);
    return Scaffold(
      backgroundColor: MColors.greyBackground,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.chevron_left, color: MColors.black, size: 30), onPressed: () => GlobalTap.safeTap(() => Navigator.of(context).pop())),
        backgroundColor: MColors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(widget.title, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Row(
                  children: [
                    CircleAvatar(radius: 5, backgroundColor: Helper.convertStatus(module: Constant.amcJobs ,number:widget.status)?.color),
                    const SizedBox(width: 8),
                    Text(
                      Helper.convertStatus(module: Constant.amcJobs ,number: widget.status)?.label ?? '',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MColors.textDarkGrey, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (widget.tasksList.isEmpty) ...[
                Center(child: Text(strings.no_tasks_found, style: TextStyle(fontSize: 16, color: MColors.textDarkGrey))),
              ] else ...[
                if (widget.isGarden) ...[
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    dividerColor: MColors.transparent,
                    labelColor: MColors.primaryGreen,
                    unselectedLabelColor: MColors.textDarkGrey,
                    indicatorColor: MColors.primaryGreen,
                    labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    unselectedLabelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    tabs: categories.map((category) => Tab(child: Text(category))).toList(),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children:
                          categories
                              .map(
                                (category) => ListView.builder(
                                  itemCount: categorizedTasks[category]?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    return _buildTask(categorizedTasks[category]![index], strings);
                                  },
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.tasksList.length,
                      itemBuilder: (context, index) {
                        return _buildTask(widget.tasksList[index], strings);
                      },
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTask(AmcTaskModel task, AppLocalizations strings) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: MColors.white),
      child: ListTile(
        leading: Transform.scale(
          scale: 1.2,
          child: Checkbox(
            value: task.status == Constant.AMC_JOB_TASK_CLOSED ? true : false,
            onChanged: (bool? value) {
              if (value != null) {
                if (task.status == Constant.AMC_JOB_TASK_CLOSED || widget.status == Constant.AMC_JOB_COMPLETED) {
                  return;
                }
                simpleConfirmationDialog(
                  context: context,
                  title: strings.are_you_sure_you_want_to_close_the_task,
                  strings: strings,
                  onConfirm: () {
                    updateJobTaskStatus(context, task.visitTaskId, value ? 1 : 0, task);
                  },
                );
              }
            },
            activeColor: MColors.primaryGreen,
          ),
        ),
        title: Text(task.taskName, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: task.status == Constant.AMC_JOB_TASK_OPEN ? MColors.green.withValues(alpha: 0.2) : MColors.red.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(backgroundColor: task.status == Constant.AMC_JOB_TASK_OPEN ? MColors.green : MColors.red, radius: 4),
              SizedBox(width: 6),
              Text(
                task.status == Constant.AMC_JOB_TASK_OPEN ? strings.open.toUpperCase() : strings.closed.toUpperCase(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: task.status == Constant.AMC_JOB_TASK_OPEN ? MColors.green : MColors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> updateJobTaskStatus(BuildContext context, int visitTaskId, int status, AmcTaskModel task) async {
    try {
      context.showLoader();

      final apiRes = await AmcRepo().updateJobTaskStatus(visitTaskId, status);

      if (apiRes.status != false) {
        setState(() {
          task.status = status;
        });
        Log.e('Job task status updated successfully: $visitTaskId');
      } else {
        Log.e('Failed to update job task status: ${apiRes.errorMessage}');
      }
    } catch (e) {
      Log.e('Error updating job task status: $e');
    } finally {
      Navigator.of(context).pop();
      context.hideLoader();
    }
  }
}
