import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert'; // JSON 파싱을 위해 추가

class HomeScreen extends StatelessWidget {
  final FlutterSecureStorage storage = FlutterSecureStorage(); // 토큰 저장소

  Future<void> checkAccessToken(BuildContext context) async {
    try {
      // 저장된 토큰 확인
      String? accessToken = await storage.read(key: 'access_token');
      String? refreshToken = await storage.read(key: 'refresh_token');
      
      if (accessToken == null || accessToken.isEmpty) {
        print('저장된 토큰이 없음! 빈 값으로 요청 보냄');
        accessToken = ''; // 백엔드에서 401을 받을 수 있도록 빈 값으로 요청
        refreshToken = '';
      } else {
        print('가져온 토큰: $accessToken');
      }

      var url = Uri.parse('${dotenv.env['ADDRESS']}/auth-check');

      print('백엔드 요청 시작: $url');

      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accessToken': 'Bearer $accessToken', // 헤더에 토큰 포함
          'refreshToken': 'Bearer $refreshToken',
        },
      );

      print('응답 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        print('200 응답 → 내가 만든 퀴즈 화면으로 이동');
        Navigator.pushNamed(context, '/manQuiz');
      } else if (response.statusCode == 201) {
        // 응답 본문에서 새로운 액세스 토큰 추출
        var responseData = jsonDecode(response.body); // JSON 디코딩
        String accessToken = responseData['accessToken']; // 'accessToken' 값을 추출
        await storage.write(key: 'access_token', value: accessToken);
        print('201 응답 → 새 액세스 토큰 저장: $accessToken');
        
        // 갱신된 토큰으로 다시 백엔드에 요청 보내기
        var newResponse = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'accessToken': 'Bearer $accessToken', // 갱신된 토큰 사용
            'refreshToken': 'Bearer $refreshToken', // 기존 리프레시 토큰 사용
          },
        );

        print('새 요청 응답 코드: ${newResponse.statusCode}');
        print('새 요청 응답 본문: ${newResponse.body}');

        if (newResponse.statusCode == 200) {
          print('새로운 토큰으로 요청 성공 → 내가 만든 퀴즈 화면으로 이동');
          Navigator.pushNamed(context, '/manQuiz');
        } else {
          print('새로운 토큰으로 요청 실패: ${newResponse.statusCode} - ${newResponse.body}');
        }
      } else if (response.statusCode == 401) {
        print('401 응답 → 로그인 화면으로 이동');
        Navigator.pushNamed(context, '/login');
      } else {
        print('기타 오류: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('요청 중 오류 발생: $e');
    }
  }

  @override
  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFB8E0FF), // 전체 배경 색상 통일
    appBar: AppBar(
      backgroundColor: const Color(0xFFB8E0FF),
      elevation: 0,
      centerTitle: true,
      title: Text(
        'QUIZ FACTORY',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.indigo[900],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.person, color: Colors.indigo[900]),
          onPressed: () {
            Navigator.pushNamed(context, '/mypage');
          },
        ),
      ],
    ),
    body: Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.settings, size: 48, color: Colors.indigo[900]),
            SizedBox(height: 16),
            Text(
              '퀴즈를 시작해볼까요?',
              style: TextStyle(fontSize: 18, color: Colors.indigo[900]),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => checkAccessToken(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB8E0FF),
                foregroundColor: Colors.indigo[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: Size(200, 50),
              ),
              child: Text('내가 만든 퀴즈', style: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/enter_code');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB8E0FF),
                foregroundColor: Colors.indigo[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: Size(200, 50),
              ),
              child: Text('코드 입력', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    ),
  );
}
}