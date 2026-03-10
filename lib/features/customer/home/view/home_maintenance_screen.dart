import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:panamera_app/comman_widget/amc_calendar_dialog.dart';
import 'package:panamera_app/comman_widget/image_widgets.dart';
import 'package:panamera_app/features/customer/home/view_model/home_maintenance_view_model.dart';
import 'package:panamera_app/features/employee/amc/model/amc_job_data_model.dart';
import 'package:panamera_app/l10n/app_localizations.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/global_tap.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/snackbar_messages.dart';
import 'package:panamera_app/utils/system_ui_manager.dart';
import 'package:panamera_app/utils/time_utils.dart';
import 'package:panamera_app/values/colors.dart';
import 'package:provider/provider.dart';

class HomeMaintenanceScreen extends StatefulWidget {
  final int villaId;
  final String villaName;
  const HomeMaintenanceScreen({super.key, required this.villaId, required this.villaName});

  @override
  State<HomeMaintenanceScreen> createState() => _HomeMaintenanceScreenState();
}

class _HomeMaintenanceScreenState extends State<HomeMaintenanceScreen> with TickerProviderStateMixin {
  late AppLocalizations strings;
  late TabController _tabController;
  late TabController _gardenTabController;
  late TabController _photosTabController;
  late HomeMaintenanceViewModel _homeMaintenanceViewModel;
  late Map<String, List<AmcTaskModel>> categorizedTasks;
  late List<String> categories;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _homeMaintenanceViewModel = Provider.of<HomeMaintenanceViewModel>(context, listen: false);
    _homeMaintenanceViewModel.initModel(context, widget.villaId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    if (_homeMaintenanceViewModel.jobsForSelectedDate.isNotEmpty) _gardenTabController.dispose();
    if (_homeMaintenanceViewModel.jobsForSelectedDate.isNotEmpty) _photosTabController.dispose();
    _homeMaintenanceViewModel.resetModel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemUIManager.setSystemUI(context: context, statusBarColor: MColors.green.withValues(alpha: 0.2));
    strings = Helper.getLocalization()!;
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [MColors.green.withValues(alpha: 0.2), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Consumer<HomeMaintenanceViewModel>(
            builder: (context, provider, child) {
              return provider.calendarJobs.isEmpty
                  ? Center(child: Text(strings.no_amc_found_for_this_villa))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        Text(
                          widget.villaName.toUpperCase(),
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 22, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 35),
                        _buildDateSection(provider),
                        const SizedBox(height: 20),
                        if (provider.jobsForSelectedDate.isNotEmpty) _buildTabBar(),
                        Expanded(
                          child: provider.jobsForSelectedDate.isEmpty
                              ? Center(child: Text(strings.no_jobs_found))
                              : TabBarView(
                                  controller: _tabController,
                                  children: [
                                    _buildGardenView(provider.mergedGardenTasks, provider),
                                    _buildPoolView(provider.mergedPoolTasks, provider),
                                    _buildPhotosView(provider.gardenPhotos, provider.poolPhotos),
                                  ],
                                ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: 200,
                            decoration: BoxDecoration(color: MColors.primaryGreen, borderRadius: BorderRadius.circular(2)),
                            child: TextButton(
                              onPressed: () => GlobalTap.safeTap(() {
                                Navigator.of(context).pop();
                              }),
                              child: Text(
                                strings.back,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: MColors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDateSection(HomeMaintenanceViewModel provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(strings.date, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w600)),
            Spacer(),
          ],
        ),
        const SizedBox(height: 12),
        _buildDatePicker(provider),
      ],
    );
  }

  Widget _buildDatePicker(HomeMaintenanceViewModel provider) {
    return InkWell(
      onTap: () => GlobalTap.safeTap(() {
        _showDatePicker(provider);
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: MColors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              provider.selectedDate != null ? DateFormat(Constant.dd_MM_yyyy).format(provider.selectedDate!) : strings.select_date,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w500),
            ),
            Icon(Icons.calendar_today, color: MColors.primaryGreen, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Theme(
        // To remove ripple effect on tab click
        data: Theme.of(context).copyWith(tabBarTheme: TabBarThemeData(overlayColor: WidgetStateProperty.all(Colors.transparent))),
        child: TabBar(
          controller: _tabController,
          dividerColor: MColors.transparent,
          indicator: BoxDecoration(color: MColors.green, borderRadius: BorderRadius.circular(10)),
          indicatorPadding: const EdgeInsets.all(5),
          labelColor: MColors.white,
          unselectedLabelColor: MColors.primaryGreen,
          labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400),
          unselectedLabelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: [
            Tab(child: Text(strings.garden)),
            Tab(child: Text(strings.pool)),
            Tab(child: Text(strings.photos)),
          ],
        ),
      ),
    );
  }

  void _categorizeTasks(List<AmcTaskModel> gardenTask) {
    categorizedTasks = <String, List<AmcTaskModel>>{};

    // Define the order of categories
    const List<String> categoryOrder = ['Daily', 'Weekly', 'Monthly', 'Seasonal', 'Special'];

    // Initialize empty lists for each category
    for (String category in categoryOrder) {
      categorizedTasks[category] = <AmcTaskModel>[];
    }

    // Group tasks by category
    for (AmcTaskModel task in gardenTask) {
      String category = task.category;
      if (categorizedTasks.containsKey(category)) {
        categorizedTasks[category]!.add(task);
      } else {
        categorizedTasks[category] = [task];
      }
    }

    categories = categorizedTasks.entries.where((entry) => entry.value.isNotEmpty).map((entry) => entry.key).toList();
  }

  Widget _buildGardenView(List<AmcTaskModel> gardenTask, HomeMaintenanceViewModel provider) {
    _categorizeTasks(gardenTask);
    _gardenTabController = TabController(length: categories.length, vsync: this);
    return Padding(
      padding: const EdgeInsets.only(top: 0.0),
      child: gardenTask.isEmpty
          ? Center(child: Text(strings.no_data_found))
          : Column(
              children: [
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(strings.status, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                    const SizedBox(width: 3),
                    if (provider.jobsForSelectedDate.where((job) => job.visitType == Constant.VISIT_TYPE_GARDEN).firstOrNull != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Helper.convertStatus(module: Constant.amcJobs, number: provider.gardenStatus)?.color.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          Helper.convertStatus(module: Constant.amcJobs, number: provider.gardenStatus)!.label,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
                Theme(
                  data: Theme.of(context).copyWith(tabBarTheme: TabBarThemeData(overlayColor: WidgetStateProperty.all(Colors.transparent))),
                  child: TabBar(
                    controller: _gardenTabController,
                    isScrollable: true,
                    dividerColor: MColors.transparent,
                    labelColor: MColors.primaryGreen,
                    unselectedLabelColor: MColors.textDarkGrey,
                    indicatorColor: MColors.primaryGreen,
                    tabAlignment: TabAlignment.start,
                    labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    unselectedLabelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    tabs: categories.map((category) => Tab(child: Text(category))).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TabBarView(
                    controller: _gardenTabController,
                    children: categories
                        .map(
                          (category) => ListView.builder(
                            itemCount: categorizedTasks[category]?.length ?? 0,
                            itemBuilder: (context, index) {
                              // return _buildTask(categorizedTasks[category]![index], strings);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: MColors.white,
                                    border: Border.all(color: MColors.black.withValues(alpha: 0.3)),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                                  child: Row(
                                    children: [
                                      (categorizedTasks[category]![index].status == 1)
                                          ? Icon(Icons.check_circle_rounded, color: MColors.green)
                                          : Icon(Icons.circle_outlined),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          categorizedTasks[category]![index].taskName,
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPoolView(List<AmcTaskModel> poolTask, HomeMaintenanceViewModel provider) {
    return poolTask.isEmpty
        ? Center(child: Text(strings.no_data_found))
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(strings.status, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                  const SizedBox(width: 3),
                  if (provider.jobsForSelectedDate.where((job) => job.visitType == Constant.VISIT_TYPE_POOL).firstOrNull != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Helper.convertStatus(module: Constant.amcJobs, number: provider.poolStatus)?.color.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        Helper.convertStatus(module: Constant.amcJobs, number: provider.poolStatus)!.label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: ListView.builder(
                    itemCount: poolTask.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: MColors.white,
                            border: Border.all(color: MColors.black.withValues(alpha: 0.3)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                          child: Row(
                            children: [
                              (poolTask[index].status == 1) ? Icon(Icons.check_circle_rounded, color: MColors.green) : Icon(Icons.circle_outlined),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  poolTask[index].taskName,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
  }

  Widget _buildPhotosView(List<String> gardenPhotos, List<String> poolPhotos) {
    _photosTabController = TabController(length: 2, vsync: this);
    final bool hasGardenPhotos = gardenPhotos.isNotEmpty;
    final bool hasPoolPhotos = poolPhotos.isNotEmpty;
    final bool hasNoPhotos = !hasGardenPhotos && !hasPoolPhotos;

    return hasNoPhotos
        ? Center(child: Text(strings.no_data_found))
        : Column(
            children: [
              const SizedBox(height: 5),
              Theme(
                data: Theme.of(context).copyWith(tabBarTheme: TabBarThemeData(overlayColor: WidgetStateProperty.all(Colors.transparent))),
                child: TabBar(
                  controller: _photosTabController,
                  tabAlignment: TabAlignment.center,
                  dividerColor: MColors.transparent,
                  indicator: BoxDecoration(color: MColors.green, borderRadius: BorderRadius.circular(20)),
                  indicatorPadding: const EdgeInsets.symmetric(vertical: 8),
                  labelColor: MColors.white,
                  unselectedLabelColor: MColors.primaryGreen,
                  labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                  unselectedLabelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 20),
                  tabs: [
                    Tab(child: Text(strings.garden)),
                    Tab(child: Text(strings.pool)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: TabBarView(controller: _photosTabController, children: [_buildPhotoGrid(gardenPhotos), _buildPhotoGrid(poolPhotos)]),
              ),
            ],
          );
  }

  Widget _buildPhotoGrid(List<String> photos) {
    if (photos.isEmpty) {
      return Center(child: Text(strings.no_data_found));
    }
    return GridView.builder(
      padding: const EdgeInsets.only(top: 10, bottom: 15),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) => InkWell(
        onTap: () => GlobalTap.safeTap(() => ImageWidgets.showImageDialog(context, photos[index], photos)),
        child: CachedNetworkImage(imageUrl: photos[index], fit: BoxFit.cover, placeholder: (context, url) => ShimmerPlaceholder()),
      ),
    );
  }

  Future<void> _showDatePicker(HomeMaintenanceViewModel provider) async {
    final availableDates = provider.calendarJobs.map((job) => DateTime.parse(job.date!)).toSet();
    if (availableDates.isEmpty) {
      SnackBarMsg.showErrorMessage(context, strings.no_amc_found_for_this_villa);
      return;
    }
    final firstDate = availableDates.reduce((a, b) => a.isBefore(b) ? a : b);
    final lastDate = availableDates.reduce((a, b) => a.isAfter(b) ? a : b);
    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (context) => AmcCalendarDialog(
        initialDate: provider.selectedDate ?? lastDate,
        firstDate: firstDate,
        lastDate: TimeUtils.getCurrentDateTime(),
        dateJobTypes: provider.dateJobTypes,
        availableDates: availableDates,
        helpText: strings.select_date,
      ),
    );
    if (picked != null && picked != provider.selectedDate) {
      provider.setSelectedDate(context, picked);
    }
  }
}
