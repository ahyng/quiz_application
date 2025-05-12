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
  List<dynamic> _quizList = [];
  List<dynamic> _userAnswers = [];
  int _score = 0;

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

        if (responseData['data'] != null && responseData['data'] is List) {
          final resultList = responseData['data'] as List<dynamic>;

          List<Widget> resultWidgets = [];

          for (int i = 0; i < resultList.length; i++) {
            var item = resultList[i];
            String user = item['userAnswer'] ?? '';
            String correct = item['correctAnswer'] ?? '';
            String question = item['question'] ?? '';
            List<dynamic> options = item['options'] ?? [];
            bool isCorrect = user == correct;

            resultWidgets.add(
              ListTile(
                title: Text('Q${i + 1}. $question'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('학생 답: $user'),
                    Text('정답: $correct'),
                    Text(
                      isCorrect ? '정답 ✅' : '오답 ❌',
                      style: TextStyle(
                        color: isCorrect ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
            resultWidgets.add(Divider());
          }

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => DraggableScrollableSheet(
              expand: false,
              builder: (context, scrollController) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  controller: scrollController,
                  children: [
                    Text(
                      '$studentName의 퀴즈 결과',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    ...resultWidgets,
                  ],
                ),
              ),
            ),
          );
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
      backgroundColor: const Color(0xFFB8E0FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB8E0FF),
        elevation: 0,
        centerTitle: true,
        title: Text(
          '퀴즈 랭킹',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.indigo[900],
          ),
        ),
      ),
      body: _scores.isEmpty
          ? Center(
              child: Text(
                '아직 문제를 푼 사람이 없습니다.',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            )
          : ListView.builder(
              itemCount: _scores.length,
              itemBuilder: (context, index) {
                var student = _scores[index];
                bool isPerfect = student['perfectScore'] ?? false;

                int rank;
                if (index == 0) {
                  rank = 1;
                } else {
                  int prevScore = _scores[index - 1]['score'];
                  int prevRank = _scores[index - 1]['rank'];
                  if (student['score'] == prevScore) {
                    rank = prevRank;
                  } else {
                    rank = index + 1;
                  }
                }

                _scores[index]['rank'] = rank;

                return Container(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: (rank == 1)
                        ? Colors.lightBlue.shade100
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    leading: Text(
                      '$rank위',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo[800],
                      ),
                    ),
                    title: Text(
                      student['name'] ?? '이름 없음',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text(
                      '점수: ${student['score']}점',
                      style: TextStyle(fontSize: 16),
                    ),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo[400],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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

