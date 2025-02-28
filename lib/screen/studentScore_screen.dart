import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
    if (_quizCode == null) return;

    try {
      var url = Uri.parse('${dotenv.env['ADDRESS']}/ranking');
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': _quizCode}),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        print('서버 응답: ${response.body}');

        setState(() {
          _scores = List<Map<String, dynamic>>.from(responseData['ranking']);
          _scores.sort((a, b) => b['score'].compareTo(a['score']));
        });
      } else {
        throw Exception('랭킹 데이터를 불러오지 못했습니다.');
      }
    } catch (e) {
      print('오류 발생: $e');
    }
  }

  void _viewQuizResult(String studentName) async {
  if (_quizCode == null) return;
  
  try {
    var url = Uri.parse('${dotenv.env['ADDRESS']}/ranking-detail');
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'code': _quizCode, 'name': studentName}),
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      print('서버 응답 본문: ${response.body}');

      if (responseData['data'] != null && responseData['data'] is List) {
        Navigator.pushNamed(context, '/quizresult', arguments: responseData['data']);
      } else {
        throw Exception('잘못된 데이터 형식');
      }
    } else {
      throw Exception('퀴즈 결과를 불러오지 못했습니다.');
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
                bool isPerfect = student['perfectScore'] ?? false;
                int rank = index + 1;
                if (index > 0 && _scores[index]['score'] == _scores[index - 1]['score']) {
                  rank = index;
                }

                return Container(
                  decoration: BoxDecoration(
                    color: isPerfect ? Colors.lightBlue.shade100 : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: Text('$rank위'),
                    title: Text(
                      student['name'] ?? '이름 없음',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('점수: ${student['score']}점'),
                    trailing: ElevatedButton(
                      onPressed: () => _viewQuizResult(student['name']),
                      child: Text('결과 보기'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
