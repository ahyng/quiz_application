import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screen/home_screen.dart';
import 'screen/login_screen.dart';
import 'screen/code_screen.dart';
import 'screen/signup_screen.dart';
import 'screen/manageQuiz_screen.dart';
import 'screen/makeQuiz_screen.dart';
import 'screen/solveQuiz_screen.dart';
import 'screen/studentScore_screen.dart';
import 'screen/eiditQuiz_scree.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/manQuiz', // 초기 화면
      routes: {
        '/': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/enter_code': (context) => CodeScreen(),
        '/manQuiz':(context) => ManageQuiz(),
        '/make_quiz':(contest) => MakeQuiz(),
        '/solve-quiz':(contest) => SolveQuiz(),
        '/edit_quiz':(context) => EditQuiz(),
        '/student_score':(context) => StudentScoreScreen()
      },
    );
  }
}
