import 'package:panamera_app/utils/constant.dart';

class AmcCalendarModel {
  final String? date;
  final String? amcJobName;
  final int? amcId;
  final int? amcJobId;
  final String? customerId;
  final String? customerName;
  final String? supervisorId;
  final String? supervisorName;
  final int? villaId;
  final int? visitType;

  AmcCalendarModel({
    this.date,
    this.amcJobName,
    this.amcId,
    this.amcJobId,
    this.customerId,
    this.customerName,
    this.supervisorId,
    this.supervisorName,
    this.villaId,
    this.visitType,
  });

  @override
  String toString() {
    return amcJobName ?? '';
  }

  factory AmcCalendarModel.fromJson(Map<String, dynamic> json) {
    return AmcCalendarModel(
      date: json[Constant.date] as String?,
      amcJobName: json[Constant.amcJobName] as String?,
      amcId: json[Constant.amcId] as int?,
      amcJobId: json[Constant.amcJobId] ?? -1,
      customerId: json[Constant.customerId] as String?,
      customerName: json[Constant.customerName] as String?,
      supervisorId: json[Constant.supervisorId] as String?,
      supervisorName: json[Constant.supervisorName] as String?,
      villaId: json[Constant.villaId] as int?,
      visitType: json[Constant.visitType] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    Constant.date: date,
    Constant.amcJobName: amcJobName,
    Constant.amcId: amcId,
    Constant.amcJobId: amcJobId,
    Constant.customerId: customerId,
    Constant.customerName: customerName,
    Constant.supervisorId: supervisorId,
    Constant.supervisorName: supervisorName,
    Constant.villaId: villaId,
    Constant.visitType: visitType,
  };
}
