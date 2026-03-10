import 'package:flutter/material.dart';
import 'package:panamera_app/comman_widget/custom_dropdown.dart';
import 'package:panamera_app/features/employee/home/view/issue_screen.dart';
import 'package:panamera_app/features/employee/home/view_model/all_tasks_issues_view_model.dart';
import 'package:panamera_app/features/login/model/emp_login_res.dart';
import 'package:panamera_app/l10n/app_localizations.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/global_tap.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/system_ui_manager.dart';
import 'package:panamera_app/values/colors.dart';
import 'package:provider/provider.dart';

class AllTasksIssuesScreen extends StatefulWidget {
  final List<EmployeeModel> allSupervisorList;
  final String title;
  final int taskType; // 0 Task, 1 Issue
  final String? supervisorId;
  final DateTimeRange? dateRange;
  final String? dateType; // startDate, dueDate
  final int? taskStatus; // startDate, dueDate

  const AllTasksIssuesScreen({
    super.key,
    required this.allSupervisorList,
    required this.title,
    required this.taskType,
    this.supervisorId,
    this.dateRange,
    this.dateType,
    this.taskStatus,
  });

  @override
  State<AllTasksIssuesScreen> createState() => _AllTasksIssuesScreenState();
}

class _AllTasksIssuesScreenState extends State<AllTasksIssuesScreen> {
  String? selectedValue;
  late AppLocalizations strings;
  late AllTasksIssuesViewModel _allTasksIssuesViewModel;

