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
  bool _agreedToPrivacy = false;
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

    setState(() {
      _isLoading = true;
    });

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
          SnackBar(content: Text('인증번호가 이메일로 전송되었습니다. 인증번호는 3분동안 유효합니다.')),
        );
      } else {
        // 여기도 처리해야 함
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('인증번호 전송 실패: ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (e is DioException) {
        print('오류 상태 코드: ${e.response?.statusCode}');
        print('응답 데이터: ${e.response?.data}');

        if (e.response?.statusCode == 409) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('이미 존재하는 이메일입니다.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('오류 발생: ${e.message}')),
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


  // 이메일 인증 코드 확인
  Future<void> verifyCode() async {
    final email = _emailController.text.trim();
    final otp = _verificationCodeController.text.trim();

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
          _isEmailVerified = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이메일 인증이 완료되었습니다.')),
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

  void showPrivacyPolicyDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('개인정보 수집 및 이용 동의서'),
      content: SingleChildScrollView(
        child: Text(
          '''1. 수집하는 개인정보 항목
          - 이메일 주소

          2. 개인정보의 수집 및 이용 목적
          - 회원 가입, 로그인, 비밀번호 재설정 등 서비스 제공을 위한 목적

          3. 개인정보의 보관 및 이용 기간
          - 회원 탈퇴 시 이메일 주소를 포함한 개인정보를 즉시 삭제합니다.

          4. 개인정보 제3자 제공
          - 개인정보를 제3자에게 제공하지 않습니다. (단, 법적 요구 사항에 따라 제공될 수 있음)

          5. 개인정보 보호
          - 이메일 주소는 안전하게 저장하며, 외부 접근으로부터 보호됩니다.

          6. 동의 철회
          - 언제든지 동의를 철회할 수 있으며, 동의를 철회한 경우 서비스 이용에 제한이 있을 수 있습니다. 

          7. 사용자의 권리
          - 사용자는 언제든지 개인정보를 조회, 수정 또는 삭제할 수 있습니다.

          8. 개인정보 보호 담당자
          - 개인정보 보호 관련 문의는 아래 연락처로 하시면 됩니다:
            - 이메일: [담당자 이메일]''',
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('닫기'),
                  ),
                ],
              ),
            );
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

    if (!_agreedToPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('개인정보 수집 및 이용에 동의해야 회원가입이 가능합니다.')),
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
      if (e is DioException) {
        print('오류 상태 코드: ${e.response?.statusCode}');
        print('응답 데이터: ${e.response?.data}');

        if (e.response?.statusCode == 409) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('이미 존재하는 이메일입니다.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('오류 발생: ${e.message}')),
          );
        }
      } else {
        print('예상치 못한 오류: $e');
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
    backgroundColor: const Color(0xFFB8E0FF),
    appBar: AppBar(
      backgroundColor: const Color(0xFFB8E0FF),
      elevation: 0,
      centerTitle: true,
      title: Text(
        '회원가입',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.indigo[900],
        ),
      ),
    ),
    resizeToAvoidBottomInset: true,
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
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
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : sendVerificationCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB8E0FF),
                    foregroundColor: Colors.indigo[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text('이메일 확인', style: TextStyle(fontSize: 16)),
                ),
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
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB8E0FF),
                    foregroundColor: Colors.indigo[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text('인증번호 확인', style: TextStyle(fontSize: 16)),
                ),
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
              Row(
                children: [
                  Checkbox(
                    value: _agreedToPrivacy,
                    onChanged: (value) {
                      setState(() {
                        _agreedToPrivacy = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.black),
                        children: [
                          TextSpan(text: '개인정보 수집 내용에 동의하십니까? '),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: GestureDetector(
                              onTap: showPrivacyPolicyDialog,
                              child: Text(
                                '(자세히 보기)',
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _isLoading
                  ? CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: handleSignup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isEmailVerified
                              ? const Color(0xFFB8E0FF)
                              : Colors.grey.shade300,
                          foregroundColor: Colors.indigo[900],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text('회원가입', style: TextStyle(fontSize: 16)),
                      ),
                    ),
            ],
          ),
        ),
      ),
    ),
  );
}
}