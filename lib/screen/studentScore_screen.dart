import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentScoreScreen extends StatefulWidget {
  @override
  _StudentScoreScreenState createState() => _StudentScoreScreenState();
}

class _StudentScoreScreenState extends State<StudentScoreScreen> {
  List<Map<String, dynamic>> _scores = [];
  String? _quizCode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, dynamic>? quiz =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (quiz != null) {
      setState(() {
        _quizCode = quiz['code'];
      });
      _fetchScores();
    }
  }

  Future<void> _fetchScores() async {
    try {
      var url = Uri.parse('');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> result = jsonDecode(response.body);
        setState(() {
          _scores = List<Map<String, dynamic>>.from(result);
          _scores.sort((a, b) => b['score'].compareTo(a['score']));
        });
      } else {
        throw Exception('랭킹 데이터를 불러오지 못했습니다.');
      }
    } catch (e) {
      print('오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('퀴즈 랭킹')),
      body: _scores.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _scores.length,
              itemBuilder: (context, index) {
                var student = _scores[index];
                return ListTile(
                  leading: Text('${index + 1}위'),
                  title: Text(student['name'] ?? '이름 없음'),
                  subtitle: Text('점수: ${student['score']}점'),
                );
              },
            ),
    );
  }
}

