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
      final url = Uri.parse(''); // 서버의 코드 API
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': code}),
      ); 
      if (response.statusCode == 200) {
        // 코드 입력 성공
        final responseData = jsonDecode(response.body);
        print(responseData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('확인 완료')),
        );
        // 문제 풀기 화면으로 이동
        Navigator.pushNamed(context, '/solve-quiz', arguments: code);
      } 
    }
    catch (e) {
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
                labelStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(width: 1, color: const Color.fromARGB(255, 0, 0, 0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(width: 1, color: const Color.fromARGB(255, 0, 0, 0)),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
              keyboardType: TextInputType.text,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _handleCode, // 버튼 클릭 시 _handleCode 호출
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB8E0FF),
                foregroundColor: const Color(0xFF212121),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: Size(200, 50),
              ),
              child: _isLoading
                  ? CircularProgressIndicator() // 로딩 중일 때 로딩 표시
                  : Text('확인', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
