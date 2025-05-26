import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MakeQuiz extends StatefulWidget {
  @override
  _MakeQuizScreenState createState() => _MakeQuizScreenState();
}

class _MakeQuizScreenState extends State<MakeQuiz> {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  List<Map<String, dynamic>> quizList = [];
  int currentIndex = 0;
  int questionNumber = 1;
  TextEditingController questionController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  List<TextEditingController> optionControllers =
      List.generate(5, (index) => TextEditingController());

  String questionType = '객관식'; // '객관식' or 'OX'
  String selectedAnswer = ''; // 정답으로 선택된 값
  String code = '';

  void saveCurrentQuestion() {
    if (questionController.text.isNotEmpty) {
      final question = {
        'question': questionController.text,
        'isMultipleChoice': questionType == '객관식',
        'answer': selectedAnswer,
        'options': questionType == '객관식'
            ? optionControllers.map((c) => c.text).toList()
            : [],
      };

      if (quizList.length > currentIndex) {
        quizList[currentIndex] = question;
      } else {
        quizList.add(question);
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
    bool isAuthValid = await checkAndRefreshToken();
    if (!isAuthValid) return;

    await _attemptSubmitQuiz();
  }

  Future<void> _attemptSubmitQuiz({bool isRetry = false}) async {
    String? accessToken = await storage.read(key: 'access_token');
    String? refreshToken = await storage.read(key: 'refresh_token');

    var url = Uri.parse('${dotenv.env['ADDRESS']}/write');
    var headers = {
      'Content-Type': 'application/json',
      if (accessToken != null) 'accessToken': 'Bearer $accessToken',
      if (refreshToken != null) 'refreshToken': 'Bearer $refreshToken',
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
                    Navigator.pushReplacementNamed(context, '/manQuiz');
                  },
                  child: Text('확인'),
                ),
              ],
            );
          },
        );
      } else if (response.statusCode == 201 && !isRetry) {
        var responseData = jsonDecode(response.body);
        String newAccessToken = responseData['accessToken'];
        await storage.write(key: 'access_token', value: newAccessToken);
        await _attemptSubmitQuiz(isRetry: true);
      } else if (response.statusCode == 401) {
        Navigator.pushNamed(context, '/login');
      } else {
        print('기타 오류: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('서버 통신 오류: $e');
    }
  }

  Future<bool> checkAndRefreshToken() async {
    String? accessToken = await storage.read(key: 'access_token');
    String? refreshToken = await storage.read(key: 'refresh_token');

    if (accessToken == null || refreshToken == null) {
      Navigator.pushNamed(context, '/login');
      return false;
    }

    var url = Uri.parse('${dotenv.env['ADDRESS']}/write');
    var headers = {
      'Content-Type': 'application/json',
      'accessToken': 'Bearer $accessToken',
      'refreshToken': 'Bearer $refreshToken',
    };

    try {
      var response = await http.post(url, headers: headers);

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 201) {
        var responseData = jsonDecode(response.body);
        String newAccessToken = responseData['accessToken'];
        await storage.write(key: 'access_token', value: newAccessToken);
        return true;
      } else {
        Navigator.pushNamed(context, '/login');
        return false;
      }
    } catch (e) {
      print('auth-check 오류: $e');
      return false;
    }
  }

  void loadQuestion(int index) {
    if (quizList.length > index) {
      final quiz = quizList[index];
      questionController.text = quiz['question'] ?? '';
      questionType = quiz['isMultipleChoice'] == true ? '객관식' : 'OX';
      selectedAnswer = quiz['answer'] ?? '';

      if (questionType == '객관식' && quiz['options'] != null) {
        List<dynamic> options = quiz['options'];
        for (int i = 0; i < 5; i++) {
          optionControllers[i].text = i < options.length ? options[i] : '';
        }
      } else {
        for (int i = 0; i < 5; i++) {
          optionControllers[i].clear();
        }
      }
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
      centerTitle: true,
      title: Text(
        '퀴즈 만들기',
        style: TextStyle(
          color: Colors.indigo[900],
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.check, color: Colors.indigo[900]),
          onPressed: submitQuiz,
        ),
      ],
    ),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '문제 $questionNumber',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo[800]),
              ),
              SizedBox(height: 16),
              TextField(
                controller: questionController,
                decoration: InputDecoration(
                  labelText: '문제 입력',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 20),
              Text('문제 유형 선택:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => questionType = '객관식'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: questionType == '객관식' ? Colors.indigo : Colors.grey[400],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('객관식'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => questionType = 'OX'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: questionType == 'OX' ? Colors.indigo : Colors.grey[400],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('OX문제'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              if (questionType == '객관식') ...[
                for (int i = 0; i < 5; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Radio<String>(
                          value: '${i + 1}',
                          groupValue: selectedAnswer,
                          onChanged: (value) {
                            setState(() {
                              selectedAnswer = value!;
                            });
                          },
                        ),
                        Expanded(
                          child: TextField(
                            controller: optionControllers[i],
                            decoration: InputDecoration(
                              labelText: '선택지 ${i + 1}',
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ] else ...[
                Text('정답 선택:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.indigo[800])),
                SizedBox(height: 12),
                Row(
                  children: ['O', 'X'].map((ox) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedAnswer = ox;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedAnswer == ox ? Colors.indigo : Colors.grey[400],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            minimumSize: Size(0, 60), // 높이 키움
                            padding: EdgeInsets.symmetric(vertical: 16), // 내부 패딩 추가
                          ),
                          child: Text(ox),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, size: 32),
                    color: currentIndex > 0 ? Colors.indigo : Colors.grey,
                    onPressed: currentIndex > 0
                        ? () {
                            saveCurrentQuestion();
                            setState(() {
                              currentIndex--;
                              questionNumber--;
                            });
                            loadQuestion(currentIndex);
                          }
                        : null,
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward, size: 32),
                    color: Colors.indigo,
                    onPressed: () {
                      saveCurrentQuestion();
                      setState(() {
                        currentIndex++;
                        questionNumber++;
                        questionController.clear();
                        selectedAnswer = '';
                        for (var c in optionControllers) {
                          c.clear();
                        }
                      });
                      Future.delayed(Duration.zero, () => loadQuestion(currentIndex));
                    },
                  ),
                ],
              ),
              if (code.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Center(
                    child: Text(
                      '퀴즈 코드: $code',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[800]),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

}
