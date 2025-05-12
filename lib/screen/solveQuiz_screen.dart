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
      code = args['code'];
      _quizList = args['quizList'] ?? [];
      
      /// `_userAnswers`가 비어 있거나 길이가 다를 때만 초기화
      if (_userAnswers.isEmpty || _userAnswers.length != _quizList.length) {
        _userAnswers = List.filled(_quizList.length, null);
      }
    }
  }

  Future<void> _sendAnswers() async {
    if (_userName.isEmpty) {
      _showNameDialog();
      return;
    }

    try {
      var url = Uri.parse('${dotenv.env['ADDRESS']}/evaluate');
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'code': code,
          'userAnswers': _userAnswers.map((answer) {
            if (answer != null) {
              if (answer == 'O' || answer == 'X') {
                return answer; // OX 문제는 그대로 전송
              } else {
                return (int.parse(answer)).toString(); // 객관식 문제는 1부터 시작하도록 저장
              }
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
        content: Text('총 ${_quizList.length} 문제 중 $_score 문제를 맞히셨습니다.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(
                context, 
                '/quizresult',
                arguments: {
                  'quizList': _quizList,
                  'userAnswers': _userAnswers,
                  'score': _score,
                  }
                );
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
          centerTitle: true,
          title: Text(
            '퀴즈 풀기',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.indigo[900],
            ),
          ),
        ),
        body: Center(
          child: Text(
            "퀴즈가 없습니다.",
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
        ),
      );
    }

    var currentQuestion = _quizList[_currentQuestionIndex];
    String questionText = currentQuestion['question'] ?? '';
    List<dynamic> options = currentQuestion['options'] ?? [];
    bool isMultipleChoice = currentQuestion['isMultipleChoice'] ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFB8E0FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB8E0FF),
        elevation: 0,
        centerTitle: true,
        title: Text(
          '퀴즈 풀기',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.indigo[900],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '문제 ${_currentQuestionIndex + 1} / ${_quizList.length}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  questionText,
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 24),

                // OX 버튼
                if (!isMultipleChoice)
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
                          backgroundColor: _userAnswers[_currentQuestionIndex] == 'O'
                              ? const Color(0xFFB8E0FF)
                              : Colors.white,
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
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
                          backgroundColor: _userAnswers[_currentQuestionIndex] == 'X'
                              ? const Color(0xFFB8E0FF)
                              : Colors.white,
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
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
                        value: (idx + 1).toString(),
                        groupValue: _userAnswers[_currentQuestionIndex],
                        activeColor: Colors.indigo[400],
                        onChanged: (value) {
                          setState(() {
                            _userAnswers[_currentQuestionIndex] = value!;
                          });
                        },
                      );
                    }).toList(),
                  ),

                SizedBox(height: 24),

                // 이전/다음/제출 버튼
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB8E0FF),
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                        child: Text('이전', style: TextStyle(fontSize: 16)),
                      )
                    else
                      SizedBox(width: 100), // 이전 버튼 공간

                    ElevatedButton(
                      onPressed: () {
                        if (_currentQuestionIndex < _quizList.length - 1) {
                          setState(() {
                            _currentQuestionIndex++;
                          });
                        } else {
                          _sendAnswers();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentQuestionIndex < _quizList.length - 1
                            ? const Color(0xFFB8E0FF)
                            : Colors.indigo[900],
                        foregroundColor: _currentQuestionIndex < _quizList.length - 1
                            ? Colors.black87
                            : Colors.white, // ← 제출 버튼일 때 흰색 글자
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: Text(
                        _currentQuestionIndex < _quizList.length - 1 ? '다음' : '제출',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}