import 'package:flutter/material.dart';
import 'package:panamera_app/features/employee/amc/model/amc_model.dart';
import 'package:panamera_app/features/employee/amc/view_model/amc_view_model.dart';
import 'package:panamera_app/l10n/app_localizations.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/global_tap.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/system_ui_manager.dart';
import 'package:panamera_app/utils/time_utils.dart';
import 'package:panamera_app/values/colors.dart';
import 'package:provider/provider.dart';

class AmcScreen extends StatefulWidget {
  const AmcScreen({super.key});

  @override
  State<AmcScreen> createState() => _AmcScreenState();
}

class _AmcScreenState extends State<AmcScreen> {
  late AppLocalizations strings;
  late AmcViewModel amcViewModel;

  @override
  void initState() {
    super.initState();
    amcViewModel = Provider.of<AmcViewModel>(context, listen: false);
    amcViewModel.initModel(context);
  }

  @override
  void dispose() {
    super.dispose();
    amcViewModel.resetModel();
  }

  @override
  Widget build(BuildContext context) {
    strings = Helper.getLocalization()!;
    SystemUIManager.setSystemUI(context: context, statusBarColor: MColors.greyBackground);
    return Scaffold(
      backgroundColor: MColors.greyBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Consumer<AmcViewModel>(
              builder: (context, provider, child) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [buildNameAndDateText(strings)]),
                      ),
                      const SizedBox(height: 30),
                      Expanded(
                        child:
                            provider.jobList.isEmpty
                                ? Center(child: Text(strings.no_jobs_found, style: TextStyle(fontSize: 16, color: MColors.textDarkGrey)))
                                : ListView.builder(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  itemCount: provider.jobList.length,
                                  itemBuilder: (context, index) {
                                    return Padding(padding: const EdgeInsets.only(bottom: 8.0), child: _JobListItem(job: provider.jobList[index]));
                                  },
                                ),
                      ),
                      if (provider.totalPages > 1) buildPaginationFooter(provider, context),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Container buildPaginationFooter(AmcViewModel provider, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            onTap:
                () => GlobalTap.safeTap(() {
                  provider.goToPrevPage(context);
                }),
            child: Row(children: [Icon(Icons.chevron_left), const SizedBox(width: 10), Text(strings.prev)]),
          ),
          Text(
            strings.pageInfo(provider.currentPage, provider.totalPages),
            style: const TextStyle(fontSize: 14, color: MColors.black, fontWeight: FontWeight.w500),
          ),
          InkWell(
            onTap:
                () => GlobalTap.safeTap(() {
                  provider.goToNextPage(context);
                }),
            child: Row(children: [Text(strings.next), const SizedBox(width: 10), Icon(Icons.chevron_right)]),
          ),
        ],
      ),
    );
  }

  Widget buildNameAndDateText(AppLocalizations strings) {
    var time = TimeUtils.getCurrentDateTimeInLocal(Constant.EEEE_dd_MM_yyyy);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(strings.amc_jobs, style: Theme.of(context).textTheme.displaySmall?.copyWith(color: MColors.black, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(
          '${strings.date} : $time',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ), // const SizedBox(height: 8),
      ],
    );
  }
}

class _JobListItem extends StatelessWidget {
  final AmcJob job;

  const _JobListItem({required this.job});

  @override
  Widget build(BuildContext context) {
    AppLocalizations strings = Helper.getLocalization()!;
    return InkWell(
      onTap:
          () => GlobalTap.safeTap(() {
            Navigator.pushNamed(context, Constant.jobScreen, arguments: job).then((v) {
              if (v != null && v == true) {
                Provider.of<AmcViewModel>(context, listen: false).getJobs(context);
              }
            });
          }),
      child: Container(
        color: MColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(job.amcJobName, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      CircleAvatar(radius: 5, backgroundColor: Helper.convertStatus(module: Constant.amcJobs, number: job.amcJobStatus)?.color),
                      const SizedBox(width: 8),
                      Text(
                        Helper.convertStatus(module: Constant.amcJobs, number: job.amcJobStatus)?.label ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MColors.textDarkGrey, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (job.visitType == Constant.VISIT_TYPE_GARDEN) ...[
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
                                  'SV- ${job.gardenSupervisorName}',
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MColors.textDarkGrey, fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  'TL- ${job.gardenTeamLeaderName}',
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MColors.textDarkGrey, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                      ],
                      if (job.visitType == Constant.VISIT_TYPE_POOL)
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
                                  'SV- ${job.poolSupervisorName}',
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MColors.textDarkGrey, fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  'TL- ${job.poolTeamLeaderName}',
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MColors.textDarkGrey, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ), // Spacer(),
            // CircularPercentIndicator(
            //   radius: 25.0,
            //   lineWidth: 5,
            //   percent: job.completionPercentage / 100,
            //   center: Text(
            //     "${job.completionPercentage}%",
            //     style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MColors.textDarkGrey, fontWeight: FontWeight.w600),
            //   ),
            //   progressColor: MColors.lightGreen,
            //   backgroundColor: MColors.grey.withValues(alpha: 0.3),
            //   circularStrokeCap: CircularStrokeCap.square,
            // ),
          ],
        ),
      ),
    );
  }
}
