import 'package:pink_acg/app/http/dao/login_dao.dart';

/// 全局config配置文件
class PinkConstants {
  // static String domain = "10.0.2.2";
  // static String domain = "localhost";
  static String domain = "110.42.168.231";
  static String ossDomain = "https://img.catacg.cn";
  static String port = "8080";
  static String versionPath = "/api/v1";
  static String qq = "3142493883";
  // 登录token验证
  static const Authorization = 'Authorization';
  static header() {
    Map<String, dynamic> header = {};
    header[Authorization] = LoginDao.getBoardingPass();
    return header;
  }
}
