import 'package:panamera_app/utils/constant.dart';

class ProjectModel {
  int? id;
  String? imageUrl;

  ProjectModel({this.id, this.imageUrl});

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(id: map[Constant.id], imageUrl: map[Constant.imageUrl]);
  }

  Map<String, dynamic> toMap() {
    return {Constant.id: id, Constant.imageUrl: imageUrl};
  }
}
