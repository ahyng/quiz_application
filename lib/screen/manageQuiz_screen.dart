import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ManageQuiz extends StatefulWidget {
  @override
  _ManageQuizScreenState createState() => _ManageQuizScreenState();
}

class _ManageQuizScreenState extends State<ManageQuiz> {
  List<Map<String, dynamic>> quizList = [];

  @override
  void initState() {
    super.initState();
    fetchQuizzes(); // 백엔드에서 퀴즈 리스트 가져오기
  }

  // 백엔드에서 퀴즈 리스트 가져오는 함수
  Future<void> fetchQuizzes() async {
    try {
      var url = Uri.parse(''); // 백엔드 URL
      var response = await http.post(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          setState(() {
            quizList = List<Map<String, dynamic>>.from(responseData['quiz']);
          });
        } else {
          print('서버에서 데이터를 가져오지 못했습니다.');
        }
      } else {
        print('퀴즈 목록을 불러오는 데 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      print('서버 연결 실패: $e');
    }
  }

  void addQuiz(Map<String, dynamic> quiz) {
    setState(() {
      quizList.add(quiz);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('퀴즈 관리')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: quizList.length,
              itemBuilder: (context, index) {
                var questions = quizList[index]['questions'] ?? [];
                return ListTile(
                  title: Text('퀴즈 ${index + 1}'),
                  subtitle: Text('문제 개수: ${questions.length}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/make_quiz',
                            arguments: quizList[index],
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.visibility),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/quiz_results',
                            arguments: quizList[index],
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/make_quiz').then((quiz) {
                    if (quiz != null) {
                      addQuiz(quiz as Map<String, dynamic>);
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB8E0FF),
                  foregroundColor: const Color(0xFF212121),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: Size(60, 60),
                ),
                child: Text('+', style: TextStyle(fontSize: 20)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
