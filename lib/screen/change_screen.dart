import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final Dio dio = Dio();

  bool _codeSent = false;
  bool _isVerified = false;
  String? otp; // 백엔드에서 받은 인증번호 저장

  // 인증번호 요청
  Future<void> _sendVerificationCode() async {
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
        print(response.data['otp']);
        setState(() {
          _codeSent = true;
          otp = response.data['otp'].toString(); // 인증번호 저장
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('인증번호가 이메일로 전송되었습니다.')),
        );
        print(response.data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이메일 전송 실패: ${response.data}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류 발생: $e')),
      );
    }
  }

  // 인증번호 확인 (프론트에서 직접 비교)
  void _verifyCode() {
    String code = _codeController.text.trim();

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('인증번호를 입력하세요.')),
      );
      return;
    }

    if (code == otp) {
      setState(() {
        _isVerified = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('인증 완료! 새 비밀번호를 입력하세요.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('인증번호가 틀렸습니다. 다시 시도하세요.')),
      );
    }
  }

  // 비밀번호 변경
  Future<void> _changePassword() async {
    String email = _emailController.text.trim();
    String newPassword = _newPasswordController.text.trim();

    if (newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('새 비밀번호를 입력하세요.')),
      );
      return;
    }

    try {
      final response = await dio.post(
        '${dotenv.env['ADDRESS']}/change-password',
        data: {'email': email, 'newPassword': newPassword},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('비밀번호 변경 완료! 로그인하세요.')),
        );

        Navigator.pop(context); // 로그인 화면으로 이동
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('비밀번호 변경 실패: ${response.data}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류 발생: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('비밀번호 찾기')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: '이메일'),
            ),
            SizedBox(height: 16),
            _codeSent
                ? Column(
                    children: [
                      TextField(
                        controller: _codeController,
                        decoration: InputDecoration(labelText: '인증번호'),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _verifyCode,
                        child: Text('인증번호 확인'),
                      ),
                    ],
                  )
                : ElevatedButton(
                    onPressed: _sendVerificationCode,
                    child: Text('인증번호 요청'),
                  ),
            SizedBox(height: 16),
            if (_isVerified) ...[
              TextField(
                controller: _newPasswordController,
                decoration: InputDecoration(labelText: '새 비밀번호'),
                obscureText: true,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _changePassword,
                child: Text('비밀번호 변경'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
