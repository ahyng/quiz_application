import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MakeQuiz extends StatefulWidget {
  @override
  _MakeQuizScreenState createState() => _MakeQuizScreenState();
}

class _MakeQuizScreenState extends State<MakeQuiz> {
  List<Map<String, dynamic>> quizList = [];
  int currentIndex = 0;
  int questionNumber = 1;
  TextEditingController questionController = TextEditingController();
  TextEditingController answerController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  List<TextEditingController> optionControllers =
      List.generate(5, (index) => TextEditingController());
  String questionType = '객관식'; // '객관식' or 'OX'
  String code = '';

  Future<void> saveCookie(String cookie) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('cookie', cookie);
  }

  Future<String?> getCookie() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('cookie');
  }

  void saveCurrentQuestion() {
    if (questionController.text.isNotEmpty) {
      if (quizList.length > currentIndex) {
        quizList[currentIndex] = {
          'question': questionController.text,
          'isMultipleChoice': questionType == '객관식',
          'answer': answerController.text,
          'options': questionType == '객관식'
              ? optionControllers.map((c) => c.text).toList()
              : [],
        };
      } else {
        quizList.add({
          'question': questionController.text,
          'isMultipleChoice': questionType == '객관식',
          'answer': answerController.text,
          'options': questionType == '객관식'
              ? optionControllers.map((c) => c.text).toList()
              : [],
        });
      }
    }
  }

  Future<void> submitQuiz() async {
    saveCurrentQuestion();

    if (quizList.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('오류'),
          content: Text('퀴즈를 먼저 추가하세요!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('확인'),
            ),
          ],
        ),
      );
      return;
    }

    showTitleDialog();
  }

  void showTitleDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('퀴즈 제목 입력'),
          content: TextField(
            controller: titleController,
            decoration: InputDecoration(hintText: '퀴즈 제목을 입력하세요'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                sendQuizData();
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  Future<void> sendQuizData() async {
    String? cookie = await getCookie();
    var url = Uri.parse(''); // 백엔드 URL
    var headers = {
      'Content-Type': 'application/json',
      if (cookie != null) 'Cookie': cookie
    };

    var body = jsonEncode({
      'title': titleController.text,
      'quizList': quizList,
    });

    try {
      var response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        String code = responseData['code'];

        setState(() {
          this.code = code;
        });

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('퀴즈 제출 완료'),
              content: Text('퀴즈가 성공적으로 저장되었습니다.\n퀴즈 코드: $code'),
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
        print('퀴즈 제출 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('서버와 연결 실패: $e');
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
            onPressed: submitQuiz,
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
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => questionType = '객관식'),
                  child: Text('객관식'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: questionType == '객관식' ? Colors.blue : Colors.grey,
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => setState(() => questionType = 'OX'),
                  child: Text('OX문제'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: questionType == 'OX' ? Colors.blue : Colors.grey,
                  ),
                ),
              ],
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
                          setState(() {
                            currentIndex--;
                            questionNumber--;
                          });
                        }
                      : null,
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () {
                    saveCurrentQuestion();
                    setState(() {
                      currentIndex++;
                      questionNumber++;
                      questionController.clear();
                      answerController.clear();
                      for (var c in optionControllers) {
                        c.clear();
                      }
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            if (code.isNotEmpty)
              Text(
                '퀴즈 코드: $code',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
              ),
          ],
        ),
      ),
    );
  }
}
