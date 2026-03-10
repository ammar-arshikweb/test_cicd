import 'package:dio/dio.dart';
import 'package:panamera_app/utils/constant.dart';

class LeaveModel {
  int? id;
  String? leaveId;
  String? employeeId;
  String? employeeName;
  int? leaveType;
  String? emergencyReason;
  String? startDate;
  String? endDate;
  String? reportingDate;
  String? contactAddress;
  String? contactNumber;
  String? leaveCertificate;
  String? createdAt;
  int? leaveStatus;
  double? timeRemainingForCertificate;

  LeaveModel({
    this.id,
    this.leaveId,
    this.employeeId,
    this.employeeName,
    this.leaveType,
    this.emergencyReason,
    this.startDate,
    this.endDate,
    this.reportingDate,
    this.contactAddress,
    this.contactNumber,
    this.leaveCertificate,
    this.createdAt,
    this.leaveStatus,
    this.timeRemainingForCertificate,
  });

  factory LeaveModel.fromMap(Map<String, dynamic> map) {
    return LeaveModel(
      id: map[Constant.id],
      leaveId: map[Constant.leaveId],
      employeeId: map[Constant.employeeId],
      employeeName: map[Constant.employeeName],
      leaveType: map[Constant.leaveType],
      emergencyReason: map[Constant.emergencyReason],
      startDate: map[Constant.startDate],
      endDate: map[Constant.endDate],
      reportingDate: map[Constant.reportingDate],
      contactAddress: map[Constant.contactAddress],
      contactNumber: map[Constant.contactNumber],
      leaveCertificate: map[Constant.leaveCertificate],
      createdAt: map[Constant.createdAt],
      leaveStatus: map[Constant.leaveStatus],
      timeRemainingForCertificate: map[Constant.timeRemainingForCertificate],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      Constant.id: id,
      Constant.leaveId: leaveId,
      Constant.employeeId: employeeId,
      Constant.employeeName: employeeName,
      Constant.leaveType: leaveType,
      Constant.emergencyReason: emergencyReason,
      Constant.startDate: startDate,
      Constant.endDate: endDate,
      Constant.reportingDate: reportingDate,
      Constant.contactAddress: contactAddress,
      Constant.contactNumber: contactNumber,
      Constant.leaveCertificate: leaveCertificate,
      Constant.createdAt: createdAt,
      Constant.leaveStatus: leaveStatus,
      Constant.timeRemainingForCertificate: timeRemainingForCertificate,
    };
  }

  FormData toFormData(MultipartFile? certificateMultipartFile) {
    return FormData.fromMap({
      Constant.leaveType: leaveType,
      Constant.emergencyReason: emergencyReason,
      Constant.startDate: startDate,
      Constant.endDate: endDate,
      Constant.reportingDate: reportingDate,
      Constant.contactAddress: contactAddress,
      Constant.contactNumber: contactNumber,
      Constant.leaveCertificate: certificateMultipartFile,
    });
  }
}
