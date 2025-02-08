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
    fetchQuizzes();
  }

  Future<void> fetchQuizzes() async {
    try {
      var url = Uri.parse(''); // 백엔드 URL
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "": "" // 예제 데이터 (필요 없으면 빈 `{}` 보내도 됨)
        }),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          setState(() {
            quizList = responseData['quiz'] != null
                ? List<Map<String, dynamic>>.from(responseData['quiz'])
                : [];
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

  void deleteQuiz(int index) async {
    String code = quizList[index]['code']; // 삭제할 퀴즈 코드 가져오기

    try {
      var url = Uri.parse(''); // 백엔드 URL 확인
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': code}), // Body에 코드 포함
      );

      if (response.statusCode == 200) {
        setState(() {
          quizList.removeAt(index);
        });
        Navigator.of(context).pop();
      } else {
        print('퀴즈 삭제 실패: ${response.statusCode}');
        print('서버 응답: ${response.body}');
      }
    } catch (e) {
      print('서버 오류: $e');
    }
  }

void editQuiz(int index) async {
  String code = quizList[index]['code']; // 수정할 퀴즈 코드 가져오기

  try {
    var fetchUrl = Uri.parse('');
    var fetchResponse = await http.post(
      fetchUrl,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'code': code}), //수정할 퀴즈 코드 전송
    );

     print('퀴즈 데이터 응답: ${fetchResponse.body}');

    if (fetchResponse.statusCode == 200) {
      var quiz = jsonDecode(fetchResponse.body); // 기존 퀴즈 데이터 가져오기

      Navigator.pushNamed(
        context,
        '/edit_quiz',
        arguments: {quiz,} // 기존 퀴즈 데이터 전달
      ).then((updatedQuiz) async {
        if (updatedQuiz != null) {
          try {
            var updateUrl = Uri.parse('');
            var updateResponse = await http.post(
              updateUrl,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'code': code, ...updatedQuiz as Map<String, dynamic>}), // ✅ POST로 전송
            );

            print('퀴즈 수정 응답: ${updateResponse.body}');

            if (updateResponse.statusCode == 200) {
              setState(() {
                quizList[index] = updatedQuiz as Map<String, dynamic>;
              });
            } else {
              print('퀴즈 수정 실패: ${updateResponse.statusCode}');
            }
          } catch (e) {
            print('서버 오류: $e');
          }
        }
      });
    } else {
      print('퀴즈 데이터 불러오기 실패: ${fetchResponse.statusCode}');
    }
  } catch (e) {
    print('서버 오류: $e');
  }
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
                var quiz = quizList[index];
                return ListTile(
                  title: Text(quiz['title'] ?? '퀴즈 ${index + 1}'),
                  subtitle: Text('코드: ${quiz['code']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => editQuiz(index),
                      ),
                      IconButton(
                        icon: Icon(Icons.visibility),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/student_score',
                            arguments: quiz,
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("퀴즈 삭제"),
                                content: Text("정말 이 퀴즈를 삭제하시겠습니까?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: Text("취소"),
                                  ),
                                  TextButton(
                                    onPressed: () => deleteQuiz(index),
                                    child: Text("삭제", style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              );
                            },
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
                onPressed: () async {
                  final newQuiz = await Navigator.pushNamed(context, '/make_quiz');
                  if (newQuiz != null) {
                    setState(() {
                      quizList.add(newQuiz as Map<String, dynamic>); // 바로 목록에 추가
                    });
                  }
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

