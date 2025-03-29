import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MyPageScreen extends StatefulWidget {
  @override
  _MyPageScreenState createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  String? userId;
  bool isLoggedIn = false;

  String? getUserIDFromToken(String token) {
    try {
      var decodedToken = JwtDecoder.decode(token);
      return decodedToken['userId'];  // 'userID'가 JWT에 포함된 경우
    } catch (e) {
      print('JWT 디코딩 오류: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _loaduserID();
  }

  Future<void> _loaduserID() async {
  String? accessToken = await storage.read(key: 'access_token');
  String? refreshToken = await storage.read(key: 'refresh_token');
  if (accessToken == null) {
    setState(() {
      isLoggedIn = false;
    });
    return;
  }

  // JWT에서 userID 추출
  String? extractedUserID = getUserIDFromToken(accessToken);
  if (extractedUserID != null) {
    setState(() {
      userId = extractedUserID;
      isLoggedIn = true;
    });
  } else {
    // 액세스 토큰이 유효하지 않으면 /auth-check API 호출
    try {
      var url = Uri.parse('${dotenv.env['ADDRESS']}/auth-check');
      var response = await http.post(
        url,
        headers: {
          'accessToken': 'Bearer $accessToken',
          'refreshToken': 'Bearer $refreshToken',
        },
      );

      if (response.statusCode == 200) {
        var userData = jsonDecode(response.body);
        setState(() {
          userId = userData['userId'];
          isLoggedIn = true;
        });
      } else {
        setState(() {
          isLoggedIn = false;
        });
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      print('오류 발생: $e');
      setState(() {
        isLoggedIn = false;
      });
    }
  }
}

  Future<void> _deleteAccount() async {
  // 계정 삭제 확인 다이얼로그
  bool? isConfirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('계정 삭제'),
        content: Text('정말로 계정을 삭제하시겠습니까?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);  // '아니오' 클릭 시 다이얼로그 닫기
            },
            child: Text('아니오'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);  // '예' 클릭 시 다이얼로그 닫기
            },
            child: Text('예'),
          ),
        ],
      );
    },
  );

  if (isConfirmed == true) {
    // 사용자가 '예'를 클릭하면 계정 삭제를 진행
    try {
      String? accessToken = await storage.read(key: 'access_token');
      String? refreshToken = await storage.read(key: 'refresh_token');

      if (accessToken == null) return;

      // 액세스토큰을 사용하여 인증 시도
      var url = Uri.parse('${dotenv.env['ADDRESS']}/delete-account');
      var response = await http.post(
        url,
        headers: {
          'accessToken': 'Bearer $accessToken',
          'refreshToken': 'Bearer $refreshToken',
        },
      );

      // 만약 액세스토큰이 만료되었으면 /auth-check을 호출
      if (response.statusCode == 401) {
        // 액세스토큰이 만료되었으므로 /auth-check 호출
        var authCheckUrl = Uri.parse('${dotenv.env['ADDRESS']}/auth-check');
        var authCheckResponse = await http.post(
          authCheckUrl,
          headers: {
            'accessToken': 'Bearer $accessToken',
            'refreshToken': 'Bearer $refreshToken',
          },
        );

        if (authCheckResponse.statusCode == 200) {
          // /auth-check에서 인증이 성공하면 계정 삭제를 계속 진행
          var deleteResponse = await http.post(
            url,
            headers: {
              'accessToken': 'Bearer $accessToken',
              'refreshToken': 'Bearer $refreshToken',
            },
          );

          if (deleteResponse.statusCode == 200) {
            print('계정이 삭제되었습니다.');
            await storage.delete(key: 'access_token');
            await storage.delete(key: 'refresh_token');
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          } else {
            print('계정 삭제 실패: ${deleteResponse.statusCode}');
          }
        } else {
          // 만약 /auth-check이 실패하면 로그인 화면으로 이동
          print('액세스토큰 만료, 로그인 다시 하세요');
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        }
      } else if (response.statusCode == 200) {
        // 액세스토큰이 유효하면 바로 계정 삭제 진행
        print('계정이 삭제되었습니다.');
        await storage.delete(key: 'access_token');
        await storage.delete(key: 'refresh_token');
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } else {
        print('계정 삭제 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('오류 발생: $e');
    }
  } else {
    print('계정 삭제 취소');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('마이페이지')),
      body: Center(
        child: isLoggedIn
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person, size: 100, color: const Color.fromARGB(255, 72, 139, 255)),
                  SizedBox(height: 10),
                  Text('$userId', style: TextStyle(fontSize: 20)),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/changepw');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 154, 209, 255),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      minimumSize: Size(200, 50),
                    ),
                    child: Text('비밀번호 변경', style: TextStyle(fontSize: 18)),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _deleteAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      minimumSize: Size(200, 50),
                    ),
                    child: Text('계정 삭제', style: TextStyle(fontSize: 18)),
                  ),
                ],
              )
            : Text('로그인이 필요합니다.', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}