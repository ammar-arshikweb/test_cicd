import 'package:panamera_app/utils/constant.dart';

class JobCountsModel{
  final int amcJobsCount;
  final int tasksCount;
  final int issuesCount;

  JobCountsModel({
    required this.amcJobsCount,
    required this.tasksCount,
    required this.issuesCount,
  });

  factory JobCountsModel.fromMap(Map<String, dynamic> map) => JobCountsModel(
    amcJobsCount: map[Constant.amcJobsCount],
    tasksCount: map[Constant.tasksCount],
    issuesCount: map[Constant.issuesCount],
  );

  Map<String, dynamic> toMap() => {
    Constant.amcJobsCount: amcJobsCount,
    Constant.tasksCount: tasksCount,
    Constant.issuesCount: issuesCount,
  };

}