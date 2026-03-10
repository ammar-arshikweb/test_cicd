import 'package:panamera_app/utils/constant.dart';

class CstLoginRes {
  final CustomerData customerData;
  final String refreshToken;
  final String jwt;
  CstLoginRes({required this.customerData, required this.refreshToken, required this.jwt});

  factory CstLoginRes.fromJson(Map<String, dynamic> json) {
    return CstLoginRes(
      customerData: CustomerData.fromMap(json[Constant.customerData]),
      refreshToken: json[Constant.refreshToken] as String,
      jwt: json[Constant.jwt] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {Constant.customerData: customerData, Constant.refreshToken: refreshToken, Constant.jwt: jwt};
  }
}

class CustomerData {
  int? id;
  String? customerId;
  String? customerName;
  String? email;
  String? contactNumber;
  String? emirate;

  CustomerData({this.id, this.customerId, this.customerName, this.email, this.contactNumber, this.emirate});

  @override
  String toString() {
    return customerName ?? '';
  }

  factory CustomerData.fromMap(Map<String, dynamic> map) {
    return CustomerData(
      id: map[Constant.id],
      customerId: map[Constant.customerId],
      customerName: map[Constant.customerName],
      email: map[Constant.email],
      contactNumber: map[Constant.contactNumber],
      emirate: map[Constant.emirate] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      Constant.id: id,
      Constant.customerId: customerId,
      Constant.customerName: customerName,
      Constant.email: email,
      Constant.contactNumber: contactNumber,
      Constant.emirate: emirate,
    };
  }
}
