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
  TextEditingController answerController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  List<TextEditingController> optionControllers =
      List.generate(5, (index) => TextEditingController());
  String questionType = '객관식'; // '객관식' or 'OX'
  String code = '';

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
  bool isAuthValid = await checkAndRefreshToken();
  if (!isAuthValid) return; // 토큰 무효 → 로그인 이동됨

  // 토큰이 유효하므로 퀴즈 제출 시도
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
        print('액세스 토큰 갱신 완료. 다시 요청 시도 중...');
        await _attemptSubmitQuiz(isRetry: true); // 재시도
      } else if (response.statusCode == 401) {
        print('인증 실패. 로그인 화면으로 이동합니다.');
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
      print('✅ accessToken 유효');
      return true;
    } else if (response.statusCode == 201) {
      var responseData = jsonDecode(response.body);
      String newAccessToken = responseData['accessToken'];
      await storage.write(key: 'access_token', value: newAccessToken);
      print('🔄 accessToken 갱신 성공');
      return true;
    } else if (response.statusCode == 401) {
      print('❌ access/refresh 토큰 만료 → 로그인으로 이동');
      Navigator.pushNamed(context, '/login');
      return false;
    } else {
      print('⚠️ 알 수 없는 상태 코드: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('🌐 auth-check 오류: $e');
    return false;
  }
}

  void loadQuestion(int index) {
  if (quizList.length > index) {
    final quiz = quizList[index];
    questionController.text = quiz['question'] ?? '';
    answerController.text = quiz['answer'] ?? '';
    questionType = quiz['isMultipleChoice'] == true ? '객관식' : 'OX';

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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // 화면 탭 시 키보드 숨김
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16.0),
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
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => questionType = '객관식'),
                      child: Text('객관식'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: questionType == '객관식' ? Colors.indigo : Colors.grey[400],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => questionType = 'OX'),
                      child: Text('OX문제'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: questionType == 'OX' ? Colors.indigo : Colors.grey[400],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextField(
                controller: answerController,
                decoration: InputDecoration(
                  labelText: '정답 입력',
                  hintText: questionType == '객관식' 
                      ? '1, 2, 3, 4, 5 중 하나를 입력하세요' 
                      : 'O 또는 X를 입력하세요',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 16),
              if (questionType == '객관식') ...[
                for (int i = 0; i < 5; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TextField(
                      controller: optionControllers[i],
                      decoration: InputDecoration(
                        labelText: '선택지 ${i + 1}',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
              ],
              SizedBox(height: 20),
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
                        answerController.clear();
                        for (var c in optionControllers) {
                          c.clear();
                        }
                      });
                      Future.delayed(Duration.zero, () => loadQuestion(currentIndex));
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              if (code.isNotEmpty)
                Center(
                  child: Text(
                    '퀴즈 코드: $code',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}