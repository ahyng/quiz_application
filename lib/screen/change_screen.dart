import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final Dio dio = Dio();
  static const storage = FlutterSecureStorage();

  bool _codeSent = false;
  bool _isVerified = false;
  bool _isLoading = false;
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

    setState(() {
      _isLoading = true; // 로딩 시작
    });

    try {
      final response = await dio.post(
        '${dotenv.env['ADDRESS']}/request-reset-pwd',
        data: {'email': email},
      );

      setState(() {
        _isLoading = false; // 로딩 종료
      });

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

      setState(() {
        _isLoading = false; // 로딩 종료
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류 발생: $e')),
      );
    }
  }

  // 인증번호 확인 (프론트에서 직접 비교)
  Future<void> _verifyCode() async {
    final email = _emailController.text.trim();
    final otp = _codeController.text.trim();

    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('인증번호를 입력하세요.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await dio.post(
        '${dotenv.env['ADDRESS']}/otp-check',
        data: {
          'email': email,
          'otp': otp,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _isVerified = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('인증 완료! 새 비밀번호를 입력하세요.')),
        );
      }
    } catch (e) {
      if (e is DioException) {
        print('OTP 확인 실패: ${e.response?.data}');
        if (e.response?.statusCode == 400) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('인증번호가 유효하지 않거나 만료되었습니다. 다시 시도해주세요.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('예상치 못한 오류: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
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

        await storage.delete(key: 'access_token');
        await storage.delete(key: 'refresh_token');
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false); // 로그인 화면으로 이동
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
      backgroundColor: const Color(0xFFB8E0FF),
      appBar: AppBar(
        title: Text(
          '비밀번호 찾기',
          style: TextStyle(color: Colors.indigo[900]),
        ),
        backgroundColor: const Color(0xFFB8E0FF),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.indigo[900]),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(_emailController, '이메일'),
            const SizedBox(height: 16),
            if (_codeSent) ...[
              _buildTextField(_codeController, '인증번호'),
              const SizedBox(height: 16),
              _buildMainButton('인증번호 확인', _verifyCode),
            ] else if (_isLoading) ...[
              const SizedBox(height: 32),
              Center(child: CircularProgressIndicator()),
            ] else ...[
              _buildMainButton('인증번호 요청', _sendVerificationCode),
            ],
            const SizedBox(height: 16),
            if (_isVerified) ...[
              _buildTextField(_newPasswordController, '새 비밀번호', obscureText: true),
              const SizedBox(height: 16),
              _buildMainButton('비밀번호 변경', _changePassword),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildMainButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(text, style: TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo[900],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
