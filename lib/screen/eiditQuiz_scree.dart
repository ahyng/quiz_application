import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditQuiz extends StatefulWidget {
  @override
  _EditQuizScreenState createState() => _EditQuizScreenState();
}

class _EditQuizScreenState extends State<EditQuiz> {
  List<Map<String, dynamic>> quizList = [];
  int currentIndex = 0;
  int questionNumber = 1;
  TextEditingController questionController = TextEditingController();
  TextEditingController answerController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  List<TextEditingController> optionControllers =
      List.generate(5, (index) => TextEditingController());
  String questionType = '객관식';
  String code = '';

  @override
  @override
void initState() {
  super.initState();

  Future.delayed(Duration.zero, () {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    print('전달된 데이터: $args'); // 전달된 데이터 확인

    if (args != null) {
      titleController.text = args['title'] ?? '';
      code = args['code'] ?? '';

      var quizData = args['quiz'];
      if (quizData is List) {
        quizList = List<Map<String, dynamic>>.from(quizData);
      } else if (quizData is Set) {
        quizList = List<Map<String, dynamic>>.from(quizData.toList());
      } else {
        quizList = [];
      }

      print('quizList 로드 완료: $quizList'); //quizList 정상 로드 확인

      setState(() {}); // 화면 갱신

      if (quizList.isNotEmpty) {
        loadQuestion(0);
      } else {
        print('quizList가 비어 있음');
      }
    } else {
      print('arguments가 없음');
    }
  });
}


  void loadQuestion(int index) {
    if (index < quizList.length) {
      var quiz = quizList[index];
      questionController.text = quiz['question'];
      answerController.text = quiz['answer'];
      questionType = quiz['isMultipleChoice'] ? '객관식' : 'OX';

      // 선택지 설정
      for (int i = 0; i < optionControllers.length; i++) {
        optionControllers[i].text =
            (quiz['options'] != null && i < quiz['options'].length)
                ? quiz['options'][i]
                : '';
      }

      setState(() {
        currentIndex = index;
        questionNumber = index + 1;
      });
    }
  }

  void saveCurrentQuestion() {
    if (questionController.text.isNotEmpty) {
      quizList[currentIndex] = {
        'question': questionController.text,
        'isMultipleChoice': questionType == '객관식',
        'answer': answerController.text,
        'options': questionType == '객관식'
            ? optionControllers.map((c) => c.text).toList()
            : [],
      };
    }
  }

  Future<void> sendQuizData() async {
    var url = Uri.parse(''); // 백엔드 URL
    var headers = {
      'Content-Type': 'application/json'
    };

    var body = jsonEncode({
      'code': code, // 기존 퀴즈 코드 유지
      'title': titleController.text,
      'quizList': quizList,
    });

    try {
      var response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('퀴즈 수정 완료'),
              content: Text('퀴즈가 성공적으로 수정되었습니다.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/manQuiz');
                  },
                  child: Text('확인'),
                ),
              ],
            );
          },
        );
      } else {
        print('퀴즈 수정 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('서버와 연결 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('퀴즈 수정하기'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: sendQuizData,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '문제 $questionNumber',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              controller: questionController,
              decoration: InputDecoration(
                labelText: '문제 입력',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: answerController,
              decoration: InputDecoration(
                labelText: '정답 입력',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            if (questionType == '객관식') ...[
              for (int i = 0; i < 5; i++)
                TextField(
                  controller: optionControllers[i],
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
                  onPressed: currentIndex > 0
                      ? () {
                          saveCurrentQuestion();
                          loadQuestion(currentIndex - 1);
                        }
                      : null,
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: currentIndex < quizList.length - 1
                      ? () {
                          saveCurrentQuestion();
                          loadQuestion(currentIndex + 1);
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
