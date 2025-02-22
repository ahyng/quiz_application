import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  static const storage = FlutterSecureStorage();

  AuthInterceptor(this.dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // ✅ 저장된 accessToken 가져오기
    String? accessToken = await storage.read(key: "access_token");

    if (accessToken != null) {
      options.headers["Authorization"] = "Bearer $accessToken"; // 요청 헤더에 추가
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // ✅ 401 오류 발생 시 토큰 만료 메시지만 출력 (갱신 X)
    if (err.response?.statusCode == 401) {
      print("Access Token 만료됨. 다시 로그인해야 합니다.");
    }

    handler.next(err);
  }
}