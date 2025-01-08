import 'package:flutter/material.dart';

class MakeQuiz extends StatefulWidget {
  @override
  _MakeQuizState createState() => _MakeQuizState();
}

class _MakeQuizState extends State<MakeQuiz> {
  int _questionNumber = 1; // 현재 문제 번호
  String _question = ''; // 문제 텍스트
  String _answer = ''; // 답
  String _questionType = '객관식'; // 문제 유형 (기본값은 객관식)
  List<Map<String, dynamic>> _questionsList = []; // 만든 문제들을 저장

  // 객관식 문제에 대한 선택지
  List<String> _multipleChoiceOptions = ['', '', '', ''];

  // 문제 유형을 선택하는 버튼
  void _toggleQuestionType(String type) {
    setState(() {
      _questionType = type;
    });
  }

  // 질문을 저장하고 넘어가기
  void _saveQuestion() {
    Map<String, dynamic> questionData = {
      'question': _question,
      'answer': _answer,
      'questionType': _questionType,
      'options': _questionType == '객관식' ? _multipleChoiceOptions : null,
    };

    setState(() {
      _questionsList.add(questionData);
      _question = '';
      _answer = '';
      _multipleChoiceOptions = ['', '', '', ''];
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('문제 저장 완료'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('퀴즈 만들기'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              // 완료 버튼 클릭 시
              _saveQuestion();
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
            // 문제 번호 표시
            Text(
              '문제 $_questionNumber',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            // 문제 텍스트 입력
            TextField(
              onChanged: (text) {
                setState(() {
                  _question = text;
                });
              },
              decoration: InputDecoration(
                labelText: '문제 입력',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            SizedBox(height: 16),
            // 문제 유형 선택 버튼
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _toggleQuestionType('객관식'),
                  child: Text('객관식'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _questionType == '객관식'
                        ? Colors.blue
                        : Colors.grey,
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _toggleQuestionType('OX'),
                  child: Text('OX문제'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _questionType == 'OX' ? Colors.blue : Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // 답 입력 필드
            TextField(
              onChanged: (text) {
                setState(() {
                  _answer = text;
                });
              },
              decoration: InputDecoration(
                labelText: '정답 입력',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            // 객관식일 때, 객관식 옵션 입력 필드
            if (_questionType == '객관식') ...[
              for (int i = 0; i < 4; i++)
                TextField(
                  onChanged: (text) {
                    setState(() {
                      _multipleChoiceOptions[i] = text;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: '선택지 ${i + 1}',
                    border: OutlineInputBorder(),
                  ),
                ),
            ],
            SizedBox(height: 16),
            // 만든 문제들 리스트 표시 버튼
            ElevatedButton(
              onPressed: () {
                // 문제 리스트 화면으로 이동
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('문제 목록'),
                    content: SingleChildScrollView(
                      child: Column(
                        children: _questionsList.map((question) {
                          return ListTile(
                            title: Text(question['question']),
                            subtitle: Text('유형: ${question['questionType']}'),
                          );
                        }).toList(),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('닫기'),
                      ),
                    ],
                  ),
                );
              },
              child: Text('문제 목록 보기'),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 이전 문제로 가기 버튼
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
                // 다음 문제로 가기 버튼
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () {
                    setState(() {
                      _questionNumber++;
                    });
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
