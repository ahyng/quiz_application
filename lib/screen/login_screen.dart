import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _IDController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  static const storage = FlutterSecureStorage();
  bool _isLoading = false;
  final Dio dio = Dio();

  Future<void> _handleLogin() async {
    String userID = _IDController.text.trim();
    String password = _passwordController.text.trim();
    

    if (userID.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이메일과 비밀번호를 모두 입력하세요.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await login(userID, password, context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('에러 발생: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('로그인 화면')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _IDController,
              decoration: InputDecoration(
                labelText: '이메일',
                hintText: '이메일을 입력하세요',
                labelStyle: TextStyle(color: Colors.black),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(width: 1, color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(width: 1, color: Colors.black),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: '비밀번호',
                hintText: '비밀번호를 입력하세요',
                labelStyle: TextStyle(color: Colors.black),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(width: 1, color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(width: 1, color: Colors.black),
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.bottomRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/changepw');
                    },
                    child: Text('비밀번호를 잊으셨나요?'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: Text('회원가입'),
                  ),
                ],
              ),
            ),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB8E0FF),
                      foregroundColor: const Color(0xFF212121),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      minimumSize: Size(200, 50),
                    ),
                    child: Text('로그인', style: TextStyle(fontSize: 20)),
                  ),
          ],
        ),
      ),
    );
  }
}

// 로그인 함수 Dio 사용
Future<void> login(String userID, String password, BuildContext context) async {
  final storage = FlutterSecureStorage();
  final dio = Dio();

  try {
    final response = await dio.post(
      '${dotenv.env['ADDRESS']}/sign-in',
      data: {'userId': userID, 'password': password},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    print("Response Data: ${response.data}");

    if (response.statusCode == 200) {
      final data = response.data;
      if (data != null && data['accessToken'] != null && data['refreshToken'] != null) {
        final accessToken = data['accessToken'];
        final refreshToken = data['refreshToken'];

        await storage.write(key: "access_token", value: accessToken);
        await storage.write(key: "refresh_token", value: refreshToken);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 성공')),
        );

        Navigator.pushReplacementNamed(
          context,
          '/manQuiz',
          arguments: {
            'accessToken': accessToken,
            'refreshToken': refreshToken,
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 응답 오류: 액세스 토큰 없음')),
        );
      }
    }
  } on DioException catch (e) {
    if (e.response != null && e.response!.data != null) {
      final message = e.response!.data["message"];
      if (message == "invalid pwd") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("비밀번호를 확인해 주세요")),
        );
      } else if (message == "user not found") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("이메일을 확인해 주세요")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("오류: $message")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("서버 응답이 없습니다. 네트워크 상태를 확인하세요.")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('예상치 못한 오류: $e')),
    );
  }
}
