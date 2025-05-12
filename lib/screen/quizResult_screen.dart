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
            '퀴즈 결과',
            style: TextStyle(color: Colors.indigo[900], fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(
          child: Text(
            "퀴즈 데이터를 불러올 수 없습니다.",
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ),
      );
    }

    var currentQuestion = _quizList[_currentQuestionIndex];
    String questionText = currentQuestion['question'] ?? '';
    List<dynamic> options = currentQuestion['options'] ?? [];
    String correctAnswer = currentQuestion['answer'].toString();
    String userAnswer = _userAnswers[_currentQuestionIndex]?.toString() ?? '미응답';

    bool isMultipleChoice = currentQuestion['isMultipleChoice'] ?? false;

    if (isMultipleChoice) {
      try {
        correctAnswer = (int.parse(correctAnswer)).toString();
      } catch (e) {
        debugPrint("Error parsing correctAnswer: $correctAnswer");
      }
    }

    bool isCorrect = userAnswer.trim() == correctAnswer.trim();

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
          '퀴즈 결과',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.indigo[900],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
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
              mainAxisSize: MainAxisSize.min,
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
                SizedBox(height: 20),
                if (isMultipleChoice)
                  Column(
                    children: options.asMap().entries.map((entry) {
                      int idx = entry.key;
                      String option = entry.value;
                      String optionIndex = (idx + 1).toString();

                      bool isUserSelected = (optionIndex == userAnswer);
                      bool isCorrectOption = (optionIndex == correctAnswer);

                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: isUserSelected
                              ? (isCorrect ? Colors.green[200] : Colors.red[200])
                              : (isCorrectOption ? Colors.green[100] : Colors.white),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text('$optionIndex. $option'),
                        ),
                      );
                    }).toList(),
                  )
                else
                  Center(
                    child: Text(
                      '당신의 답변: $userAnswer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isCorrect ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                SizedBox(height: 24),
                Center(
                  child: Text(
                    isCorrect ? '✅ 정답입니다!' : '❌ 오답입니다!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
                  ),
                ),
                SizedBox(height: 24), // <- 여기를 Column 안으로 옮김
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentQuestionIndex > 0)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo[400],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _currentQuestionIndex--;
                          });
                        },
                        child: Text('이전'),
                      ),
                    Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo[400],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (_currentQuestionIndex < _quizList.length - 1) {
                          setState(() {
                            _currentQuestionIndex++;
                          });
                        } else {
                          // 마지막 문제에서 "확인" 버튼을 눌렀을 때 동작
                          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                        }
                      },
                      child: Text(
                        _currentQuestionIndex < _quizList.length - 1 ? '다음' : '확인',
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