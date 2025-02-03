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
        SnackBar(content: Text('아이디와 비밀번호를 모두 입력하세요.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse(''); // 서버 로그인 API
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userID, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final accessToken = responseData['accessToken'];
        final refreshToken = responseData['refreshToken'];
        final cookie = response.headers['set-cookie']; // 서버에서 쿠키 받아오기

        await _LoginScreenState.storage.write(key: 'accessToken', value: accessToken);
        await _LoginScreenState.storage.write(key: 'refreshToken', value: refreshToken);
        
        if (cookie != null) {
          await _LoginScreenState.storage.write(key: 'cookie', value: cookie);
          print('저장된 쿠키: $cookie');
        } else {
          print('서버에서 쿠키를 받지 못함');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 성공')),
        );
        Navigator.pushNamed(context, '/manQuiz');
      }
      else {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        String message = responseData["message"] == "invalid pwd"
            ? "비밀번호를 확인해 주세요"
            : "아이디를 확인해 주세요";
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
