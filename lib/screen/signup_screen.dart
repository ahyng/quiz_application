import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _verificationCodeController = TextEditingController();
  final Dio dio = Dio();

  bool _isLoading = false;
  bool _isEmailVerified = false;
  bool _codeSent = false;
  String? otp;

  // 이메일 인증 요청
  Future<void> sendVerificationCode() async {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이메일을 입력하세요.')),
      );
      return;
    }

    try {
      final response = await dio.post(
        '${dotenv.env['ADDRESS']}/send-email',
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        setState(() {
          _codeSent = true;
          otp = response.data['otp'].toString();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('인증번호가 이메일로 전송되었습니다.')),
        );
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 409) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미 존재하는 이메일입니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류 발생: $e')),
        );
      }
    }
  }

  // 이메일 인증 코드 확인
  void verifyCode() {
    if (_verificationCodeController.text.trim() == otp) {
      setState(() {
        _isEmailVerified = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이메일 인증이 완료되었습니다.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('잘못된 인증번호입니다.')),
      );
    }
  }

  // 회원가입 처리
  Future<void> handleSignup() async {
    if (!_isEmailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이메일 인증을 완료해주세요.')),
      );
      return;
    }

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('모든 빈칸을 입력하세요.')),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('비밀번호는 8자 이상이어야 합니다.')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await dio.post(
        '${dotenv.env['ADDRESS']}/sign-up',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('회원가입 성공')),
        );
        Navigator.pushNamed(context, '/login');
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 409) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미 존재하는 이메일입니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류 발생: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: '이메일',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: sendVerificationCode,
                    child: Text('이메일 확인'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            TextField(
              controller: _verificationCodeController,
              decoration: InputDecoration(
                labelText: '인증번호 입력',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: verifyCode,
                    child: Text('인증 확인'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: '비밀번호',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: '비밀번호 확인',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: handleSignup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isEmailVerified ? const Color(0xFFB8E0FF) : const Color.fromARGB(255, 10, 247, 255),
                      foregroundColor: const Color(0xFF212121),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text('회원가입'),
                  ),
          ],
        ),
      ),
    );
  }
}