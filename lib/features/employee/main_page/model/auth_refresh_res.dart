import 'package:panamera_app/utils/constant.dart';

class AuthRefreshRes {
  final String? jwt;
  final String? refreshToken;

  AuthRefreshRes({this.jwt, this.refreshToken});

  factory AuthRefreshRes.fromMap(Map<String, dynamic> json) {
    return AuthRefreshRes(jwt: json[Constant.jwt] as String?, refreshToken: json[Constant.refreshToken] as String?);
  }

  Map<String, dynamic> toMap() {
    return {Constant.jwt: jwt, Constant.refreshToken: refreshToken};
  }
}
