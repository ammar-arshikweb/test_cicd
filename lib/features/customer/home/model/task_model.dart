import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/log_utils.dart';

class TaskModel {
  int? id;
  String? taskName;
  String? customerId;
  String? customerName;
  int? villaId;
  int? jobType; // 0 One Time Job, 1 AMC JOB, 2 PROJECT JOB
  int? amcJobId;
  int? priority;
  String? reminder; // None, Daily, Weekly Twice, Weekly Once
  String? supervisorId;
  String? teamLeaderId;
  String? teamLeaderName;
  String? notes;
  String? dueDate;
  String? startDate;
  String? requestId;
  String? amcJobName;
  String? villaName;
  int? approvalStatus; // 0 Pending, 1 Approved, 2 Rejected
  int? taskType; // 0 Task, 1 Issue
  int? taskStatus; // 0 Open , 1 Closed, 2 On Hold
  List<String>? images;
  List<XFile>? imagesFile;
  List<String>? audio;
  bool? wasRequested;
  List<CommentsModel>? comments;

  TaskModel({
    this.id,
    this.taskName,
    this.customerId,
    this.customerName,
    this.villaId,
    this.jobType,
    this.amcJobId,
    this.priority,
    this.reminder,
    this.supervisorId,
    this.teamLeaderId,
    this.teamLeaderName,
    this.notes,
    this.dueDate,
    this.startDate,
    this.requestId,
    this.amcJobName,
    this.villaName,
    this.approvalStatus,
    this.taskType,
    this.taskStatus,
    this.images,
    this.imagesFile,
    this.audio,
    this.wasRequested,
    this.comments,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map[Constant.id],
      taskName: map[Constant.taskName],
      customerId: map[Constant.customerId],
      customerName: map[Constant.customerName],
      villaId: map[Constant.villaId],
      jobType: map[Constant.jobType],
      amcJobId: map[Constant.amcJobId],
      priority: map[Constant.priority],
      reminder: map[Constant.reminder],
      supervisorId: map[Constant.supervisorId],
      teamLeaderId: map[Constant.teamLeaderId],
      teamLeaderName: map[Constant.teamLeaderName],
      notes: map[Constant.notes],
      dueDate: map[Constant.dueDate],
      startDate: map[Constant.startDate],
      requestId: map[Constant.requestId],
      amcJobName: map[Constant.amcJobName],
      villaName: map[Constant.villaName],
      approvalStatus: map[Constant.approvalStatus],
      taskType: map[Constant.taskType],
      taskStatus: map[Constant.taskStatus],
      images: (map[Constant.images] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      audio: (map[Constant.audio] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      wasRequested: map[Constant.wasRequested],
      comments: (map[Constant.comments] as List<dynamic>?)?.map((e) => CommentsModel.fromMap(e)).toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      Constant.id: id,
      Constant.taskName: taskName,
      Constant.customerId: customerId,
      Constant.customerName: customerName,
      Constant.villaId: villaId,
      Constant.jobType: jobType,
      Constant.amcJobId: amcJobId,
      Constant.priority: priority,
      Constant.reminder: reminder,
      Constant.supervisorId: supervisorId,
      Constant.teamLeaderId: teamLeaderId,
      Constant.teamLeaderName: teamLeaderName,
      Constant.notes: notes,
      Constant.dueDate: dueDate,
      Constant.startDate: startDate,
      Constant.requestId: requestId,
      Constant.amcJobName: amcJobName,
      Constant.villaName: villaName,
      Constant.approvalStatus: approvalStatus,
      Constant.taskType: taskType,
      Constant.taskStatus: taskStatus,
      Constant.images: images,
      Constant.audio: audio,
      Constant.wasRequested: wasRequested,
      Constant.comments: comments?.map((e) => e.toMap()).toList(),
    };
  }

  Future<FormData> buildTaskFormData(TaskModel task) async {
    Log.e('Building FormData for TaskModel: ${task.toMap()}');
    // Handle images
    List<MultipartFile> imageMultipart = [];
    if (task.imagesFile != null) {
      if (task.imagesFile!.isNotEmpty) {
        imageMultipart = await Future.wait(
          task.imagesFile!.map((xFile) async {
            return await MultipartFile.fromFile(xFile.path, filename: xFile.name);
          }),
        );
      }
    }

    return FormData.fromMap({
      Constant.taskName: task.taskName,
      Constant.customerId: task.customerId,
      Constant.villaId: task.villaId,
      Constant.jobType: task.jobType,
      Constant.notes: task.notes,
      Constant.approvalStatus: task.approvalStatus,
      Constant.taskType: task.taskType,
      Constant.taskStatus: task.taskStatus,
      Constant.wasRequested: task.wasRequested,
      if (imageMultipart.isNotEmpty) Constant.images: imageMultipart,
    });
  }

  Future<FormData> buildAmcIssueFormData(TaskModel task) async {
    Log.e('Building FormData for AmcIssue: ${task.toMap()}');
    // Handle images
    List<MultipartFile> imageMultipart = [];
    List<MultipartFile> voiceMultipart = [];
    if (task.imagesFile != null) {
      if (task.imagesFile!.isNotEmpty) {
        imageMultipart = await Future.wait(
          task.imagesFile!.map((xFile) async {
            return await MultipartFile.fromFile(xFile.path, filename: xFile.name);
          }),
        );
      }
    }
    if (task.audio != null) {
      if (task.audio!.isNotEmpty) {
        voiceMultipart = await Future.wait(
          task.audio!.map((path) async {
            return await MultipartFile.fromFile(path, filename: path.split('/').last);
          }),
        );
      }
    }

    return FormData.fromMap({
      Constant.taskName: task.taskName,
      Constant.jobType: task.jobType,
      Constant.amcJobId: task.amcJobId,
      Constant.priority: task.priority,
      Constant.notes: task.notes,
      Constant.approvalStatus: task.approvalStatus,
      Constant.taskType: task.taskType,
      Constant.taskStatus: task.taskStatus,
      Constant.wasRequested: task.wasRequested,
      Constant.dueDate: task.dueDate,
      Constant.startDate: task.startDate,
      Constant.supervisorId: task.supervisorId,
      if (imageMultipart.isNotEmpty) Constant.images: imageMultipart,
      if (voiceMultipart.isNotEmpty) Constant.audio: voiceMultipart,
    });
  }

  Future<FormData> buildFullTaskFormData(TaskModel task) async {
    Log.e('Building FormData for Full Task: ${task.toMap()}');
    // Handle images
    List<MultipartFile> imageMultipart = [];
    List<MultipartFile> voiceMultipart = [];
    if (task.imagesFile != null) {
      if (task.imagesFile!.isNotEmpty) {
        imageMultipart = await Future.wait(
          task.imagesFile!.map((xFile) async {
            return await MultipartFile.fromFile(xFile.path, filename: xFile.name);
          }),
        );
      }
    }
    if (task.audio != null) {
      if (task.audio!.isNotEmpty) {
        voiceMultipart = await Future.wait(
          task.audio!.map((path) async {
            return await MultipartFile.fromFile(path, filename: path.split('/').last);
          }),
        );
      }
    }

    return FormData.fromMap({
      Constant.taskName: task.taskName,
      Constant.notes: task.notes,
      Constant.customerId: task.customerId,
      Constant.customerName: task.customerName,
      Constant.villaId: task.villaId,
      Constant.jobType: task.jobType,
      Constant.priority: task.priority,
      Constant.reminder: task.reminder,
      Constant.supervisorId: task.supervisorId,
      Constant.teamLeaderId: task.teamLeaderId,
      Constant.startDate: task.startDate,
      Constant.dueDate: task.dueDate,
      Constant.taskStatus: task.taskStatus,
      Constant.taskType: task.taskType,
      Constant.approvalStatus: task.approvalStatus,
      if (imageMultipart.isNotEmpty) Constant.images: imageMultipart,
      if (voiceMultipart.isNotEmpty) Constant.audio: voiceMultipart,
    });
  }
}

class CommentsModel {
  int? id;
  int? attachmentType; // 0 Image, 1 Audio
  String? path;
  String? employeeId;
  String? employeeName;
  String? createdAt;

  CommentsModel({this.id, this.attachmentType, this.path, this.employeeId, this.employeeName, this.createdAt});

  factory CommentsModel.fromMap(Map<String, dynamic> map) {
    return CommentsModel(
      id: map[Constant.id] ?? 0,
      attachmentType: map[Constant.attachmentType] ?? 0,
      path: map[Constant.path] ?? '',
      employeeId: map[Constant.employeeId] ?? '',
      employeeName: map[Constant.employeeName] ?? '',
      createdAt: map[Constant.createdAt] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      Constant.id: id,
      Constant.attachmentType: attachmentType,
      Constant.path: path,
      Constant.employeeId: employeeId,
      Constant.employeeName: employeeName,
      Constant.createdAt: createdAt,
    };
  }
}
