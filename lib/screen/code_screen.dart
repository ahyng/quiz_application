import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CodeScreen extends StatefulWidget {
  @override
  _CodeScreenState createState() => _CodeScreenState();
}

class _CodeScreenState extends State<CodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleCode() async {
    String code = _codeController.text.trim();

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('코드를 입력하세요.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse(''); // 서버의 API URL
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': code}),  // 서버에 코드 전송
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['success'] == true && responseData['quiz'] != null) {
          // 퀴즈 데이터를 함께 전달
          Navigator.pushNamed(
            context,
            '/solve-quiz',
            arguments: {
              'code': code,
              'quizList': responseData['quiz'],  // 퀴즈 데이터 전달
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('해당 코드의 퀴즈를 찾을 수 없습니다.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('서버 오류: ${response.statusCode}')),
        );
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
      appBar: AppBar(title: Text('코드 입력 화면')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Code',
                hintText: 'Enter Quiz Code',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
              keyboardType: TextInputType.text,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _handleCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB8E0FF),
                foregroundColor: const Color(0xFF212121),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: Size(200, 50),
              ),
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('확인', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
