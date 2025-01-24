import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MakeQuiz extends StatefulWidget {
  @override
  _MakeQuizState createState() => _MakeQuizState();
}

class _MakeQuizState extends State<MakeQuiz> {
  int _questionNumber = 1;
  String _questionType = '객관식';
  String _code = '';
  List<Map<String, dynamic>> _quizData = [
    {
      'question': '',
      'answer': '',
      'questionType': '객관식',
      'options': ['', '', '', ''],
    }
  ];

  void _saveCurrentQuestion() {
    if (_questionNumber - 1 < _quizData.length) {
      _quizData[_questionNumber - 1] = {
        'number':_questionNumber,
        'question': _quizData[_questionNumber - 1]['question'] ?? '',
        'answer': _quizData[_questionNumber - 1]['answer'] ?? '',
        'questionType': _questionType,
        'code':_code,
        'options': _questionType == '객관식'
            ? List<String>.from(_quizData[_questionNumber - 1]['options'] ?? ['', '', '', ''])
            : null,
      };
    }
  }

  void _loadQuestion(int questionNumber) {
    setState(() {
      if (questionNumber - 1 < _quizData.length) {
        _questionType = _quizData[questionNumber - 1]['questionType'];
      } else {
        _quizData.add({
          'number': 1,
          'question': '',
          'answer': '',
          'questionType': '객관식',
          'options': ['', '', '', ''],
          'code':'',
        });
      }
    });
  }

  Future<void> _saveAndSendQuestion() async {
    _saveCurrentQuestion();

    try {
      var url = Uri.parse(''); // 서버 url
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(_quizData[_questionNumber - 1]),
      );

      if (response.statusCode == 200) {
        print('퀴즈 저장 성공: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('문제 저장 완료'),
        ));

        setState(() {
          _questionNumber++;
          _loadQuestion(_questionNumber);
        });
      } else {
        print('퀴즈 저장 실패: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('문제 저장 실패'),
        ));
      }
    } catch (e) {
      print('오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('오류 발생: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('퀴즈 만들기'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              await _saveAndSendQuestion();
              Navigator.pushNamed(context, '/manageQuiz');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '문제 $_questionNumber',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              onChanged: (text) {
                setState(() {
                  _quizData[_questionNumber - 1]['question'] = text;
                });
              },
              decoration: InputDecoration(
                labelText: '문제 입력',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => _questionType = '객관식'),
                  child: Text('객관식'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _questionType == '객관식' ? const Color.fromARGB(255, 109, 187, 250) : Colors.grey,
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => setState(() => _questionType = 'OX'),
                  child: Text('OX문제'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _questionType == 'OX' ? const Color.fromARGB(255, 123, 196, 255) : Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              onChanged: (text) {
                setState(() {
                  _quizData[_questionNumber - 1]['answer'] = text;
                });
              },
              decoration: InputDecoration(
                labelText: '정답 입력',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            if (_questionType == '객관식') ...[
              for (int i = 0; i < 4; i++)
                TextField(
                  onChanged: (text) {
                    setState(() {
                      _quizData[_questionNumber - 1]['options'][i] = text;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: '선택지 ${i + 1}',
                    border: OutlineInputBorder(),
                  ),
                ),
            ],
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: _questionNumber > 1
                      ? () {
                          setState(() {
                            _questionNumber--;
                          });
                        }
                      : null,
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () async {
                    await _saveAndSendQuestion();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
