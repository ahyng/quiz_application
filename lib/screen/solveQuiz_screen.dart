import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SolveQuiz extends StatefulWidget {
  @override
  _SolveQuizState createState() => _SolveQuizState();
}

class _SolveQuizState extends State<SolveQuiz> {
  List<dynamic> _quizList = [];
  int _currentQuestionIndex = 0;
  List<dynamic> _userAnswers = [];
  int _score = 0;
  String? code;
  String? _resultMessage;
  String _userName = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        code = args['code'];
        _quizList = args['quizList'] ?? [];
        _userAnswers = List.filled(_quizList.length, null);
      });
    }
  }

  Future<void> _sendAnswers() async {
    if (_userName.isEmpty) {
      _showNameDialog();
      return;
    }

    try {
      var url = Uri.parse('${dotenv.env['ADDRESS']}/evaluate'); // 서버 URL로 변경
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'code': code,
          'userAnswers': _userAnswers.map((answer) {
            if (answer != null) {
              return (int.parse(answer) + 1).toString(); // 0-based index를 1-based로 변환
            }
            return null;
          }).toList(),
          'name': _userName,
        }),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> result = jsonDecode(response.body);
        setState(() {
          _score = result['score'];
          _resultMessage = result['result'];
        });
        _showResultDialog();
      } else {
        _showSnackBar('답안 전송에 실패했습니다.');
      }
    } catch (e) {
      _showSnackBar('오류 발생: $e');
    }
  }

  void _showNameDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('이름 입력'),
        content: TextField(
          onChanged: (value) {
            _userName = value;
          },
          decoration: InputDecoration(hintText: '이름을 입력하세요'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_userName.isNotEmpty) {
                Navigator.of(context).pop();
                _sendAnswers();
              }
            },
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('결과'),
        content: Text('총 ${_quizList.length} 문제 중 $_score 문제를 맞히셨습니다.\n$_resultMessage'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _currentQuestionIndex = 0;
                _userAnswers = List.filled(_quizList.length, null);
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (_quizList.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('퀴즈 풀기')),
        body: Center(child: Text("퀴즈가 없습니다.")),
      );
    }

    var currentQuestion = _quizList[_currentQuestionIndex];
    String questionText = currentQuestion['question'] ?? '';
    List<dynamic> options = currentQuestion['options'] ?? [];
    bool isMultipleChoice = currentQuestion['isMultipleChoice'] ?? false;

    return Scaffold(
      appBar: AppBar(title: Text('퀴즈 풀기')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '문제 ${_currentQuestionIndex + 1}/${_quizList.length}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              questionText,
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            if (isMultipleChoice == false)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _userAnswers[_currentQuestionIndex] = 'O';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _userAnswers[_currentQuestionIndex] == 'O' ? const Color.fromRGBO(114, 247, 252, 1) : const Color.fromARGB(255, 0, 213, 213),
                    ),
                    child: Text('O'),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _userAnswers[_currentQuestionIndex] = 'X';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _userAnswers[_currentQuestionIndex] == 'X' ? const Color.fromARGB(114, 247, 252, 1) : const Color.fromARGB(255, 74, 206, 210),
                    ),
                    child: Text('X'),
                  ),
                ],
              )
            else
              Column(
                children: options.asMap().entries.map((entry) {
                  int idx = entry.key;
                  String option = entry.value;
                  return RadioListTile<String>(
                    title: Text(option),
                    value: idx.toString(),
                    groupValue: _userAnswers[_currentQuestionIndex],
                    onChanged: (value) {
                      setState(() {
                        _userAnswers[_currentQuestionIndex] = value;
                      });
                    },
                  );
                }).toList(),
              ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentQuestionIndex > 0)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentQuestionIndex--;
                      });
                    },
                    child: Text('이전'),
                  ),
                if (_currentQuestionIndex < _quizList.length - 1)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentQuestionIndex++;
                      });
                    },
                    child: Text('다음'),
                  ),
                if (_currentQuestionIndex == _quizList.length - 1)
                  ElevatedButton(
                    onPressed: _sendAnswers,
                    child: Text('제출'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
