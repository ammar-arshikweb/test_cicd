import 'package:panamera_app/utils/constant.dart';

class AmcJobDetail {
  final int amcJobId;
  final int amcId;
  final int amcJobStatus;
  final String amcJobName;
  final String customerName;
  final String gardenSupervisorName;
  final String poolSupervisorName;
  final String gardenTeamLeaderName;
  final String poolTeamLeaderName;
  final String gardenTeamLeaderId;
  final String poolTeamLeaderId;
  final String gardenSupervisorId;
  final String poolSupervisorId;
  final int completionPercentage;
  final int visitType;
  final List<AmcIssueModel> issues;
  final AmcCommentModel comments;
  final List<AmcTaskModel> poolTask;
  final List<AmcTaskModel> gardenTask;

  AmcJobDetail({
    required this.amcJobId,
    required this.amcId,
    required this.amcJobStatus,
    required this.amcJobName,
    required this.customerName,
    required this.gardenSupervisorName,
    required this.poolSupervisorName,
    required this.gardenTeamLeaderName,
    required this.poolTeamLeaderName,
    required this.gardenTeamLeaderId,
    required this.poolTeamLeaderId,
    required this.gardenSupervisorId,
    required this.poolSupervisorId,
    required this.completionPercentage,
    required this.visitType,
    required this.issues,
    required this.comments,
    required this.poolTask,
    required this.gardenTask,
  });

  factory AmcJobDetail.fromMap(Map<String, dynamic> map) {
    return AmcJobDetail(
      amcJobId: map[Constant.amcJobId],
      amcId: map[Constant.amcId],
      amcJobStatus: map[Constant.amcJobStatus],
      amcJobName: map[Constant.amcJobName],
      customerName: map[Constant.customerName] ?? '',
      gardenSupervisorName: map[Constant.gardenSupervisorName] ?? '',
      poolSupervisorName: map[Constant.poolSupervisorName] ?? '',
      gardenTeamLeaderName: map[Constant.gardenTeamLeaderName] ?? '',
      poolTeamLeaderName: map[Constant.poolTeamLeaderName] ?? '',
      gardenTeamLeaderId: map[Constant.gardenTeamLeaderId] ?? '',
      poolTeamLeaderId: map[Constant.poolTeamLeaderId] ?? '',
      gardenSupervisorId: map[Constant.gardenSupervisorId] ?? '',
      poolSupervisorId: map[Constant.poolSupervisorId] ?? '',
      completionPercentage: map[Constant.completionPercentage] ?? 0,
      visitType: map[Constant.visitType] ?? 0,
      issues: (map[Constant.issues] as List<dynamic>).map((issue) => AmcIssueModel.fromMap(issue)).toList(),
      comments: AmcCommentModel.fromMap(map[Constant.comments] ?? {}),
      poolTask: (map[Constant.poolTask] as List<dynamic>).map((task) => AmcTaskModel.fromMap(task)).toList(),
      gardenTask: (map[Constant.gardenTask] as List<dynamic>).map((task) => AmcTaskModel.fromMap(task)).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      Constant.amcJobId: amcJobId,
      Constant.amcId: amcId,
      Constant.amcJobStatus: amcJobStatus,
      Constant.amcJobName: amcJobName,
      Constant.customerName: customerName,
      Constant.gardenSupervisorName: gardenSupervisorName,
      Constant.poolSupervisorName: poolSupervisorName,
      Constant.gardenTeamLeaderName: gardenTeamLeaderName,
      Constant.poolTeamLeaderName: poolTeamLeaderName,
      Constant.gardenTeamLeaderId: gardenTeamLeaderId,
      Constant.poolTeamLeaderId: poolTeamLeaderId,
      Constant.gardenSupervisorId: gardenSupervisorId,
      Constant.poolSupervisorId: poolSupervisorId,
      Constant.completionPercentage: completionPercentage,
      Constant.visitType: visitType,
      Constant.issues: issues.map((issue) => issue.toMap()).toList(),
      Constant.comments: comments.toMap(),
      Constant.poolTask: poolTask.map((task) => task.toMap()).toList(),
      Constant.gardenTask: gardenTask.map((task) => task.toMap()).toList(),
    };
  }
}

class AmcIssueModel {
  final String title;
  final String notes;
  final int issueId;
  int status;
  final List<String> audioUrls;
  final List<String> imageUrls;
  int priority;
  String? supervisorId;

  AmcIssueModel({
    required this.title,
    required this.notes,
    required this.issueId,
    this.status = 0,
    required this.audioUrls,
    required this.imageUrls,
    this.priority = 0,
    this.supervisorId,
  });

  factory AmcIssueModel.fromMap(Map<String, dynamic> map) {
    return AmcIssueModel(
      title: map[Constant.title] ?? '',
      notes: map[Constant.notes] ?? '',
      issueId: map[Constant.issueId] ?? 0,
      status: map[Constant.status] ?? 0,
      audioUrls: List<String>.from(map[Constant.audioUrls] ?? []),
      imageUrls: List<String>.from(map[Constant.imageUrls] ?? []),
      priority: map[Constant.priority] ?? 0,
      supervisorId: map[Constant.supervisorId] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      Constant.title: title,
      Constant.notes: notes,
      Constant.issueId: issueId,
      Constant.status: status,
      Constant.audioUrls: audioUrls,
      Constant.imageUrls: imageUrls,
      Constant.priority: priority,
      Constant.supervisorId: supervisorId,
    };
  }
}

class AmcTaskModel {
  int status;
  final String dueDate;
  final String category;
  final String taskName;
  final int visitTaskId;
  final dynamic completedAt;

  AmcTaskModel({
    required this.status,
    required this.dueDate,
    required this.category,
    required this.taskName,
    required this.visitTaskId,
    required this.completedAt,
  });

  factory AmcTaskModel.fromMap(Map<String, dynamic> map) {
    return AmcTaskModel(
      status: map[Constant.status] ?? 0,
      dueDate: map[Constant.dueDate] ?? '',
      category: map[Constant.category] ?? '',
      taskName: map[Constant.taskName] ?? '',
      visitTaskId: map[Constant.visitTaskId] ?? 0,
      completedAt: map[Constant.completedAt],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      Constant.status: status,
      Constant.dueDate: dueDate,
      Constant.category: category,
      Constant.taskName: taskName,
      Constant.visitTaskId: visitTaskId,
      Constant.completedAt: completedAt,
    };
  }
}

class AmcCommentModel {
  final String logDate;
  final String comment;
  final List<String> audioUrls;
  final List<String> imageUrls;

  AmcCommentModel({required this.logDate, required this.comment, required this.audioUrls, required this.imageUrls});

  factory AmcCommentModel.fromMap(Map<String, dynamic> map) {
    return AmcCommentModel(
      logDate: map[Constant.logDate] ?? '',
      comment: map[Constant.comment] ?? '',
      audioUrls: List<String>.from(map[Constant.audioUrls] ?? []),
      imageUrls: List<String>.from(map[Constant.imageUrls] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {Constant.logDate: logDate, Constant.comment: comment, Constant.audioUrls: audioUrls, Constant.imageUrls: imageUrls};
  }
}

class IssueRes {
  final int id;

  IssueRes({required this.id});

  factory IssueRes.fromMap(Map<String, dynamic> map) {
    return IssueRes(id: map[Constant.id] ?? 0);
  }

  Map<String, dynamic> toMap() {
    return {Constant.id: id};
  }
}
