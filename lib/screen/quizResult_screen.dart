import 'package:flutter/material.dart';

class QuizResult extends StatefulWidget {
  @override
  _QuizResultState createState() => _QuizResultState();
}

class _QuizResultState extends State<QuizResult> {
  List<dynamic> _quizList = [];
  List<dynamic> _userAnswers = [];
  int _score = 0;
  int _currentQuestionIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        _quizList = args['quizList'] ?? [];
        _userAnswers = args['userAnswers'] ?? [];
        _score = args['score'] ?? 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_quizList.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('퀴즈 결과')),
        body: Center(child: Text("퀴즈 데이터를 불러올 수 없습니다.")),
      );
    }

    var currentQuestion = _quizList[_currentQuestionIndex];
    String questionText = currentQuestion['question'] ?? '';
    List<dynamic> options = currentQuestion['options'] ?? [];
    String correctAnswer = currentQuestion['answer'].toString(); // 정답
    String userAnswer = _userAnswers[_currentQuestionIndex]?.toString() ?? '미응답';

    bool isMultipleChoice = currentQuestion['isMultipleChoice'] ?? false;

    // 객관식 문제일 경우 정답 값을 변환
    if (isMultipleChoice) {
      try {
        correctAnswer = (int.parse(correctAnswer)).toString(); // 1-based index로 변환
      } catch (e) {
        debugPrint("Error parsing correctAnswer: $correctAnswer");
      }
    }

    bool isCorrect = userAnswer.trim() == correctAnswer.trim(); // 문자열 비교 시 공백 제거

    return Scaffold(
      appBar: AppBar(title: Text('퀴즈 결과')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '결과 ${_currentQuestionIndex + 1}/${_quizList.length}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              questionText,
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            if (isMultipleChoice)
              Column(
                children: options.asMap().entries.map((entry) {
                  int idx = entry.key;
                  String option = entry.value;
                  String optionIndex = (idx + 1).toString(); // 1-based index

                  bool isUserSelected = (optionIndex == userAnswer);
                  bool isCorrectOption = (optionIndex == correctAnswer);

                  return ListTile(
                    title: Text('$optionIndex. $option'),
                    tileColor: isUserSelected
                        ? (isCorrect ? Colors.green[200] : Colors.red[200])
                        : (isCorrectOption ? Colors.green[100] : null),
                  );
                }).toList(),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '당신의 답변: $userAnswer',
                    style: TextStyle(fontSize: 18, color: isCorrect ? Colors.green : Colors.red),
                  ),
                ],
              ),
            SizedBox(height: 20),
            Text(
              isCorrect ? '✅ 정답입니다!' : '❌ 오답입니다!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isCorrect ? Colors.green : Colors.red),
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
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/');
                    },
                    child: Text('홈으로'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
