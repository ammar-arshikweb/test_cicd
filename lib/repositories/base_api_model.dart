import 'package:panamera_app/utils/constant.dart';

class ApiResponse<T> {
  final bool? status;
  final String? successMessage;
  final String? errorMessage;
  final T? data;

  ApiResponse({this.status, this.successMessage, this.errorMessage, this.data});

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    return ApiResponse(
      status: json[Constant.status] as bool,
      successMessage: json[Constant.successMessage],
      errorMessage: json[Constant.errorMessage],
      data: json[Constant.data] != null ? fromJsonT(json[Constant.data]) : null,
    );
  }

  factory ApiResponse.error(Map<String, dynamic> json) {
    return ApiResponse<T>(
      status: json[Constant.status],
      successMessage: json[Constant.successMessage],
      errorMessage: json[Constant.errorMessage],
      data: null,
    );
  }
}

class PaginatedData<T> {
  final List<T> results;
  final PaginationModel pagination;

  PaginatedData({required this.results, required this.pagination});

  factory PaginatedData.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    final List<T> items = (json[Constant.results] as List).map((e) => fromJsonT(e as Map<String, dynamic>)).toList();

    final pagination = PaginationModel.fromJson(json[Constant.pagination]);

    return PaginatedData<T>(results: items, pagination: pagination);
  }
}

class PaginationModel {
  final int totalRecords;
  final int totalPages;
  final int currentPage;
  final int pageSize;

  PaginationModel({
    required this.totalRecords,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      totalRecords: json[Constant.totalRecords] ?? 0,
      totalPages: json[Constant.totalPages] ?? 0,
      currentPage: json[Constant.currentPage] ?? 1,
      pageSize: json[Constant.pageSize] ?? Constant.paginationPageSize,
    );
  }
}

