import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:cookie_jar/http.dart';
import 'package:http_cookie_manager/http_cookie_manager.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _IDController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  static const storage = FlutterSecureStorage();
  bool _isLoading = false;
  final cookieJar = CookieJar();
  late http.Client client;

  @override
  void initState() {
    super.initState();
    client = http.Client();
    client = HttpClientWithCookieManager(CookieManager(cookieJar));
  }

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
      final url = Uri.parse('https://yourapi.com/login'); // 서버 로그인 API
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userID, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final accessToken = responseData['accessToken'];
        final refreshToken = responseData['refreshToken'];

        await storage.write(key: 'accessToken', value: accessToken);
        await storage.write(key: 'refreshToken', value: refreshToken);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 성공')),
        );
        Navigator.pushNamed(context, '/manQuiz');
      } else {
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

  Future<void> sendRequestWithCookies() async {
    final url = Uri.parse('https://yourapi.com/protected-route');
    final response = await client.get(url);
    
    if (response.statusCode == 200) {
      print('Response: ${response.body}');
    } else {
      print('Failed to load data');
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
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: '비밀번호',
                hintText: '비밀번호를 입력하세요',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _handleLogin,
                    child: Text('로그인', style: TextStyle(fontSize: 20)),
                  ),
          ],
        ),
      ),
    );
  }
}
