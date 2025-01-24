import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
      final url = Uri.parse(''); // 서버의 로그인 API
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userID, 'password': password}),
      );

      if (response.statusCode == 200) {
        // 로그인 성공
        final responseData = jsonDecode(response.body);

        final accessToken = responseData['accessToken'];
        final refreshToken = responseData['refreshToken'];

        // 토큰 저장
        await _LoginScreenState.storage.write(key: 'accessToken', value: accessToken); // static으로 선언했으므로 클래스 이름으로 접근
        await _LoginScreenState.storage.write(key: 'refreshToken', value: refreshToken);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 성공')),
        );

        // 퀴즈 관리 화면으로 이동
        Navigator.pushNamed(context, '/manQuiz');
      } else {
        // 로그인 실패
        Map<String, dynamic> responseData = jsonDecode(response.body);
        print(responseData);
        if (responseData["message"] == "invalid pwd"){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('비밀번호를 확인해 주세요')),
        );
        }
        else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('이메일을 확인해 주세요')),
        );
        }
      }
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
                labelText: '아이디',
                hintText: '아이디를 입력하세요',
                labelStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(width: 1, color: const Color.fromARGB(255, 0, 0, 0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(width: 1, color: const Color.fromARGB(255, 0, 0, 0)),
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
                labelStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(width: 1, color: const Color.fromARGB(255, 0, 0, 0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(width: 1, color: const Color.fromARGB(255, 0, 0, 0)),
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: Text('회원가입'),
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
