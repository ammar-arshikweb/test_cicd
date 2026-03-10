import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:marquee/marquee.dart';
import 'package:panamera_app/comman_widget/confirmation_dialog.dart';
import 'package:panamera_app/comman_widget/custom_dropdown.dart';
import 'package:panamera_app/features/employee/attendance/view/break_in_out_dialog.dart';
import 'package:panamera_app/features/employee/attendance/view/clock_in_dialog.dart';
import 'package:panamera_app/features/employee/attendance/view/early_leave_dialog.dart';
import 'package:panamera_app/features/employee/attendance/view/overtime_dialog.dart';
import 'package:panamera_app/features/employee/attendance/view_model/attendance_view_model.dart';
import 'package:panamera_app/features/employee/main_page/view_model/main_page_view_model.dart';
import 'package:panamera_app/features/login/model/emp_login_res.dart';
import 'package:panamera_app/gen/assets.gen.dart';
import 'package:panamera_app/l10n/app_localizations.dart';
import 'package:panamera_app/responsive/screen_size_config.dart';
import 'package:panamera_app/services/network_service.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/global_tap.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/preference.dart';
import 'package:panamera_app/utils/snackbar_messages.dart';
import 'package:panamera_app/utils/system_ui_manager.dart';
import 'package:panamera_app/utils/time_utils.dart';
import 'package:panamera_app/utils/utils.dart';
import 'package:panamera_app/values/colors.dart';
import 'package:provider/provider.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> with TickerProviderStateMixin {
  late AppLocalizations strings;
  late AttendanceViewModel attendanceViewModel;

  @override
  void initState() {
    super.initState();
    // attendanceViewModel = Provider.of<AttendanceViewModel>(context, listen: false);
    // attendanceViewModel.initModel(context, this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    attendanceViewModel = Provider.of<AttendanceViewModel>(context, listen: false);
    attendanceViewModel.initModel(context, this);
  }

  @override
  void dispose() {
    attendanceViewModel.resetModel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    strings = Helper.getLocalization()!;
    SystemUIManager.setSystemUI(context: context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: MColors.greyBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Consumer<AttendanceViewModel>(
            builder: (context, provider, child) {
              return RefreshIndicator(
                onRefresh: () async {
                  await attendanceViewModel.resetModel();
                  await Future.delayed(const Duration(milliseconds: 500), () {});
                  return attendanceViewModel.initModel(context, this);
                },
                backgroundColor: MColors.primaryGreen,
                color: MColors.white,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    color: provider.isSupervisor ? MColors.white : null,
                    height: constraints.maxHeight,
                    width: constraints.maxWidth,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      // child: provider.isSupervisor ? buildSupervisorView(constraints, provider) : buildStaffView(constraints, provider),
                      child: provider.isMobileAdmin
                          ? buildMobileAdminView(constraints, provider)
                          : provider.isSupervisor
                          ? buildSupervisorView(constraints, provider)
                          : buildStaffView(constraints, provider),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget buildStaffView(BoxConstraints constraints, AttendanceViewModel provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: constraints.maxHeight * 0.05),
          // buildHeader(provider),
          buildNameAndDateText(),
          SizedBox(height: constraints.maxHeight * 0.02),
          buildMarquee(constraints),
          SizedBox(height: constraints.maxHeight * 0.02),
          buildSupervisorName(constraints),
          SizedBox(height: constraints.maxHeight * 0.01),
          buildClockView(constraints, provider),
          // SizedBox(height: constraints.maxHeight * 0.02),
          Expanded(flex: 2, child: buildMapView(provider, constraints)),
          SizedBox(height: constraints.maxHeight * 0.02),
          Expanded(flex: 2, child: buildAttendanceCountView(constraints, provider)),
        ],
      ),
    );
  }

  Widget buildMobileAdminView(BoxConstraints constraints, AttendanceViewModel provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: constraints.maxHeight * 0.05),
        // buildHeader(provider),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 15.0), child: buildNameAndDateText()),
        SizedBox(height: constraints.maxHeight * 0.02),
        // buildMarquee(constraints),
        // SizedBox(height: constraints.maxHeight * 0.02),
        Expanded(
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: buildTeamAttendanceView(provider)),
        ),
      ],
    );
  }

  Widget buildSupervisorView(BoxConstraints constraints, AttendanceViewModel provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: constraints.maxHeight * 0.05),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [buildNameAndDateText()]),
        ),
        SizedBox(height: constraints.maxHeight * 0.01),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 15.0), child: buildMarquee(constraints)),
        TabBar(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          controller: provider.tabController,
          labelColor: MColors.black,
          unselectedLabelColor: MColors.black,
          indicatorColor: MColors.primaryGreen,
          labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          unselectedLabelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          labelPadding: const EdgeInsets.symmetric(horizontal: 8),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerHeight: 0,
          indicatorPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          tabs: [
            Tab(text: strings.my_attendance),
            Tab(text: strings.team_attendance),
          ],
        ),
        // SizedBox(height: constraints.maxHeight * 0.02),
        Expanded(
          child: Container(
            color: MColors.grey.withValues(alpha: 0.1),
            child: TabBarView(
              controller: provider.tabController,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    children: [
                      buildClockView(constraints, provider),
                      // SizedBox(height: constraints.maxHeight * 0.02),
                      Expanded(flex: 2, child: buildMapView(provider, constraints)),
                      SizedBox(height: constraints.maxHeight * 0.035),
                      Expanded(flex: 2, child: buildAttendanceCountView(constraints, provider)),
                    ],
                  ),
                ),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 15.0), child: buildTeamAttendanceView(provider)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Container buildMarquee(BoxConstraints constraints) {
    return Container(
      height: 20,
      width: constraints.maxWidth,
      decoration: BoxDecoration(color: MColors.primaryGreen.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(6)),
      child: Marquee(
        text:
            'Press "clock in" button when you start work and "clock out" when you finish work.   काम शुरू करते समय चेकइन बटन दबाएँ और काम समाप्त होने पर चेकआउट करें',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MColors.white, fontWeight: FontWeight.bold),
        scrollAxis: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.center,
        blankSpace: 50.0,
        velocity: 30,
      ),
    );
  }

  Future<void> showClockInOutDialog(BuildContext context, bool isClockOut) async {
    if (attendanceViewModel.currentPosition == null) {
      SnackBarMsg.showErrorMessage(context, Helper.getLocalization()!.please_allow_location);
      return;
    }
    attendanceViewModel.getLocationAndAddress(context, getOnlyLocation: true);
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      barrierColor: MColors.black.withValues(alpha: 0.4),
      builder: (BuildContext context) {
        return ClockInOutDialog(time: TimeUtils.getCurrentDateTime(), isClockOut: isClockOut);
      },
    );
  }

  Future<void> showBreakInOutDialog(BuildContext context, bool isBreakOut) async {
    if (attendanceViewModel.currentPosition == null) {
      SnackBarMsg.showErrorMessage(context, Helper.getLocalization()!.please_allow_location);
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      barrierColor: MColors.black.withValues(alpha: 0.4),
      builder: (BuildContext context) {
        return BreakInOutDialog(time: TimeUtils.getCurrentDateTime(), isBreakOut: isBreakOut);
      },
    );
  }

  Widget _buildClockCard({required String label, required String time, required String icon, VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: MColors.white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [BoxShadow(color: MColors.black12, blurRadius: 4)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(icon, height: 25, width: 25),
              const SizedBox(height: 1),
              Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 1),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [MColors.red, MColors.orange]),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MColors.white, fontWeight: FontWeight.w100, letterSpacing: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreakClockCard({required String label, required String time, required String icon, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap != null ? () => GlobalTap.safeTap(onTap) : null,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: MColors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [BoxShadow(color: MColors.black12, blurRadius: 4)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(icon, height: 20, width: 20),
            const SizedBox(height: 2),
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [MColors.red, MColors.orange]),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                time,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: MColors.white, fontSize: 10, fontWeight: FontWeight.w100, letterSpacing: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildClockView(BoxConstraints constraints, AttendanceViewModel provider) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: constraints.maxHeight * 0.01),
      child: Row(
        children: [
          _buildClockCard(
            label: strings.clock_in.toUpperCase(),
            time:
                '${(provider.clockInTime?.hour ?? 0).toString().padLeft(2, '0')} : '
                '${(provider.clockInTime?.minute ?? 0).toString().padLeft(2, '0')} : '
                '${(provider.clockInTime?.second ?? 0).toString().padLeft(2, '0')}',
            icon: Assets.images.clockIn,
            onTap: () => GlobalTap.safeTap(() {
              if (provider.clockInTime != null) {
                return;
              }
              showClockInOutDialog(context, false);
            }),
          ),
          const SizedBox(width: 6),
          if (Pref.getDepartment() == Constant.DEPARTMENT_PROJECT) buildBreakClockView(provider),
          const SizedBox(width: 6),
          _buildClockCard(
            label: strings.clock_out.toUpperCase(),
            time:
                '${(provider.clockOutTime?.hour ?? 0).toString().padLeft(2, '0')} : '
                '${(provider.clockOutTime?.minute ?? 0).toString().padLeft(2, '0')} : '
                '${(provider.clockOutTime?.second ?? 0).toString().padLeft(2, '0')}',
            icon: Assets.images.clockOut,
            onTap: () => GlobalTap.safeTap(() {
              if (provider.breakInTime != null && provider.breakOutTime == null) {
                return;
              }
              if (provider.clockOutTime != null) {
                return;
              }
              if (provider.clockInTime == null) {
                SnackBarMsg.showErrorMessage(context, strings.please_check_in_first);
                return;
              }
              showClockInOutDialog(context, true);
            }),
          ),
        ],
      ),
    );
  }

  Widget buildBreakClockView(AttendanceViewModel provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (provider.breakInTime == null) ...[
          _buildBreakClockCard(
            label: strings.break_in.toUpperCase(),
            time:
                '${(provider.breakInTime?.hour ?? 0).toString().padLeft(2, '0')} : '
                '${(provider.breakInTime?.minute ?? 0).toString().padLeft(2, '0')} : '
                '${(provider.breakInTime?.second ?? 0).toString().padLeft(2, '0')}',
            icon: Assets.images.clockIn,
            onTap: () => GlobalTap.safeTap(() {
              if (provider.breakInTime != null || provider.clockOutTime != null) {
                return;
              }
              if (provider.clockInTime == null) {
                SnackBarMsg.showErrorMessage(context, strings.please_check_in_first);
                return;
              }
              showBreakInOutDialog(context, false);
            }),
          ),
        ] else ...[
          _buildBreakClockCard(
            label: strings.break_out.toUpperCase(),
            time:
                '${(provider.breakOutTime?.hour ?? 0).toString().padLeft(2, '0')} : '
                '${(provider.breakOutTime?.minute ?? 0).toString().padLeft(2, '0')} : '
                '${(provider.breakOutTime?.second ?? 0).toString().padLeft(2, '0')}',
            icon: Assets.images.clockOut,
            onTap: () => GlobalTap.safeTap(() {
              if (provider.breakOutTime != null) {
                return;
              }
              if (provider.breakInTime == null) {
                SnackBarMsg.showErrorMessage(context, strings.please_break_in_first);
                return;
              }
              showBreakInOutDialog(context, true);
            }),
          ),
        ],
      ],
    );
  }

  Widget buildSupervisorName(BoxConstraints constraints) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: constraints.maxHeight * 0.015),
      decoration: BoxDecoration(color: MColors.white, borderRadius: BorderRadius.circular(5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(strings.supervisor, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text(Pref.getReportingToName(), style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget buildNameAndDateText() {
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

  Widget buildMapView(AttendanceViewModel provider, BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(strings.your_current_location, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
        SizedBox(height: constraints.maxHeight * 0.01),
        Expanded(
          child: Container(
            padding: EdgeInsets.zero,
            width: double.infinity,
            child: GoogleMap(
              mapType: MapType.normal,
              zoomControlsEnabled: false,
              compassEnabled: false,
              myLocationButtonEnabled: false,
              initialCameraPosition: provider.currentPosition == null
                  ? CameraPosition(target: LatLng(25.2048, 55.2708), zoom: 17)
                  : CameraPosition(target: LatLng(provider.currentPosition!.latitude, provider.currentPosition!.longitude), zoom: 17),
              markers: provider.currentPosition == null
                  ? {}
                  : {
                      Marker(
                        markerId: const MarkerId('current_location'),
                        icon: BitmapDescriptor.defaultMarker,
                        position: LatLng(provider.currentPosition!.latitude, provider.currentPosition!.longitude),
                      ),
                    },
              onMapCreated: (GoogleMapController controller) {
                provider.setGoogleMapController(controller);
              },
            ),
          ),
        ),
        SizedBox(height: constraints.maxHeight * 0.01),
        Row(
          children: [
            const Icon(Icons.location_on_outlined, size: 20),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                provider.currentAddress == null ? '' : provider.currentAddress!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildAttendanceCountView(BoxConstraints constraints, AttendanceViewModel provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(strings.this_month, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
        SizedBox(height: constraints.maxHeight * 0.01),
        Container(
          width: constraints.maxWidth,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          decoration: BoxDecoration(
            color: MColors.white,
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAttendanceCard(title: strings.present, value: provider.workingDaysInMonth.toString()),
              Container(color: MColors.cCACACA, width: 1, height: 50),
              _buildAttendanceCard(title: strings.absent, value: provider.absentDaysInMonth.toString()),
              Container(color: MColors.cCACACA, width: 1, height: 50),
              _buildAttendanceCard(title: strings.overtime_hrs, value: provider.totalOvertimeInMonth.toString()),
              Container(color: MColors.cCACACA, width: 1, height: 50),
              _buildAttendanceCard(title: strings.holidays, value: provider.holidaysInMonth.toString()),
            ],
          ),
        ),
        const Spacer(),
        Center(
          child: Text(
            '${strings.last_synced} : ${provider.lastSyncedTime ?? ''}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w400),
          ),
        ),
        SizedBox(height: constraints.maxHeight * 0.01),
      ],
    );
  }

  Widget _buildAttendanceCard({required String title, required String value}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Text(value, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget buildTeamAttendanceView(AttendanceViewModel provider) {
    return Column(
      children: [
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () => GlobalTap.safeTap(() => provider.teamPageClick(context, 0)),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                alignment: Alignment.center,
                decoration: (provider.activeTeamPageIndex == 0)
                    ? const BoxDecoration(color: MColors.primaryGreen, borderRadius: BorderRadius.all(Radius.circular(15.0)))
                    : BoxDecoration(color: MColors.c667085.withAlpha(50), borderRadius: BorderRadius.all(Radius.circular(15.0))),
                child: Text(
                  strings.today,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: provider.activeTeamPageIndex == 0 ? MColors.white : MColors.c667085,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: () => GlobalTap.safeTap(() => provider.teamPageClick(context, 1)),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                alignment: Alignment.center,
                decoration: (provider.activeTeamPageIndex == 1)
                    ? const BoxDecoration(color: MColors.primaryGreen, borderRadius: BorderRadius.all(Radius.circular(15.0)))
                    : BoxDecoration(color: MColors.c667085.withAlpha(50), borderRadius: BorderRadius.all(Radius.circular(15.0))),
                child: Text(
                  strings.yesterday,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: provider.activeTeamPageIndex == 1 ? MColors.white : MColors.c667085,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Spacer(),
            if (provider.isMobileAdmin)
              Container(
                width: 200,
                alignment: Alignment.center,
                child: MCustomDropdown<EmployeeModel>(
                  label: null,
                  labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: MColors.black, fontWeight: FontWeight.w600),
                  initialItem: provider.selectedSupervisor,
                  hintText: strings.select_supervisor,
                  borderColor: MColors.grey,
                  showSearch: false,
                  items: provider.allSupervisorList,
                  headerBuilder: (context, item, isSelected) => Text(
                    item.fullName ?? '',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MColors.black, fontWeight: FontWeight.w500),
                  ),
                  listItemBuilder: (context, item, isSelected, onItemSelect) {
                    final theme = Theme.of(context);
                    return GestureDetector(
                      onTap: () => GlobalTap.safeTap(onItemSelect),
                      child: Container(
                        color: Colors.transparent,
                        child: Text(
                          item.fullName ?? '',
                          style: theme.textTheme.bodySmall?.copyWith(color: MColors.black, fontWeight: FontWeight.normal),
                        ),
                      ),
                    );
                  },
                  onChanged: (value) {
                    if (value != null) {
                      provider.setSupervisor(context, value);
                    }
                  },
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: DataTable2(
            empty: Center(
              child: Text(
                strings.no_data_found,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MColors.grey, fontWeight: FontWeight.w500),
              ),
            ),
            decoration: BoxDecoration(color: MColors.cF7F7F7),
            minWidth: ScreenSizeConfig.width * 0.9,
            headingRowColor: WidgetStateProperty.resolveWith((states) => MColors.primaryGreen),
            dataRowColor: WidgetStateProperty.resolveWith((states) => MColors.cF7F7F7),
            dividerThickness: 0.5,
            showCheckboxColumn: false,
            headingRowHeight: 40,
            columnSpacing: 10,
            horizontalMargin: 0,
            columns: [
              DataColumn2(
                label: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    strings.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MColors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              DataColumn2(
                label: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    strings.clock_in,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MColors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              DataColumn2(
                label: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    strings.clock_out,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MColors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              DataColumn2(
                label: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    strings.overtime,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MColors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
            rows: provider.teamAttendanceList.map((record) {
              return DataRow2(
                specificRowHeight: 60,
                color: WidgetStateProperty.resolveWith((_) => MColors.cF7F7F7),
                cells: [
                  DataCell(
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Tooltip(
                            message: record.fullName ?? '',
                            child: Text(
                              maxLines: 2,
                              record.fullName ?? '',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, overflow: TextOverflow.ellipsis),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(record.employeeId ?? '', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w400)),
                        ],
                      ),
                    ),
                  ),
                  DataCell(
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(record.formattedCheckInTime, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w400)),
                    ),
                  ),
                  DataCell(
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(record.formattedCheckOutTime, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w400)),
                    ),
                  ),
                  DataCell(
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        // mainAxisAlignment: record.overtime?.overtimeStatus == 1 ? MainAxisAlignment.center : MainAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formattedOverTimeHours(record.overtime?.overtimeHours ?? 0),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w400),
                          ),
                          if (record.overtime?.overtimeStatus != Constant.NA) ...[
                            const SizedBox(height: 2),
                            InkWell(
                              onTap: () => GlobalTap.safeTap(() {
                                if (record.overtime?.overtimeStatus != Constant.PENDING && record.overtime?.overtimeStatus != Constant.TL_APPROVED) {
                                  return;
                                }
                                if (Pref.getIsTeamLeader() && record.overtime?.overtimeStatus == Constant.TL_APPROVED) {
                                  return;
                                }
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  barrierLabel: '',
                                  barrierColor: MColors.black.withValues(alpha: 0.4),
                                  builder: (BuildContext context) {
                                    return OvertimeDialog(
                                      attendanceId: record.attendanceId!,
                                      overtimeData: record.overtime,
                                      isEmergency: record.emergencyStatus,
                                      emergencyData: record.emergency,
                                    );
                                  },
                                );
                              }),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: .min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: record.overtime?.overtimeStatus == Constant.PENDING
                                          ? MColors.lightOrange.withValues(alpha: 0.3)
                                          : record.overtime?.overtimeStatus == Constant.TL_APPROVED
                                          ? Pref.getIsTeamLeader()
                                                ? MColors.primaryGreen.withValues(alpha: 0.2)
                                                : MColors.lightOrange.withValues(alpha: 0.3)
                                          : record.overtime?.overtimeStatus == Constant.APPROVED
                                          ? MColors.primaryGreen.withValues(alpha: 0.2)
                                          : MColors.red.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      record.overtime?.overtimeStatus == Constant.PENDING
                                          ? Pref.getIsTeamLeader()
                                                ? strings.ot_approval
                                                : 'TL PENDING'
                                          : record.overtime?.overtimeStatus == Constant.TL_APPROVED
                                          ? Pref.getIsTeamLeader()
                                                ? strings.approved.toUpperCase()
                                                : strings.ot_approval
                                          : record.overtime?.overtimeStatus == Constant.APPROVED
                                          ? strings.approved.toUpperCase()
                                          : strings.rejected.toUpperCase(),
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: record.overtime?.overtimeStatus == Constant.PENDING
                                            ? MColors.orange
                                            : record.overtime?.overtimeStatus == Constant.TL_APPROVED
                                            ? Pref.getIsTeamLeader()
                                                  ? MColors.primaryGreen
                                                  : MColors.orange
                                            : record.overtime?.overtimeStatus == Constant.APPROVED
                                            ? MColors.primaryGreen
                                            : MColors.red.withValues(alpha: 0.8),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 8,
                                      ),
                                    ),
                                  ),
                                  if (record.emergencyStatus) ...[
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: MColors.lightOrange.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'EC',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.copyWith(color: MColors.orange, fontWeight: FontWeight.w600, fontSize: 8),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                          if (record.earlyReasonStatus != Constant.NA) ...[
                            const SizedBox(height: 2),
                            InkWell(
                              onTap: () => GlobalTap.safeTap(() {
                                if (record.earlyReasonStatus != Constant.PENDING) {
                                  return;
                                }
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  barrierLabel: '',
                                  barrierColor: MColors.black.withValues(alpha: 0.4),
                                  builder: (BuildContext context) {
                                    return EarlyLeaveDialog(attendanceId: record.attendanceId!, reason: record.earlyReason);
                                  },
                                );
                              }),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: record.earlyReasonStatus == Constant.PENDING
                                      ? MColors.cE8F1FF
                                      : record.earlyReasonStatus == Constant.APPROVED
                                      ? MColors.primaryGreen.withValues(alpha: 0.2)
                                      : MColors.red.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  record.earlyReasonStatus == Constant.PENDING
                                      ? strings.el_approval
                                      : record.earlyReasonStatus == Constant.APPROVED
                                      ? strings.approved.toUpperCase()
                                      : strings.rejected.toUpperCase(),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: record.earlyReasonStatus == Constant.PENDING
                                        ? MColors.c1E63D0
                                        : record.earlyReasonStatus == Constant.APPROVED
                                        ? MColors.primaryGreen
                                        : MColors.red.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 8,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
        if (provider.totalPages > 1)
          Container(
            color: MColors.cF7F7F7,
            padding: const EdgeInsets.symmetric(vertical: 15.0),
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
          ),
      ],
    );
  }

  String formattedOverTimeHours(double overtimeHours) {
    final hours = overtimeHours.floor();
    final minutes = ((overtimeHours - hours) * 60).round();
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  Widget buildHeader(AttendanceViewModel provider) {
    MainPageViewModel homeViewModel = Provider.of<MainPageViewModel>(context, listen: false);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: NetworkStatusService().connectionStatus,
          builder: (context, isConnected, _) {
            return Image.asset(isConnected ? Assets.images.online.path : Assets.images.offline.path, height: 20, width: 60, fit: BoxFit.fill);
          },
        ),
        const Spacer(),
        PopupMenuButton(
          onSelected: (value) {
            if (value == 1) {
              confirmationDialog(context, Assets.images.logoutIc, strings.are_you_sure_you_want_to_logout, strings.logout, DialogType.RED, () {
                homeViewModel.logoutButtonClick(context);
              });
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                padding: EdgeInsets.zero,
                height: 0,
                value: 1,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0, right: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(Icons.logout, size: 18, color: MColors.black),
                      ),
                      Text(strings.logout, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            ];
          },
          child: CircleAvatar(
            backgroundColor: MColors.grey,
            radius: 25,
            child: Text(
              Pref.getEmpName().substring(0, 1).toUpperCase(),
              style: TextStyle(color: MColors.black, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
        ),
      ],
    );
  }
}
