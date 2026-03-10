import 'package:panamera_app/utils/constant.dart';

class EmpLoginRes {
  final EmployeeModel employeeData;
  final String refreshToken;
  final String jwt;
  EmpLoginRes({required this.employeeData, required this.refreshToken, required this.jwt});

  factory EmpLoginRes.fromJson(Map<String, dynamic> json) {
    return EmpLoginRes(
      employeeData: EmployeeModel.fromJson(json[Constant.employeeData]),
      refreshToken: json[Constant.refreshToken] as String,
      jwt: json[Constant.jwt] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {Constant.employeeData: employeeData, Constant.refreshToken: refreshToken, Constant.jwt: jwt};
  }
}

class EmployeeModel {
  int? id;
  String? userName;
  String? employeeId;
  String? phoneNumber;
  String? fullName;
  String? nationality;
  String? gender;
  String? dateOfBirth;
  String? dateOfJoining;
  int? roleId;
  int? groupNumber;
  int? roleOrderId;
  String? roleName;
  String? department;
  int? reportingToId;
  String? employmentStatus;
  String? skillSet;
  String? reportingToName;
  String? shiftUpdateTime;
  int? shiftId;
  bool? isTeamLeader;
  List<String>? functionalityKeys;

  EmployeeModel({
    this.id,
    this.userName,
    this.phoneNumber,
    this.employeeId,
    this.fullName,
    this.nationality,
    this.gender,
    this.dateOfBirth,
    this.dateOfJoining,
    this.roleName,
    this.roleId,
    this.groupNumber,
    this.roleOrderId,
    this.department,
    this.reportingToId,
    this.employmentStatus,
    this.skillSet,
    this.reportingToName,
    this.shiftUpdateTime,
    this.shiftId,
    this.isTeamLeader,
    this.functionalityKeys,
  });

  @override
  String toString() {
    return fullName ?? '';
  }

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json[Constant.id],
      userName: json[Constant.userName],
      phoneNumber: json[Constant.phoneNumber],
      employeeId: json[Constant.employeeId],
      fullName: json[Constant.fullName],
      nationality: json[Constant.nationality],
      gender: json[Constant.gender],
      dateOfBirth: json[Constant.dateOfBirth],
      dateOfJoining: json[Constant.dateOfJoining],
      roleId: json[Constant.roleId],
      groupNumber: json[Constant.groupNumber] ?? 0,
      roleOrderId: json[Constant.roleOrderId] ?? 0,
      roleName: json[Constant.roleName],
      department: json[Constant.department],
      reportingToId: json[Constant.reportingToId],
      employmentStatus: json[Constant.employmentStatus],
      skillSet: json[Constant.skillSet],
      reportingToName: json[Constant.reportingToName],
      shiftUpdateTime: json[Constant.shiftUpdateTime],
      shiftId: json[Constant.shiftId],
      isTeamLeader: json[Constant.isTeamLeader],
      functionalityKeys: (json[Constant.functionalityKeys] as List?)?.map((e) => e.toString()).toList(),
    );
  }

  factory EmployeeModel.fromJson2(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json[Constant.id],
      employeeId: json[Constant.employeeId],
      fullName: json[Constant.fullName],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      Constant.id: id,
      Constant.userName: userName,
      Constant.phoneNumber: phoneNumber,
      Constant.employeeId: employeeId,
      Constant.fullName: fullName,
      Constant.nationality: nationality,
      Constant.gender: gender,
      Constant.dateOfBirth: dateOfBirth,
      Constant.dateOfJoining: dateOfJoining,
      Constant.roleId: roleId,
      Constant.groupNumber: groupNumber,
      Constant.roleOrderId: roleOrderId,
      Constant.roleName: roleName,
      Constant.department: department,
      Constant.reportingToId: reportingToId,
      Constant.employmentStatus: employmentStatus,
      Constant.skillSet: skillSet,
      Constant.reportingToName: reportingToName,
      Constant.shiftUpdateTime: shiftUpdateTime,
      Constant.shiftId: shiftId,
      Constant.isTeamLeader: isTeamLeader,
      Constant.functionalityKeys: functionalityKeys,
    };
  }

  Map<String, dynamic> toJsonUpdateProfile() {
    return {
      Constant.phoneNumber: phoneNumber,
      Constant.fullName: fullName,
      Constant.nationality: nationality,
      Constant.gender: gender,
      Constant.dateOfBirth: dateOfBirth,
      Constant.dateOfJoining: dateOfJoining,
    };
  }
}
