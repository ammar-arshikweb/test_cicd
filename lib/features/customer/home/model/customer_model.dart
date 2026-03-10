import 'package:dio/dio.dart';
import 'package:panamera_app/utils/constant.dart';

class CustomerModel {
  int? id;
  int? status;
  String? customerId;
  String? customerName;
  String? email;
  String? contactNumber;
  String? emirate;
  String? dateOfBirth;
  List<VillaModel>? villaList;

  CustomerModel({this.id, this.status, this.customerId, this.customerName, this.email, this.contactNumber, this.emirate, this.villaList, this.dateOfBirth});

  @override
  String toString() {
    return customerName ?? '';
  }

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map[Constant.id],
      status: map[Constant.status],
      customerId: map[Constant.customerId],
      customerName: map[Constant.customerName],
      email: map[Constant.email],
      contactNumber: map[Constant.contactNumber],
      emirate: map[Constant.emirate],
      dateOfBirth: map[Constant.dateOfBirth],
      villaList: map[Constant.villaList] != null
          ? List<VillaModel>.from((map[Constant.villaList] as List).map((x) => VillaModel.fromMap(x)))
          : null,
    );
  }

  factory CustomerModel.fromMap2(Map<String, dynamic> map) {
    return CustomerModel(
      id: map[Constant.id],
      customerId: map[Constant.customerId],
      customerName: map[Constant.customerName],
      villaList: map[Constant.villaList] != null
          ? List<VillaModel>.from((map[Constant.villaList] as List).map((x) => VillaModel.fromMap(x)))
          : null,
    );
  }

  FormData buildCustomerFormData(CustomerModel customer){
    return FormData.fromMap({
      Constant.customerId: customer.customerId,
      Constant.customerName: customer.customerName,
      Constant.email: customer.email,
      Constant.contactNumber: customer.contactNumber,
      Constant.emirate: customer.emirate,
      Constant.dateOfBirth: customer.dateOfBirth,
      Constant.villaList: customer.villaList?.map((x) => x.toMap()).toList(),
    });
  }

  Map<String, dynamic> toMap() {
    return {
      Constant.id: id,
      Constant.status: status,
      Constant.customerId: customerId,
      Constant.customerName: customerName,
      Constant.email: email,
      Constant.contactNumber: contactNumber,
      Constant.emirate: emirate,
      Constant.dateOfBirth: dateOfBirth,
      Constant.villaList: villaList?.map((x) => x.toMap()).toList(),
    };
  }
}

class VillaModel{
  int? villaId;
  String? villaName;
  String? community;
  String? villaImage;

  VillaModel({this.villaId, this.villaName, this.community, this.villaImage});

  @override
  String toString() {
    return villaName ?? '';
  }

  factory VillaModel.fromMap(Map<String, dynamic> map) {
    return VillaModel(
      villaId: map[Constant.villaId],
      villaName: map[Constant.villaName],
      community: map[Constant.community],
      villaImage: map[Constant.villaImage],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      Constant.villaId: villaId,
      Constant.villaName: villaName,
      Constant.community: community,
      Constant.villaImage: villaImage,
    };
  }
}