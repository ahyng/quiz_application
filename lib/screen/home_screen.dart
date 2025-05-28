import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterSecureStorage storage = FlutterSecureStorage(); // 토큰 저장소
  DateTime? _lastBackPressed; // 뒤로가기 시간 추적

  Future<void> checkAccessToken(BuildContext context) async {
    try {
      String? accessToken = await storage.read(key: 'access_token');
      String? refreshToken = await storage.read(key: 'refresh_token');

      if (accessToken == null || accessToken.isEmpty) {
        print('저장된 토큰이 없음! 빈 값으로 요청 보냄');
        accessToken = '';
        refreshToken = '';
      } else {
        print('가져온 토큰: $accessToken');
      }

      var url = Uri.parse('${dotenv.env['ADDRESS']}/main');
      print('백엔드 요청 시작: $url');

      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accessToken': 'Bearer $accessToken',
          'refreshToken': 'Bearer $refreshToken',
        },
      );

      print('응답 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        print('200 응답 → 내가 만든 퀴즈 화면으로 이동');
        Navigator.pushNamed(context, '/manQuiz');
      } else if (response.statusCode == 201) {
        var responseData = jsonDecode(response.body);
        print('201 응답 데이터: $responseData');

        String accessToken = responseData['accessToken'];
        if (accessToken == null || accessToken.isEmpty) {
          print('accessToken이 응답에 없습니다!');
          return;
        }
        await storage.write(key: 'access_token', value: accessToken);
        print('201 응답 → 새 액세스 토큰 저장: $accessToken');

        refreshToken ??= '';

        Navigator.pushNamed(context, '/manQuiz');
      } else if (response.statusCode == 401) {
        print('401 응답 → 로그인 화면으로 이동');
        Navigator.pushNamed(context, '/login');
        } else if (response.statusCode == 501) {
          // 네트워크 문제 안내
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('네트워크 연결이 불안정합니다. 잠시 후 다시 시도해주세요.')),
          );
      } else {
        print('기타 오류: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('요청 중 오류 발생: $e');
    }
  }

  Future<bool> onWillPop() async {
    DateTime now = DateTime.now();
    if (_lastBackPressed == null || now.difference(_lastBackPressed!) > Duration(seconds: 2)) {
      _lastBackPressed = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('한 번 더 누르면 종료됩니다')),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFB8E0FF),
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
                  child: Text('퀴즈 풀기', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
