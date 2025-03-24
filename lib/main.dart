import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'screen/home_screen.dart';
import 'screen/login_screen.dart';
import 'screen/code_screen.dart';
import 'screen/signup_screen.dart';
import 'screen/manageQuiz_screen.dart';
import 'screen/makeQuiz_screen.dart';
import 'screen/solveQuiz_screen.dart';
import 'screen/studentScore_screen.dart';
import 'screen/eiditQuiz_scree.dart';
import 'screen/quizResult_screen.dart';
import 'screen/change_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");

  final dio = Dio();
  dio.options.headers = {
    'Content-Type': 'application/json',
  };

  // 스토리지에서 accessToken 불러오기
  final storage = FlutterSecureStorage();
  String? accessToken = await storage.read(key: "access_token");

  if (accessToken != null) {
    dio.options.headers["Authorization"] = "Bearer $accessToken"; // ✅ 헤더에 추가
  }

  runApp(MyApp(dio: dio));
}

class MyApp extends StatelessWidget {
  final Dio dio;

  MyApp({required this.dio});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/', // 초기 화면을 홈 화면으로 설정
      routes: {
        '/': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/enter_code': (context) => CodeScreen(),
        '/manQuiz': (context) => ManageQuiz(), // 이 위젯이 정상적으로 존재하는지 확인
        '/make_quiz': (context) => MakeQuiz(),
        '/solve-quiz': (context) => SolveQuiz(),
        '/edit_quiz': (context) => EditQuiz(),
        '/student_score': (context) => StudentScoreScreen(),
        '/quizresult' : (context) => QuizResult(),
        '/changepw' : (context) => ChangePasswordScreen(),
      },
    );
  }
}

