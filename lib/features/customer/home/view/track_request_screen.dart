import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:panamera_app/comman_widget/custom_date_range_picker.dart';
import 'package:panamera_app/comman_widget/custom_loader.dart';
import 'package:panamera_app/features/customer/home/model/task_model.dart';
import 'package:panamera_app/features/employee/home/repository/home_repo.dart';
import 'package:panamera_app/l10n/app_localizations.dart';
import 'package:panamera_app/services/network_service.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/global_tap.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/log_utils.dart';
import 'package:panamera_app/utils/preference.dart';
import 'package:panamera_app/utils/snackbar_messages.dart';
import 'package:panamera_app/utils/system_ui_manager.dart';
import 'package:panamera_app/values/colors.dart';

class TrackRequestScreen extends StatefulWidget {
  const TrackRequestScreen({super.key});

  @override
  State<TrackRequestScreen> createState() => _TrackRequestScreenState();
}

class _TrackRequestScreenState extends State<TrackRequestScreen> {
  late AppLocalizations strings;
  DateTimeRange? _selectedDateRange;
  List<TaskModel> _taskList = [];

  @override
  void initState() {
    super.initState();
    _selectedDateRange = DateTimeRange(start: DateTime.now().subtract(Duration(days: 7)), end: DateTime.now().subtract(Duration(minutes: 1)));
    getTasks(context);
  }

  @override
  void dispose() {
    super.dispose();
    _taskList.clear();
  }

  @override
  Widget build(BuildContext context) {
    SystemUIManager.setSystemUI(context: context, statusBarColor: MColors.green.withValues(alpha: 0.2));
    strings = Helper.getLocalization()!;
    double horizontalPadding = 25.0;
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [MColors.green.withValues(alpha: 0.2), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Text(
                  strings.track_request.toUpperCase(),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 50),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: InkWell(
                  onTap: () => GlobalTap.safeTap(() {
                    _showDateRangePicker();
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: MColors.white),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDateRange != null
                              ? '${DateFormat(Constant.dd_MM_yy_slash).format(_selectedDateRange!.start)} - ${DateFormat(Constant.dd_MM_yy_slash).format(_selectedDateRange!.end)}'
                              : strings.select_date,
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        Icon(Icons.calendar_today, color: MColors.primaryGreen, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildRequestView(_taskList),
              const SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 200,
                      padding: const EdgeInsets.symmetric(horizontal: 25),
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
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> setSelectedDateRange(BuildContext context, DateTimeRange dateRange) async {
    _selectedDateRange = dateRange;
    setState(() {});
    getTasks(context);
  }

  Widget _buildRequestView(List<TaskModel> requestsList) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 5.0, right: 5.0),
        child: requestsList.isEmpty
            ? Center(child: Text(strings.no_requests_found))
            : ListView.builder(
                itemCount: requestsList.length,
                itemBuilder: (context, index) {
                  final request = requestsList[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0, left: 10, right: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: MColors.white,
                        border: Border.all(color: MColors.black.withValues(alpha: 0.3)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: MColors.green),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(request.taskName ?? '', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 5),
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 10,
                                  runSpacing: 4,
                                  children: [
                                    Text(
                                      '${strings.date}: ${request.startDate ?? ''}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w400),
                                    ), // const SizedBox(width: 5,),
                                    Text(
                                      'Req#: ${request.requestId ?? ''}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Helper.convertStatus(module: Constant.taskManager, number: request.taskStatus)?.color.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  backgroundColor: Helper.convertStatus(module: Constant.taskManager, number: request.taskStatus)?.color,
                                  radius: 4,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  Helper.convertStatus(module: Constant.taskManager, number: request.taskStatus)?.label ?? '',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: Helper.convertStatus(module: Constant.taskManager, number: request.taskStatus)?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _showDateRangePicker() async {
    final DateTimeRange? picked = await showCustomDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      primaryColor: MColors.primaryGreen,
      rangeHighlightColor: MColors.primaryGreen.withValues(alpha: 0.3),
    );

    if (picked != null && picked != _selectedDateRange) {
      setSelectedDateRange(context, picked);
    }
  }

  Future<void> getTasks(BuildContext context) async {
    if (!NetworkStatusService().connectionStatus.value) {
      SnackBarMsg.showErrorMessage(context, Helper.getLocalization()?.no_internet_connection);
      return;
    }
    try {
      context.showLoader();

      // Use selected date range
      final dateRange = _selectedDateRange;

      if (dateRange == null) {
        context.hideLoader();
        return;
      }

      final apiRes = await HomeRepo().getTasks(
        page: 1,
        taskType: 1,
        customerId: Pref.getCustomerStringId(),
        dateType: Constant.startDate,
        dateRange: dateRange,
        isExport: true,
      );

      if (apiRes.status != false && apiRes.data != null) {
        var results = apiRes.data!.results;

        _taskList
          ..clear()
          ..addAll(results);
        // _totalPages = apiRes.data!.pagination.totalPages;
      } else {
        SnackBarMsg.showErrorMessage(context, apiRes.errorMessage);
      }
      Log.i('Tasks List: ${_taskList.length}');
    } catch (e) {
      Log.e('Error while getTasks: $e');
      SnackBarMsg.showError(context);
    } finally {
      context.hideLoader();
      setState(() {});
    }
  }
}
