import 'package:panamera_app/utils/constant.dart';

class CstLoginReq {
  final String emailId;
  final String password;

  CstLoginReq({
    required this.emailId,
    required this.password,
  });

  factory CstLoginReq.fromMap(Map<String, dynamic> json) {
    return CstLoginReq(
      emailId: json[Constant.emailId] as String,
      password: json[Constant.password] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      Constant.emailId: emailId,
      Constant.password: password,
    };
  }
}
