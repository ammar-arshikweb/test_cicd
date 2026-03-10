import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:panamera_app/comman_widget/audio_player_widget.dart';
import 'package:panamera_app/comman_widget/custom_dropdown.dart';
import 'package:panamera_app/comman_widget/image_widgets.dart';
import 'package:panamera_app/features/customer/home/model/customer_model.dart';
import 'package:panamera_app/features/employee/home/view/all_tasks_issues_screen.dart';
import 'package:panamera_app/features/employee/home/view_model/home_view_model.dart';
import 'package:panamera_app/features/employee/main_page/view_model/main_page_view_model.dart';
import 'package:panamera_app/features/login/model/emp_login_res.dart';
import 'package:panamera_app/gen/assets.gen.dart';
import 'package:panamera_app/l10n/app_localizations.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/global_tap.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/preference.dart';
import 'package:panamera_app/utils/system_ui_manager.dart';
import 'package:panamera_app/utils/time_utils.dart';
import 'package:panamera_app/utils/utils.dart';
import 'package:panamera_app/values/colors.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class ListItem {
  final String title;
  final String icon;
  final VoidCallback onTap;
  ListItem(this.title, this.icon, this.onTap);
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeViewModel _homeViewModel;
  bool _isCreatingTask = false;
  AppLocalizations strings = Helper.getLocalization()!;

  @override
  void initState() {
    super.initState();
    _homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    _homeViewModel.initModel(context);
  }

  @override
  void dispose() {
    super.dispose();
    _homeViewModel.resetModel();
  }

  @override
  Widget build(BuildContext context) {
    SystemUIManager.setSystemUI(context: context);
    return PopScope(
      canPop: !_isCreatingTask,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        setState(() {
          _isCreatingTask = false;
          _homeViewModel.clearTaskForm();
        });
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: MColors.greyBackground,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Consumer<HomeViewModel>(
                builder: (context, provider, child) {
                  final List<ListItem> employeeListItems = [
                    ListItem(strings.my_pending_tasks, Assets.images.myPendingTasks, () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AllTasksIssuesScreen(
                            allSupervisorList: provider.allSupervisorList,
                            title: strings.my_pending_tasks,
                            taskType: 0,
                            supervisorId: Pref.getEmpId(),
                            taskStatus: 0,
                          ),
                        ),
                      );
                    }),
                    ListItem(strings.my_overdue_tasks, Assets.images.myOverdueTasks, () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AllTasksIssuesScreen(
                            allSupervisorList: provider.allSupervisorList,
                            title: strings.my_overdue_tasks,
                            taskType: 0,
                            taskStatus: 0,
                            supervisorId: Pref.getEmpId(),
                            dateType: Constant.dueDate,
                            dateRange: DateTimeRange(
                              start: TimeUtils.getCurrentDateTime().subtract(Duration(days: 1825)),
                              end: TimeUtils.getCurrentDateTime().subtract(Duration(days: 1)),
                            ),
                          ),
                        ),
                      );
                    }),
                    ListItem(strings.my_tasks_due_today, Assets.images.myTasksDueToday, () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AllTasksIssuesScreen(
                            allSupervisorList: provider.allSupervisorList,
                            title: strings.my_tasks_due_today,
                            taskType: 0,
                            taskStatus: 0,
                            supervisorId: Pref.getEmpId(),
                            dateType: Constant.dueDate,
                            dateRange: DateTimeRange(start: TimeUtils.getCurrentDateTime(), end: TimeUtils.getCurrentDateTime()),
                          ),
                        ),
                      );
                    }),
                    ListItem(strings.all_tasks, Assets.images.allTasks, () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AllTasksIssuesScreen(
                            allSupervisorList: provider.allSupervisorList,
                            title: strings.all_tasks,
                            taskType: 0,
                            taskStatus: 0,
                            supervisorId: Pref.getEmpId(),
                          ),
                        ),
                      );
                    }),
                    ListItem(strings.issues_assigned_to_me, Assets.images.issuesAssignedToMe, () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AllTasksIssuesScreen(
                            allSupervisorList: provider.allSupervisorList,
                            title: strings.my_issues,
                            taskType: 1,
                            taskStatus: 0,
                            supervisorId: Pref.getEmpId(),
                          ),
                        ),
                      );
                    }),
                    ListItem(strings.all_issues, Assets.images.allIssues, () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AllTasksIssuesScreen(
                            allSupervisorList: provider.allSupervisorList,
                            title: strings.all_issues,
                            taskType: 1,
                            taskStatus: 0,
                            supervisorId: Pref.getEmpId(),
                          ),
                        ),
                      );
                    }),
                  ];
                  final List<ListItem> adminListItems = [
                    ListItem(strings.pending_tasks, Assets.images.myPendingTasks, () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AllTasksIssuesScreen(
                            allSupervisorList: provider.allSupervisorList,
                            title: strings.pending_tasks,
                            taskType: 0,
                            taskStatus: 0,
                            supervisorId: Pref.getEmpId(),
                          ),
                        ),
                      );
                    }),
                    ListItem(strings.overdue_tasks, Assets.images.myOverdueTasks, () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AllTasksIssuesScreen(
                            allSupervisorList: provider.allSupervisorList,
                            title: strings.overdue_tasks,
                            taskType: 0,
                            taskStatus: 0,
                            supervisorId: Pref.getEmpId(),
                            dateType: Constant.dueDate,
                            dateRange: DateTimeRange(
                              start: TimeUtils.getCurrentDateTime().subtract(Duration(days: 1825)),
                              end: TimeUtils.getCurrentDateTime().subtract(Duration(days: 1)),
                            ),
                          ),
                        ),
                      );
                    }),
                    ListItem(strings.tasks_due_today, Assets.images.myTasksDueToday, () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AllTasksIssuesScreen(
                            allSupervisorList: provider.allSupervisorList,
                            title: strings.tasks_due_today,
                            taskType: 0,
                            taskStatus: 0,
                            supervisorId: Pref.getEmpId(),
                            dateType: Constant.dueDate,
                            dateRange: DateTimeRange(start: TimeUtils.getCurrentDateTime(), end: TimeUtils.getCurrentDateTime()),
                          ),
                        ),
                      );
                    }),
                    ListItem(strings.all_tasks, Assets.images.allTasks, () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AllTasksIssuesScreen(
                            allSupervisorList: provider.allSupervisorList,
                            title: strings.all_tasks,
                            taskType: 0,
                            taskStatus: 0,
                            supervisorId: Pref.getEmpId(),
                          ),
                        ),
                      );
                    }),
                    ListItem(strings.all_issues, Assets.images.allIssues, () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AllTasksIssuesScreen(
                            allSupervisorList: provider.allSupervisorList,
                            title: strings.all_issues,
                            taskType: 1,
                            taskStatus: 0,
                            supervisorId: Pref.getEmpId(),
                          ),
                        ),
                      );
                    }),
                    ListItem(strings.create_new_task, Assets.images.createNewTask, () {
                      setState(() {
                        _isCreatingTask = true;
                      });
                    }),
                  ];
                  final listItems = (Pref.getFunctionality()?.contains(Constant.MOBILE_DASHBOARD_ADMIN) ?? false)
                      ? adminListItems
                      : employeeListItems;
                  return GestureDetector(
                    onTap: () => GlobalTap.safeTap(() {
                      FocusScope.of(context).unfocus();
                    }),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: constraints.maxWidth,
                          color: MColors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [const SizedBox(height: 60), buildNameAndDateText(strings), const SizedBox(height: 40)],
                            ),
                          ),
                        ),
                        Expanded(child: _isCreatingTask ? _buildCreateTaskForm(provider) : buildDashboardBody(strings, context, provider, listItems)),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  SingleChildScrollView buildDashboardBody(AppLocalizations strings, BuildContext context, HomeViewModel provider, List<ListItem> listItems) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 10,
              childAspectRatio: 1.8,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: <Widget>[
                if (Pref.getFunctionality()?.contains(Constant.MOBILE_PROJECTS) ?? false)
                  _buildStatCard(Assets.images.projects, strings.projects, 0, () {
                    if (Pref.getFunctionality()?.contains(Constant.MOBILE_PROJECTS) ?? false) {
                      Provider.of<MainPageViewModel>(context, listen: false).setIndex(3);
                    }
                  }),
                if (Pref.getFunctionality()?.contains(Constant.MOBILE_AMC) ?? false)
                  _buildStatCard(Assets.images.amcJobs, strings.amc_jobs, provider.jobCounts?.amcJobsCount ?? 0, () {
                    if (Pref.getFunctionality()?.contains(Constant.MOBILE_AMC) ?? false) {
                      Provider.of<MainPageViewModel>(context, listen: false).setIndex(2);
                    }
                  }),
                _buildStatCard(Assets.images.tasks, strings.tasks, provider.jobCounts?.tasksCount ?? 0, () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AllTasksIssuesScreen(
                        allSupervisorList: provider.allSupervisorList,
                        title: strings.all_tasks,
                        taskType: 0,
                        taskStatus: 0,
                        supervisorId: Pref.getEmpId(),
                      ),
                    ),
                  );
                }),
                _buildStatCard(Assets.images.issues, strings.issues, provider.jobCounts?.issuesCount ?? 0, () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AllTasksIssuesScreen(
                        allSupervisorList: provider.allSupervisorList,
                        title: strings.all_issues,
                        taskType: 1,
                        taskStatus: 0,
                        supervisorId: Pref.getEmpId(),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              decoration: BoxDecoration(color: MColors.white),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: listItems.length,
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () => GlobalTap.safeTap(listItems[index].onTap),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                      child: Row(
                        children: [
                          SvgPicture.asset(listItems[index].icon, height: 20, width: 20),
                          const SizedBox(width: 10),
                          Text(listItems[index].title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => Divider(height: 1, color: MColors.grey.withValues(alpha: 0.5), indent: 15, endIndent: 15),
              ),
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildCreateTaskForm(HomeViewModel provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        children: [
          _buildTextField(strings.task_title, provider.titleController),
          _buildTextField(strings.task_description, provider.descController, maxLines: 2),
          Row(
            children: [
              Expanded(
                child: MCustomDropdown<CustomerModel>(
                  label: strings.customer,
                  hintText: strings.select_customer,
                  labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  initialItem: provider.selectedCustomer,
                  borderColor: Colors.white,
                  showSearch: false,
                  items: provider.allCustomerList,
                  headerBuilder: (context, item, isSelected) => Text(
                    item.customerName ?? '',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MColors.black, fontWeight: FontWeight.w500),
                  ),
                  listItemBuilder: (context, item, isSelected, onItemSelect) {
                    final theme = Theme.of(context);
                    return GestureDetector(
                      onTap: () => GlobalTap.safeTap(onItemSelect),
                      child: Container(
                        color: Colors.transparent,
                        child: Text(
                          item.customerName ?? '',
                          style: theme.textTheme.bodyMedium?.copyWith(color: MColors.black, fontWeight: FontWeight.normal),
                        ),
                      ),
                    );
                  },
                  onChanged: (value) {
                    if (value != null) {
                      provider.setCustomer(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MCustomDropdown<VillaModel>(
                  label: strings.villa,
                  hintText: strings.select_villa,
                  labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  initialItem: provider.selectedVilla,
                  borderColor: Colors.white,
                  showSearch: false,
                  items: provider.availableVillas,
                  headerBuilder: (context, item, isSelected) => Text(
                    item.villaName ?? '',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MColors.black, fontWeight: FontWeight.w500),
                  ),
                  listItemBuilder: (context, item, isSelected, onItemSelect) {
                    final theme = Theme.of(context);
                    return GestureDetector(
                      onTap: () => GlobalTap.safeTap(onItemSelect),
                      child: Container(
                        color: Colors.transparent,
                        child: Text(
                          item.villaName ?? '',
                          style: theme.textTheme.bodyMedium?.copyWith(color: MColors.black, fontWeight: FontWeight.normal),
                        ),
                      ),
                    );
                  },
                  onChanged: (value) {
                    if (value != null) {
                      provider.setVilla(value);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: MCustomDropdown<int>(
                  label: strings.priority,
                  labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  initialItem: provider.selectedPriority,
                  hintText: strings.select_priority,
                  borderColor: Colors.white,
                  showSearch: false,
                  items: [0, 1, 2],
                  headerBuilder: (context, item, isSelected) => Text(
                    item == 0
                        ? strings.low
                        : item == 1
                        ? strings.medium
                        : strings.high,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MColors.black, fontWeight: FontWeight.w500),
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
              const SizedBox(width: 8),
              Expanded(
                child: MCustomDropdown<String>(
                  label: strings.reminder,
                  labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  initialItem: provider.selectedReminder,
                  hintText: strings.select_reminder,
                  borderColor: Colors.white,
                  showSearch: false,
                  items: Constant.reminderList,
                  headerBuilder: (context, item, isSelected) => Text(
                    item,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MColors.black, fontWeight: FontWeight.w500),
                  ),
                  listItemBuilder: (context, item, isSelected, onItemSelect) {
                    final theme = Theme.of(context);
                    return GestureDetector(
                      onTap: () => GlobalTap.safeTap(onItemSelect),
                      child: Container(
                        color: Colors.transparent,
                        child: Text(
                          item,
                          style: theme.textTheme.bodyMedium?.copyWith(color: MColors.black, fontWeight: FontWeight.normal),
                        ),
                      ),
                    );
                  },
                  onChanged: (value) {
                    if (value != null) {
                      provider.setReminder(value);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: MCustomDropdown<EmployeeModel>(
                  label: strings.supervisor,
                  labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  initialItem: provider.selectedSupervisor,
                  hintText: strings.select_supervisor,
                  borderColor: Colors.white,
                  showSearch: false,
                  items: provider.allSupervisorList,
                  headerBuilder: (context, item, isSelected) => Text(
                    item.fullName ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MColors.black, fontWeight: FontWeight.w500),
                  ),
                  listItemBuilder: (context, item, isSelected, onItemSelect) {
                    final theme = Theme.of(context);
                    return GestureDetector(
                      onTap: () => GlobalTap.safeTap(onItemSelect),
                      child: Container(
                        color: Colors.transparent,
                        child: Text(
                          item.fullName ?? '',
                          style: theme.textTheme.bodyMedium?.copyWith(color: MColors.black, fontWeight: FontWeight.normal),
                        ),
                      ),
                    );
                  },
                  onChanged: (value) {
                    if (value != null) {
                      provider.setSupervisor(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MCustomDropdown<EmployeeModel>(
                  label: strings.assigned_to,
                  labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  initialItem: provider.selectedTL,
                  hintText: strings.select_tl,
                  borderColor: Colors.white,
                  showSearch: false,
                  items: provider.allTLList,
                  headerBuilder: (context, item, isSelected) => Text(
                    item.fullName ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MColors.black, fontWeight: FontWeight.w500),
                  ),
                  listItemBuilder: (context, item, isSelected, onItemSelect) {
                    final theme = Theme.of(context);
                    return GestureDetector(
                      onTap: () => GlobalTap.safeTap(onItemSelect),
                      child: Container(
                        color: Colors.transparent,
                        child: Text(
                          item.fullName ?? '',
                          style: theme.textTheme.bodyMedium?.copyWith(color: MColors.black, fontWeight: FontWeight.normal),
                        ),
                      ),
                    );
                  },
                  onChanged: (value) {
                    if (value != null) {
                      provider.setTL(value);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildDatePicker(provider, true, provider.startDate)),
              const SizedBox(width: 8),
              Expanded(child: _buildDatePicker(provider, false, provider.dueDate)),
            ],
          ),
          const SizedBox(height: 15),
          buildAddPhotoAudio(strings, context, provider),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MColors.primaryGreen.withValues(alpha: 0.75),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  ),
                  onPressed: () => GlobalTap.safeTap(() async {
                    setState(() {
                      _isCreatingTask = false;
                      provider.clearTaskForm();
                    });
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
                  onPressed: () => GlobalTap.safeTap(() async {
                    final bool? res = await _homeViewModel.addTask(context);
                    if (res != null && res) {
                      setState(() {
                        _isCreatingTask = false;
                        provider.clearTaskForm();
                      });
                    }
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
        ],
      ),
    );
  }

  Widget _buildDatePicker(HomeViewModel provider, bool isStartDate, DateTime? date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isStartDate ? strings.start_date : strings.due_date,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        InkWell(
          onTap: () => GlobalTap.safeTap(() {
            provider.pickDueDate(context, isStartDate);
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: MColors.white),
            child: Row(
              children: [
                Text(
                  date != null ? DateFormat(Constant.dd_MM_yyyy_slash).format(date) : strings.select_date,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildAddPhotoAudio(AppLocalizations strings, BuildContext context, HomeViewModel provider) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [buildUploadPhotoView(strings, provider), const SizedBox(height: 16), buildRecordAudioView(strings, context, provider)],
    );
  }

  Widget buildRecordAudioView(AppLocalizations strings, BuildContext context, HomeViewModel provider) {
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

  Widget buildUploadPhotoView(AppLocalizations strings, HomeViewModel provider) {
    return Builder(
      builder: (context) {
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

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          onTapOutside: (event) {
            FocusScope.of(context).unfocus();
          },
          maxLines: maxLines,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            filled: true,
            fillColor: MColors.white,
            hintText: label,
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MColors.grey),
            contentPadding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget buildNameAndDateText(AppLocalizations strings) {
    var name = Pref.getEmpName().toUpperCase();
    var time = TimeUtils.getCurrentDateTimeInLocal(Constant.EEEE_dd_MM_yyyy);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Utils.getGreetingBasedOnTime(),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: MColors.grey, fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 10),
        Text('${strings.hello}, $name!', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text('${strings.date} : $time', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildStatCard(String icon, String title, int count, VoidCallback onTap) {
    return InkWell(
      onTap: () => GlobalTap.safeTap(onTap),
      child: Material(
        elevation: 0.2,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(color: MColors.white, borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(icon, height: 35, width: 35),
                    const Spacer(),
                    Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                  ],
                ),
                Spacer(),
                Text(count.toString(), style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
