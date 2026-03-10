import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:intl/intl.dart';
import 'package:panamera_app/comman_widget/custom_dropdown.dart';
import 'package:panamera_app/features/employee/attendance/model/leave_model.dart';
import 'package:panamera_app/features/employee/attendance/view_model/leave_view_model.dart';
import 'package:panamera_app/l10n/app_localizations.dart';
import 'package:panamera_app/responsive/screen_size_config.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/global_tap.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/preference.dart';
import 'package:panamera_app/utils/snackbar_messages.dart';
import 'package:panamera_app/utils/time_utils.dart';
import 'package:panamera_app/values/colors.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> with TickerProviderStateMixin {
  late LeaveViewModel _leaveViewModel;
  late AppLocalizations strings;

  @override
  void initState() {
    super.initState();
    _leaveViewModel = Provider.of<LeaveViewModel>(context, listen: false);
    _leaveViewModel.initModel(context, this);
  }

  @override
  void dispose() {
    super.dispose();
    _leaveViewModel.resetModel();
  }

  @override
  Widget build(BuildContext context) {
    strings = Helper.getLocalization()!;
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
        child: Consumer<LeaveViewModel>(
          builder: (context, provider, child) {
            return Column(
              crossAxisAlignment: .start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        color: MColors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Column(
                            crossAxisAlignment: .start,
                            children: [
                              const SizedBox(height: 10),
                              Text(
                                strings.leave_application.toUpperCase(),
                                style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 15),
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
                                  Tab(text: strings.leave_requests),
                                  Tab(text: strings.apply_for_leave),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: TabBarView(controller: provider.tabController, children: [_buildLeaveRequests(), _buildApplyForLeave()]),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLeaveRequests() {
    return Consumer<LeaveViewModel>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            children: [
              const SizedBox(height: 15),
              // Only visible for supervisor(roleOrderID-3) and team leaders
              if (Pref.getRoleOrderId() == 3 || Pref.getIsTeamLeader()) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () => GlobalTap.safeTap(() => provider.requestPageClick(context, 0)),
                      splashColor: MColors.transparent,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        alignment: Alignment.center,
                        decoration: (provider.activeReqPageIndex == 0)
                            ? const BoxDecoration(color: MColors.primaryGreen, borderRadius: BorderRadius.all(Radius.circular(15.0)))
                            : BoxDecoration(color: MColors.grey.withAlpha(90), borderRadius: BorderRadius.all(Radius.circular(15.0))),
                        child: Text(
                          strings.my_requests,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MColors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () => GlobalTap.safeTap(() => provider.requestPageClick(context, 1)),
                      splashColor: MColors.transparent,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        alignment: Alignment.center,
                        decoration: (provider.activeReqPageIndex == 1)
                            ? const BoxDecoration(color: MColors.primaryGreen, borderRadius: BorderRadius.all(Radius.circular(15.0)))
                            : BoxDecoration(color: MColors.grey.withAlpha(90), borderRadius: BorderRadius.all(Radius.circular(15.0))),
                        child: Text(
                          strings.team_leave_requests,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MColors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
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
                  columnSpacing: 5,
                  horizontalMargin: 0,
                  columns: provider.activeReqPageIndex == 0
                      ? [
                          DataColumn2(
                            fixedWidth: 95,
                            label: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                strings.type,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MColors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          DataColumn2(
                            fixedWidth: 90,
                            label: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                strings.start_date,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MColors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          DataColumn2(
                            fixedWidth: 90,
                            label: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                strings.end_date,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MColors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          DataColumn2(
                            label: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                strings.status,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MColors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ]
                      : [
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
                            fixedWidth: 90,
                            label: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                strings.type,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MColors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          DataColumn2(
                            fixedWidth: 80,
                            label: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                strings.dates,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MColors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          DataColumn2(
                            fixedWidth: 100,
                            label: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                strings.status,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MColors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                  rows: provider.activeReqPageIndex == 0
                      ? provider.leaveApplicationsList.map((record) {
                          String startDate = '';
                          String endDate = '';
                          if (record.startDate != null) {
                            startDate = TimeUtils.formatDateTimeToOutput(
                              TimeUtils.formatStringToDateTime(record.startDate!)!,
                              Constant.dd_MM_yy_slash,
                            );
                          }
                          if (record.endDate != null) {
                            endDate = TimeUtils.formatDateTimeToOutput(TimeUtils.formatStringToDateTime(record.endDate!)!, Constant.dd_MM_yy_slash);
                          }
                          return DataRow2(
                            specificRowHeight: 60,
                            color: WidgetStateProperty.resolveWith((_) => MColors.cF7F7F7),
                            cells: [
                              DataCell(
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    record.leaveType == Constant.LEAVE_TYPE_EMERGENCY
                                        ? strings.emergency
                                        : record.leaveType == Constant.LEAVE_TYPE_SICK
                                        ? strings.sick
                                        : strings.annual,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(overflow: TextOverflow.ellipsis),
                                  ),
                                ),
                              ),
                              DataCell(
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(startDate, style: Theme.of(context).textTheme.bodySmall?.copyWith(overflow: TextOverflow.ellipsis)),
                                ),
                              ),
                              DataCell(
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(endDate, style: Theme.of(context).textTheme.bodySmall?.copyWith(overflow: TextOverflow.ellipsis)),
                                ),
                              ),
                              DataCell(
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: (record.leaveType == Constant.LEAVE_TYPE_SICK && record.leaveCertificate == null && record.leaveStatus != 4)
                                      ? Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            InkWell(
                                              onTap: () => GlobalTap.safeTap(() => showPendingCertificateDialog(record.id ?? -1, context)),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: MColors.c629CDD.withValues(alpha: 0.2),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  'PENDING CERT.',
                                                  style: Theme.of(
                                                    context,
                                                  ).textTheme.bodySmall?.copyWith(color: MColors.blue, fontWeight: FontWeight.w500, fontSize: 8),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Time Remaining: ${getTimeRemaining(record.createdAt ?? TimeUtils.getCurrentDateTime().toString())}',
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500, fontSize: 8),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          getLeaveStatusText(record.leaveStatus ?? 0),
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(overflow: TextOverflow.ellipsis),
                                        ),
                                ),
                              ),
                            ],
                          );
                        }).toList()
                      : provider.leaveApplicationsList.map((record) {
                          String startDate = '';
                          String endDate = '';
                          if (record.startDate != null) {
                            startDate = TimeUtils.formatDateTimeToOutput(
                              TimeUtils.formatStringToDateTime(record.startDate!)!,
                              Constant.dd_MM_yy_slash,
                            );
                          }
                          if (record.endDate != null) {
                            endDate = TimeUtils.formatDateTimeToOutput(TimeUtils.formatStringToDateTime(record.endDate!)!, Constant.dd_MM_yy_slash);
                          }
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
                                        message: record.employeeName ?? '',
                                        child: Text(
                                          record.employeeName ?? '',
                                          maxLines: 2,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, overflow: TextOverflow.ellipsis),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        record.employeeId ?? '',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              DataCell(
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    record.leaveType == Constant.LEAVE_TYPE_EMERGENCY
                                        ? strings.emergency
                                        : record.leaveType == Constant.LEAVE_TYPE_SICK
                                        ? strings.sick
                                        : strings.annual,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(overflow: TextOverflow.ellipsis),
                                  ),
                                ),
                              ),
                              DataCell(
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    '$startDate\n - \n$endDate',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(overflow: TextOverflow.ellipsis, height: 0.9),
                                  ),
                                ),
                              ),
                              DataCell(
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: (record.leaveType == Constant.LEAVE_TYPE_SICK && record.leaveCertificate == null && record.leaveStatus != 4)
                                      ? Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            InkWell(
                                              // onTap: () => GlobalTap.safeTap(() => showPendingCertificateDialog(record.id ?? -1, context)),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: MColors.c629CDD.withValues(alpha: 0.2),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  'PENDING CERT.',
                                                  style: Theme.of(
                                                    context,
                                                  ).textTheme.bodySmall?.copyWith(color: MColors.blue, fontWeight: FontWeight.w500, fontSize: 8),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Time Remaining: ${getTimeRemaining(record.createdAt ?? TimeUtils.getCurrentDateTime().toString())}',
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500, fontSize: 8),
                                            ),
                                          ],
                                        )
                                      : buildLeaveStatus(record),
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
          ),
        );
      },
    );
  }

  String getLeaveStatusText(int status) {
    final bool isTL = Pref.getIsTeamLeader();
    final bool isSV = Pref.getRoleOrderId() == 3;
    switch (status) {
      case 1:
        return isTL ? 'Pending' : 'TL Approved';
      case 2:
        return isSV ? 'Pending' : 'SV Approved';
      case 3:
        return 'HR Approved';
      case 4:
        return 'Rejected';
      default:
        return 'Pending';
    }
  }

  Widget buildLeaveStatus(LeaveModel record) {
    final bool isTL = Pref.getIsTeamLeader();
    final bool isSV = Pref.getRoleOrderId() == 3;
    final int status = record.leaveStatus ?? 0;

    final TextStyle? style = Theme.of(context).textTheme.bodySmall;

    // Rejected (visible to everyone)
    if (status == 4) {
      return Text('Rejected', style: style?.copyWith(color: Colors.red));
    }

    // HR Approved (final state)
    if (status == 3) {
      return Text('HR Approved', style: style);
    }

    // ==============================
    // SUPERVISOR LOGIN
    // ==============================
    if (isSV) {
      switch (status) {
        case 0:
          return Text('Pending (TL)', style: style);

        case 1:
          return _approveButton(record, style);

        case 2:
          return Text('SV Approved', style: style);
      }
    }

    // ==============================
    // TEAM LEADER LOGIN
    // ==============================
    if (isTL) {
      switch (status) {
        case 0:
          return _approveButton(record, style);

        case 1:
          return Text('TL Approved', style: style);

        case 2:
          return Text('SV Approved', style: style);
      }
    }

    return const SizedBox();
  }

  Widget _approveButton(LeaveModel record, TextStyle? style) {
    return InkWell(
      onTap: () => GlobalTap.safeTap(() => showApproveRejectDialog(record.id ?? -1, context, record)),
      child: Text(
        'Approve/\nPending',
        style: style?.copyWith(color: Colors.lightBlue, decoration: TextDecoration.underline),
      ),
    );
  }

  String getTimeRemaining(String createdAt) {
    // Step 1: Parse raw string
    final DateTime parsed = DateTime.parse(createdAt);

    // Step 2: Force it as UAE time (UTC+4)
    final DateTime uaeTime = DateTime.utc(
      parsed.year,
      parsed.month,
      parsed.day,
      parsed.hour,
      parsed.minute,
      parsed.second,
      parsed.millisecond,
      parsed.microsecond,
    );

    // Convert UAE time to UTC
    final DateTime createdUtc = uaeTime.subtract(const Duration(hours: 4));

    // Expiry time
    final DateTime expiryUtc = createdUtc.add(const Duration(hours: 12));

    final DateTime nowUtc = DateTime.now().toUtc();

    if (nowUtc.isAfter(expiryUtc)) {
      return "00:00";
    }

    final Duration remaining = expiryUtc.difference(nowUtc);

    final int hours = remaining.inHours;
    final int minutes = remaining.inMinutes % 60;

    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}";
  }

  Widget _buildApplyForLeave() {
    return Consumer<LeaveViewModel>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(strings.apply_for_leave, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Text(
                  '${strings.date} : ${TimeUtils.getCurrentDateTimeInLocal(Constant.EEEE_dd_MM_yyyy)}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: MCustomDropdown<LeaveType>(
                        label: '${strings.leave_type} *',
                        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        initialItem: provider.selectedLeaveType,
                        hintText: strings.select_leave_type,
                        borderColor: Colors.white,
                        showSearch: false,
                        items: provider.leaveTypes,
                        headerBuilder: (context, item, isSelected) => Text(
                          item.name,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: MColors.black, fontWeight: FontWeight.w500),
                        ),
                        listItemBuilder: (context, item, isSelected, onItemSelect) {
                          final theme = Theme.of(context);
                          return GestureDetector(
                            onTap: () => GlobalTap.safeTap(onItemSelect),
                            child: Container(
                              color: Colors.transparent,
                              child: Text(
                                item.name,
                                style: theme.textTheme.bodyMedium?.copyWith(color: MColors.black, fontWeight: FontWeight.normal),
                              ),
                            ),
                          );
                        },
                        onChanged: (value) {
                          if (value != null) {
                            provider.setLeaveType(value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                if (provider.selectedLeaveType?.id == Constant.LEAVE_TYPE_EMERGENCY) ...[
                  const SizedBox(height: 15),
                  _buildTextField(strings.reason_incase_of_emergency, provider.emergencyReasonController, maxLines: 3, isRequired: true),
                ],
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(child: _buildDatePicker(provider, DateTypes.startDate, provider.startDate)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildDatePicker(provider, DateTypes.endDate, provider.endDate)),
                  ],
                ),
                const SizedBox(height: 3),
                Text('${strings.number_of_leave_days} : ${provider.numberOfLeaveDays + 1}'),
                const SizedBox(height: 15),
                Row(children: [Expanded(child: _buildDatePicker(provider, DateTypes.reportingDate, provider.reportingDate))]),
                const SizedBox(height: 15),
                _buildTextField(strings.contact_address_during_leave, provider.contactAddressController, isRequired: true),
                const SizedBox(height: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${strings.contact_number_during_leave} *',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Container(
                          width: 100,
                          decoration: BoxDecoration(
                            color: MColors.white,
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            border: Border(right: BorderSide(color: MColors.grey.withValues(alpha: 0.5))),
                          ),
                          child: CountryCodePicker(
                            onChanged: (code) => provider.setCountryCode(code),
                            initialSelection: provider.selectedCountryCode,
                            favorite: ['+971', '+91'],
                            showCountryOnly: false,
                            showOnlyCountryWhenClosed: false,
                            alignLeft: false,
                            textStyle: TextStyle(fontSize: 14, color: MColors.black),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: provider.contactNumberController,
                            onTapOutside: (event) {
                              FocusScope.of(context).unfocus();
                            },
                            keyboardType: TextInputType.phone,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            maxLength: 12,
                            decoration: InputDecoration(
                              counter: const SizedBox(),
                              filled: true,
                              fillColor: MColors.white,
                              hintText: strings.contact_number,
                              hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: MColors.grey),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 0),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                if (provider.selectedLeaveType?.id == Constant.LEAVE_TYPE_SICK) ...[_buildCertificateUpload(provider)],
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(color: MColors.primaryGreen, borderRadius: BorderRadius.circular(2)),
                        child: TextButton(
                          onPressed: () => GlobalTap.safeTap(() {
                            provider.submitLeave(context);
                          }),
                          child: Text(
                            strings.submit,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: MColors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDatePicker(LeaveViewModel provider, DateTypes dateType, DateTime? date, {bool enable = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${dateType == DateTypes.startDate
              ? strings.start_date
              : dateType == DateTypes.reportingDate
              ? strings.date_of_reporting_after_leave
              : strings.end_date} *',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        InkWell(
          onTap: () => GlobalTap.safeTap(() {
            if (!enable) return;
            if (dateType == DateTypes.endDate) {
              if (provider.startDate == null) {
                SnackBarMsg.showErrorMessage(context, strings.please_select_start_date_first);
                return;
              }
            }
            provider.pickDueDate(context, dateType);
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

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1, bool enabled = true, bool isRequired = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label ${isRequired ? '*' : ''}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 5),
        TextField(
          enabled: enabled,
          controller: controller,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: MColors.black, fontWeight: FontWeight.w600),
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

  Widget _buildCertificateUpload(LeaveViewModel provider, {bool showHeading = true}) {
    final bool hasFile = provider.certificateFile != null;
    final bool isPdf = provider.isCertificatePdf;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeading)
          Text(strings.upload_sick_leave_certificate, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 5),
        if (!hasFile)
          // Upload area
          GestureDetector(
            onTap: () => GlobalTap.safeTap(() => provider.pickCertificateFromFiles(context)),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: BoxDecoration(
                color: MColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: MColors.grey.withValues(alpha: 0.3), style: BorderStyle.solid),
              ),
              child: Row(
                children: [
                  Text(strings.tap_to_upload_certificate, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MColors.grey)),
                  Spacer(),
                  Icon(Icons.file_upload_outlined, size: 25),
                ],
              ),
            ),
          )
        else
          // File preview card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: MColors.white, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                // Thumbnail or PDF icon
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: isPdf
                      ? Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(6)),
                          child: Icon(Icons.picture_as_pdf, color: MColors.red, size: 30),
                        )
                      : Image.file(provider.certificateFile!, width: 50, height: 50, fit: BoxFit.cover),
                ),
                const SizedBox(width: 12), // File name & view link
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.certificateFileName ?? 'Certificate',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => GlobalTap.safeTap(() => provider.viewCertificate(context)),
                        child: Text(
                          strings.view_certificate,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MColors.primaryGreen, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ), // Remove button
                GestureDetector(
                  onTap: () => GlobalTap.safeTap(() => provider.removeCertificate()),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: MColors.red.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: Icon(Icons.close, color: MColors.red, size: 18),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget buildCertificateFromUrl({required BuildContext context, required String certificateUrl}) {
    final bool isPdf = certificateUrl.toLowerCase().endsWith('.pdf');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: MColors.white, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: isPdf
                ? Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(6)),
                    child: Icon(Icons.picture_as_pdf, color: MColors.red, size: 30),
                  )
                : CachedNetworkImage(
                    imageUrl: certificateUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorWidget: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50),
                  ),
          ),

          const SizedBox(width: 12),

          // File name & view
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  certificateUrl.split('/').last,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () async {
                    if (isPdf) {
                      final Uri uri = Uri.parse(certificateUrl);

                      if (!await launchUrl(uri, mode: LaunchMode.inAppBrowserView)) {
                        SnackBarMsg.showErrorMessage(context, 'Error opening PDF');
                      }
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CertificateViewerScreen(
                            file: File(''),
                            fileName: certificateUrl.split('/').last,
                            isPdf: false,
                            imageUrl: certificateUrl,
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    strings.view_certificate,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MColors.primaryGreen, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  showApproveRejectDialog(int leaveId, BuildContext context, LeaveModel leaveModel) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      barrierColor: MColors.black.withValues(alpha: 0.4),
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
          child: Center(
            child: Dialog(
              backgroundColor: MColors.greyBackground,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              insetPadding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(strings.leave_application, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              strings.leave_type,
                              TextEditingController(
                                text: leaveModel.leaveType == Constant.LEAVE_TYPE_EMERGENCY
                                    ? strings.emergency
                                    : leaveModel.leaveType == Constant.LEAVE_TYPE_SICK
                                    ? strings.sick
                                    : strings.annual,
                              ),
                              enabled: false,
                            ),
                          ),
                        ],
                      ),
                      if (leaveModel.leaveType == Constant.LEAVE_TYPE_EMERGENCY) ...[
                        const SizedBox(height: 10),
                        _buildTextField(
                          strings.reason_incase_of_emergency,
                          TextEditingController(text: leaveModel.emergencyReason),
                          maxLines: 3,
                          enabled: false,
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDatePicker(
                              _leaveViewModel,
                              DateTypes.startDate,
                              leaveModel.startDate != null ? DateTime.tryParse(leaveModel.startDate!) : null,
                              enable: false,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildDatePicker(
                              _leaveViewModel,
                              DateTypes.endDate,
                              leaveModel.endDate != null ? DateTime.tryParse(leaveModel.endDate!) : null,
                              enable: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${strings.number_of_leave_days} : ${DateTime.tryParse(leaveModel.endDate!)?.difference(DateTime.tryParse(leaveModel.startDate!) ?? TimeUtils.getCurrentDateTime()).inDays ?? -1 + 1}',
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDatePicker(
                              _leaveViewModel,
                              DateTypes.reportingDate,
                              leaveModel.reportingDate != null ? DateTime.tryParse(leaveModel.reportingDate!) : null,
                              enable: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(strings.contact_address_during_leave, TextEditingController(text: leaveModel.contactAddress), enabled: false),
                      const SizedBox(height: 10),
                      _buildTextField(strings.contact_number_during_leave, TextEditingController(text: leaveModel.contactNumber), enabled: false),
                      const SizedBox(height: 10),
                      if (leaveModel.leaveType == Constant.LEAVE_TYPE_SICK && leaveModel.leaveCertificate != null) ...[
                        buildCertificateFromUrl(context: context, certificateUrl: leaveModel.leaveCertificate!),
                      ],
                      const SizedBox(height: 20),
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(color: MColors.red.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(2)),
                                  child: TextButton(
                                    onPressed: () => GlobalTap.safeTap(() {
                                      _leaveViewModel.updateLeaveStatus(context, leaveId, 2);
                                    }),
                                    child: Text(
                                      strings.reject,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: MColors.white, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(color: MColors.primaryGreen, borderRadius: BorderRadius.circular(2)),
                                  child: TextButton(
                                    onPressed: () => GlobalTap.safeTap(() {
                                      _leaveViewModel.updateLeaveStatus(context, leaveId, 1);
                                    }),
                                    child: Text(
                                      strings.approve,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: MColors.white, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(color: MColors.transparent, borderRadius: BorderRadius.circular(2)),
                                  child: TextButton(
                                    onPressed: () => GlobalTap.safeTap(() {
                                      Navigator.pop(context);
                                    }),
                                    child: Text(
                                      strings.cancel,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: MColors.black, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  showPendingCertificateDialog(int leaveId, BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      barrierColor: MColors.black.withValues(alpha: 0.4),
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
          child: Center(
            child: Dialog(
              backgroundColor: MColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Consumer<LeaveViewModel>(
                builder: (context, provider, child) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: .start,
                      children: [
                        Text(
                          strings.upload_sick_leave_certificate,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10),
                        _buildCertificateUpload(provider, showHeading: false),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => GlobalTap.safeTap(() {
                                  provider.removeCertificate();
                                  Navigator.pop(context);
                                }),
                                child: Text(strings.cancel, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                              ),
                            ),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: MColors.primaryGreen,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                ),
                                onPressed: () => GlobalTap.safeTap(() => provider.uploadPendingCertificate(leaveId, context)),
                                child: Text(
                                  strings.submit,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: MColors.white, fontWeight: FontWeight.w600),
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
          ),
        );
      },
    );
  }
}

/// Full-screen certificate viewer for both images and PDFs
class CertificateViewerScreen extends StatelessWidget {
  final File file;
  final String fileName;
  final String? imageUrl;
  final bool isPdf;

  const CertificateViewerScreen({super.key, required this.file, required this.fileName, required this.isPdf, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          fileName,
          style: const TextStyle(fontSize: 16, color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: isPdf
          ? PDFView(filePath: file.path, enableSwipe: true, swipeHorizontal: false, autoSpacing: true, pageFling: true, fitPolicy: FitPolicy.BOTH)
          : InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: imageUrl == null ? Image.file(file, fit: BoxFit.contain) : CachedNetworkImage(imageUrl: imageUrl!, fit: BoxFit.contain),
              ),
            ),
    );
  }
}

class LeaveType {
  final int id;
  final String name;
  LeaveType({required this.id, required this.name});
}