  @override
  void initState() {
    super.initState();
    _allTasksIssuesViewModel = Provider.of<AllTasksIssuesViewModel>(context, listen: false);
    _allTasksIssuesViewModel.initModel(
      context,
      widget.taskType,
      widget.supervisorId,
      widget.dateRange,
      widget.dateType,
      widget.taskStatus,
      widget.allSupervisorList,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _allTasksIssuesViewModel.resetModel();
  }

  @override
  Widget build(BuildContext context) {
    strings = Helper.getLocalization()!;
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
        child: Consumer<AllTasksIssuesViewModel>(
          builder: (context, provider, child) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  width: double.infinity,
                  color: MColors.white,
                  child: Text(widget.title, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w600)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  width: double.infinity,
                  color: MColors.primaryGreen,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              child: MCustomDropdown<String>(
                                label: strings.status,
                                labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MColors.white, fontWeight: FontWeight.w600),
                                showSearch: false,
                                hintText: strings.select_status,
                                initialItem:
                                    Helper.convertStatus(module: Constant.taskManager, number: provider.selectedStatus)?.label ?? Constant.all,
                                items: [
                                  strings.all,
                                  strings.open,
                                  if (widget.title != strings.my_pending_tasks) strings.closed,
                                  strings.on_hold,
                                  strings.in_progress,
                                  strings.awaiting_gate_pass,
                                ],
                                onChanged: (status) =>
                                    provider.setStatus(context, Helper.convertStatus(module: Constant.taskManager, text: status)?.key),
                                listItemBuilder: (context, item, isSelected, onItemSelect) {
                                  return GestureDetector(
                                    onTap: () => GlobalTap.safeTap(onItemSelect),
                                    child: Container(
                                      color: Colors.transparent,
                                      child: Text(item, maxLines: 2, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MColors.black)),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SizedBox(
                              child: MCustomDropdown<String>(
                                label: strings.priority,
                                labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MColors.white, fontWeight: FontWeight.w600),
                                showSearch: false,
                                hintText: strings.select_priority,
                                initialItem:
                                    Helper.convertStatus(module: Constant.taskManagerPriority, number: provider.selectedPriority)?.label ??
                                    Constant.all,
                                items: [strings.all, strings.low, strings.medium, strings.high],
                                onChanged: (status) =>
                                    provider.setPriority(context, Helper.convertStatus(module: Constant.taskManagerPriority, text: status)?.key),
                                listItemBuilder: (context, item, isSelected, onItemSelect) {
                                  return GestureDetector(
                                    onTap: () => GlobalTap.safeTap(onItemSelect),
                                    child: Container(
                                      color: Colors.transparent,
                                      child: Text(item, maxLines: 2, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MColors.black)),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              child: MCustomDropdown<EmployeeModel>(
                                label: strings.supervisor,
                                labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MColors.white, fontWeight: FontWeight.w600),
                                showSearch: false,
                                hintText: strings.select_supervisor,
                                initialItem: provider.selectedSupervisor ?? provider.allSupervisor,
                                items: [provider.allSupervisor, ...provider.allSupervisorList],
                                onChanged: (supervisor) => provider.setSupervisor(context, supervisor),
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
                          ),
                          const SizedBox(width: 10),
                          Expanded(flex: 1, child: SizedBox()),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: provider.taskList.isEmpty
                      ? Center(
                          child: Text(
                            widget.taskType == 0 ? strings.no_tasks_found : strings.no_issues_found,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: provider.taskList.length,
                          itemBuilder: (context, index) {
                            Color? color = Helper.convertStatus(module: Constant.taskManager, number: provider.taskList[index].taskStatus)?.color;
                            return Container(
                              color: MColors.white,
                              child: InkWell(
                                onTap: () => GlobalTap.safeTap(() {
                                  Navigator.of(
                                    context,
                                  ).push(MaterialPageRoute(builder: (context) => IssueScreen(task: provider.taskList[index]))).then((v) {
                                    _allTasksIssuesViewModel.getTasks(context);
                                  });
                                }),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: provider.taskList[index].amcJobName != null || provider.taskList[index].teamLeaderName != null
                                        ? 10
                                        : 15,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Helper.convertStatus(
                                            module: Constant.taskManagerPriority,
                                            number: provider.taskList[index].priority,
                                          )?.color.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(24),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              Helper.convertStatus(
                                                    module: Constant.taskManagerPriority,
                                                    number: provider.taskList[index].priority,
                                                  )?.label.substring(0, 1) ??
                                                  '',
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                fontWeight: FontWeight.w500,
                                                color: Helper.convertStatus(
                                                  module: Constant.taskManagerPriority,
                                                  number: provider.taskList[index].priority,
                                                )?.color,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: .min,
                                          crossAxisAlignment: .start,
                                          children: [
                                            Text(
                                              provider.taskList[index].taskName ?? '',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                                            ),
                                            if (provider.taskList[index].amcJobName != null)
                                              Text(
                                                '(${provider.taskList[index].amcJobName ?? ''})',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MColors.textDarkGrey),
                                              ),
                                            if (provider.taskList[index].teamLeaderName != null)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: MColors.blue.withValues(alpha: 0.2),
                                                  borderRadius: BorderRadius.circular(24),
                                                ),
                                                child: Text(
                                                  'TL: ${provider.taskList[index].teamLeaderName}',
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: Theme.of(
                                                    context,
                                                  ).textTheme.bodySmall?.copyWith(fontSize: 11, fontWeight: FontWeight.w500, color: MColors.blue),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        Helper.convertStatus(module: Constant.taskManager, number: provider.taskList[index].taskStatus)?.label ?? '',
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: color, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) => Divider(height: 1, color: MColors.grey.withValues(alpha: 0.5)),
                        ),
                ),
                if (provider.totalPages > 1) buildPaginationFooter(provider, context),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  Container buildPaginationFooter(AllTasksIssuesViewModel provider, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            onTap: () => GlobalTap.safeTap(() {
              provider.goToPrevPage(context);
            }),
            child: Row(children: [Icon(Icons.chevron_left), const SizedBox(width: 10), Text(strings.prev)]),
          ),
          Text(
            strings.pageInfo(provider.currentPage, provider.totalPages),
            style: const TextStyle(fontSize: 14, color: MColors.black, fontWeight: FontWeight.w500),
          ),
          InkWell(
            onTap: () => GlobalTap.safeTap(() {
              provider.goToNextPage(context);
            }),
            child: Row(children: [Text(strings.next), const SizedBox(width: 10), Icon(Icons.chevron_right)]),
          ),
        ],
      ),
    );
  }
}
