import 'package:panamera_app/utils/constant.dart';

class EmpLoginReq {
  final String userName;
  final String password;

  EmpLoginReq({
    required this.userName,
    required this.password,
  });

  factory EmpLoginReq.fromMap(Map<String, dynamic> json) {
    return EmpLoginReq(
      userName: json[Constant.userName] as String,
      password: json[Constant.password] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      Constant.userName: userName,
      Constant.password: password,
    };
  }
}
