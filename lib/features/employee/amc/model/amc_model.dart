import 'package:panamera_app/utils/constant.dart';

class AmcJob {
  final String amcJobName;
  final int amcJobStatus;
  final int amcId;
  final int amcJobId;
  final String gardenTeamLeaderId;
  final String poolTeamLeaderId;
  final String gardenTeamLeaderName;
  final String poolTeamLeaderName;
  final String gardenSupervisorId;
  final String poolSupervisorId;
  final String gardenSupervisorName;
  final String poolSupervisorName;
  final int completionPercentage;
  final int visitType;

  AmcJob({
    required this.amcJobName,
    required this.amcJobStatus,
    required this.amcId,
    required this.amcJobId,
    required this.gardenTeamLeaderId,
    required this.poolTeamLeaderId,
    required this.gardenTeamLeaderName,
    required this.poolTeamLeaderName,
    required this.gardenSupervisorId,
    required this.poolSupervisorId,
    required this.gardenSupervisorName,
    required this.poolSupervisorName,
    required this.completionPercentage,
    required this.visitType,
  });

  factory AmcJob.fromMap(Map<String, dynamic> map) {
    return AmcJob(
      amcJobName: map[Constant.amcJobName],
      amcJobStatus: map[Constant.amcJobStatus],
      amcId: map[Constant.amcId],
      amcJobId: map[Constant.amcJobId],
      gardenTeamLeaderId: map[Constant.gardenTeamLeaderId] ?? '',
      poolTeamLeaderId: map[Constant.poolTeamLeaderId] ?? '',
      gardenTeamLeaderName: map[Constant.gardenTeamLeaderName] ?? '',
      poolTeamLeaderName: map[Constant.poolTeamLeaderName] ?? '',
      gardenSupervisorId: map[Constant.gardenSupervisorId] ?? '',
      poolSupervisorId: map[Constant.poolSupervisorId] ?? '',
      gardenSupervisorName: map[Constant.gardenSupervisorName] ?? '',
      poolSupervisorName: map[Constant.poolSupervisorName] ?? '',
      completionPercentage: map[Constant.completionPercentage],
      visitType: map[Constant.visitType],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      Constant.amcJobName: amcJobName,
      Constant.amcJobStatus: amcJobStatus,
      Constant.amcId: amcId,
      Constant.amcJobId: amcJobId,
      Constant.gardenTeamLeaderId: gardenTeamLeaderId,
      Constant.poolTeamLeaderId: poolTeamLeaderId,
      Constant.gardenTeamLeaderName: gardenTeamLeaderName,
      Constant.poolTeamLeaderName: poolTeamLeaderName,
      Constant.gardenSupervisorId: gardenSupervisorId,
      Constant.poolSupervisorId: poolSupervisorId,
      Constant.gardenSupervisorName: gardenSupervisorName,
      Constant.poolSupervisorName: poolSupervisorName,
      Constant.completionPercentage: completionPercentage,
      Constant.visitType: visitType,
    };
  }
}

class UserHierarchy {
  final int id;
  final String fullName;
  final int roleOrderId;
  final String roleName;
  final String employeeId;

  UserHierarchy({required this.id, required this.fullName, required this.roleOrderId, required this.roleName, required this.employeeId});

  factory UserHierarchy.fromMap(Map<String, dynamic> map) {
    return UserHierarchy(
      id: map[Constant.id],
      fullName: map[Constant.fullName],
      roleOrderId: map[Constant.roleOrderId],
      roleName: map[Constant.roleName],
      employeeId: map[Constant.employeeId],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      Constant.id: id,
      Constant.fullName: fullName,
      Constant.roleOrderId: roleOrderId,
      Constant.roleName: roleName,
      Constant.employeeId: employeeId,
    };
  }
}

class JobCategory {
  final String iconPath;
  final String title;

  JobCategory({required this.iconPath, required this.title});
}
