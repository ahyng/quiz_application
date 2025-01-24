import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SolveQuiz extends StatefulWidget {
  @override
  _SolveQuizState createState() => _SolveQuizState();
}

class _SolveQuizState extends State<SolveQuiz> {
  List<dynamic> _quizList = [];
  int _currentQuestionIndex = 0;
  List<String> _userAnswers = [];
  int _score = 0;
  bool _isLoading = true;
  String? code;

  @override
  void initState() {
    super.initState();
    _fetchQuizList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 전달된 코드 가져오기
      code = ModalRoute.of(context)!.settings.arguments as String?;
      if (code != null) {
        _fetchQuizList();
      } else {
        _showSnackBar('퀴즈 코드를 전달받지 못했습니다.');
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _fetchQuizList() async {
    if (code == null) return; // 코드가 없으면 실행 안 함

    try {
      var url = Uri.parse(''); // 퀴즈 목록 url
      var response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _quizList = jsonDecode(response.body);
          print(_quizList);
          _userAnswers = List.filled(_quizList.length, '');
          _isLoading = false;
        });
      } else {
        print('퀴즈 목록 가져오기 실패: ${response.statusCode}');
        _showSnackBar('퀴즈 목록을 가져오는데 실패했습니다.');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('오류 발생: $e');
      _showSnackBar('오류가 발생했습니다: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendAnswers() async {
    try {
      var url = Uri.parse(''); // 답안 전송 url
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userAnswers': _userAnswers,
        }),
      );

      if (response.statusCode == 200) {
        print('답안 전송 성공: ${response.body}');
        Map<String, dynamic> result = jsonDecode(response.body);
        setState(() {
          _score = result['score'];
        });
        _showResultDialog();
      } else {
        print('답안 전송 실패: ${response.statusCode}');
        _showSnackBar('답안 전송에 실패했습니다.');
      }
    } catch (e) {
      print('답안 전송 오류: $e');
      _showSnackBar('오류가 발생했습니다: $e');
    }
  }

  void _checkAnswers() {
    _sendAnswers();
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('결과'),
        content: Text('총 ${_quizList.length} 문제 중 $_score 문제를 맞히셨습니다.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _currentQuestionIndex = 0;
                _userAnswers = List.filled(_quizList.length, '');
                _score = 0;
              });
            },
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('퀴즈 풀기')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_quizList.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('퀴즈 풀기')),
        body: Center(child: Text("퀴즈가 없습니다.")),
      );
    }

    var currentQuestion = _quizList[_currentQuestionIndex];
    bool isMultipleChoice = currentQuestion['questionType'] == '객관식';
    bool isLastQuestion = _currentQuestionIndex == _quizList.length - 1;

    return Scaffold(
      appBar: AppBar(title: Text('퀴즈 풀기')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '문제 ${_currentQuestionIndex + 1}/${_quizList.length}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              currentQuestion['question'],
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            if (isMultipleChoice) ...[
              for (int i = 0; i < currentQuestion['options'].length; i++)
                RadioListTile(
                  title: Text(currentQuestion['options'][i]),
                  value: currentQuestion['options'][i],
                  groupValue: _userAnswers[_currentQuestionIndex],
                  onChanged: (value) {
                    setState(() {
                      _userAnswers[_currentQuestionIndex] = value!;
                    });
                  },
                  activeColor: Color(0xFFB8E0FF),
                ),
            ] else ...[
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _userAnswers[_currentQuestionIndex] = 'O';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _userAnswers[_currentQuestionIndex] == 'O'
                          ? Color(0xFFB8E0FF)
                          : Colors.grey[300],
                      foregroundColor: Colors.black,
                    ),
                    child: Text('O'),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _userAnswers[_currentQuestionIndex] = 'X';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _userAnswers[_currentQuestionIndex] == 'X'
                          ? Color(0xFFB8E0FF)
                          : Colors.grey[300],
                      foregroundColor: Colors.black,
                    ),
                    child: Text('X'),
                  ),
                ],
              ),
            ],
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: _currentQuestionIndex > 0
                      ? () {
                          setState(() {
                            _currentQuestionIndex--;
                          });
                        }
                      : null,
                ),
                if (isLastQuestion)
                  ElevatedButton(
                    onPressed: _checkAnswers,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFB8E0FF),
                      foregroundColor: Colors.black,
                    ),
                    child: Text('채점하기'),
                  )
                else
                  IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: _currentQuestionIndex < _quizList.length - 1
                        ? () {
                            setState(() {
                              _currentQuestionIndex++;
                            });
                          }
                        : null,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}