import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:characters/characters.dart';


class ManageQuiz extends StatefulWidget {
  @override
  _ManageQuizScreenState createState() => _ManageQuizScreenState();
}

class _ManageQuizScreenState extends State<ManageQuiz> {
  List<Map<String, dynamic>> quizList = [];
  final FlutterSecureStorage storage = FlutterSecureStorage();
  String searchQuery = '';
  String normalize(String text) {
    return text.replaceAll(RegExp(r'\s+'), '');
  }


  @override
  void initState() {
    super.initState();
    fetchQuizzes();
  }

  Future<void> fetchQuizzes() async {
    try {
      String? accessToken = await storage.read(key: 'access_token');
      String? refreshToken = await storage.read(key: 'refresh_token');

      if (accessToken == null || refreshToken == null) {
        setState(() => quizList = []);
        print('로그인이 필요합니다.');
        return;
      }

      var url = Uri.parse('${dotenv.env['ADDRESS']}/main');
      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accessToken': 'Bearer $accessToken',
          'refreshToken': 'Bearer $refreshToken',
        },
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          List<Map<String, dynamic>> newQuizList = responseData['quiz'] != null
              ? List<Map<String, dynamic>>.from(responseData['quiz'])
              : [];

          if (mounted) {
            setState(() => quizList = newQuizList);
          }

          if (quizList.isEmpty) print('퀴즈 목록 없음');
        } else {
          print('서버에서 데이터를 가져오지 못했습니다.');
        }
      } else {
        print('퀴즈 목록을 불러오는 데 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      print('서버 연결 실패: ${e.toString()}');
    }
  }

  void deleteQuiz(int index) async {
    String code = quizList[index]['code'];

    try {
      var url = Uri.parse('${dotenv.env['ADDRESS']}/delete-quiz');
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': code}),
      );

      if (response.statusCode == 200) {
        setState(() {
          quizList.removeAt(index);
        });
        Navigator.of(context).pop();
      } else {
        print('퀴즈 삭제 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('서버 오류: $e');
    }
  }

  void editQuiz(int index) async {
    String code = quizList[index]['code'];

    try {
      var fetchUrl = Uri.parse('${dotenv.env['ADDRESS']}/find-quiz');
      var fetchResponse = await http.post(
        fetchUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': code}),
      );

      if (fetchResponse.statusCode == 200) {
        var quizData = jsonDecode(fetchResponse.body);

        Navigator.pushNamed(
          context,
          '/edit_quiz',
          arguments: {
            'title': quizData['title'],
            'code': quizData['code'],
            'quiz': quizData['quiz'] ?? [],
          },
        ).then((updatedQuiz) async {
          if (updatedQuiz != null) {
            try {
              var updateUrl = Uri.parse('${dotenv.env['ADDRESS']}/update-quiz');
              var updateResponse = await http.post(
                updateUrl,
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({'code': code, ...updatedQuiz as Map<String, dynamic>}),
              );

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

  Future<void> fetchRanking(String code) async {
    try {
      var url = Uri.parse('${dotenv.env['ADDRESS']}/ranking');
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': code}),
      );

      if (response.statusCode == 200) {
        var rankingData = jsonDecode(response.body);

        if (rankingData.containsKey('ranking')) {
          Navigator.pushNamed(
            context,
            '/student_score',
            arguments: {'code': code, 'ranking': rankingData['ranking']},
          );
        } else {
          print('랭킹 데이터를 가져오지 못했습니다.');
        }
      } else {
        print('랭킹 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('서버 연결 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB8E0FF),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.home, color: Colors.indigo[900]),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          },
        ),
        backgroundColor: const Color(0xFFB8E0FF),
        elevation: 0,
        title: Text(
          '퀴즈 관리',
          style: TextStyle(color: Colors.indigo[900], fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.indigo[900]),
            onPressed: () {
              Navigator.pushNamed(context, '/mypage');
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: '퀴즈 제목으로 검색',
                prefixIcon: Icon(Icons.search),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                List<Map<String, dynamic>> filteredQuizList = quizList.where((quiz) {
                  final titleRaw = quiz['title']?.toString() ?? '';
                  final title = normalize(titleRaw);
                  final query = normalize(searchQuery);
                  return query.isEmpty || title.contains(query);
                }).toList();


                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredQuizList.length,
                  itemBuilder: (context, index) {
                    var quiz = filteredQuizList[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          quiz['title'] ?? '퀴즈 ${index + 1}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('코드: ${quiz['code']}'),
                        trailing: Wrap(
                          spacing: 4,
                          children: <Widget>[
                            IconButton(
                              tooltip: '코드 복사',
                              icon: Icon(Icons.content_copy),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: quiz['code']));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('퀴즈 코드가 복사되었습니다!')),
                                );
                              },
                            ),
                            IconButton(
                              tooltip: '퀴즈 수정',
                              icon: Icon(Icons.edit),
                              onPressed: () => editQuiz(index),
                            ),
                            IconButton(
                              tooltip: '랭킹 보기',
                              icon: FaIcon(FontAwesomeIcons.trophy),
                              onPressed: () => fetchRanking(quiz['code']),
                            ),
                            IconButton(
                              tooltip: '퀴즈 삭제',
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
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newQuiz = await Navigator.pushNamed(context, '/make_quiz');
          if (newQuiz != null) {
            setState(() {
              quizList.add(newQuiz as Map<String, dynamic>);
            });
          }
        },
        backgroundColor: Colors.indigo[900],
        child: Icon(Icons.add, color: Colors.white),
        tooltip: '새 퀴즈 만들기',
      ),
    );
  }
}
