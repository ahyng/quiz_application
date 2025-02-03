import 'package:flutter/material.dart';

class StudentScore extends StatefulWidget {
  final int score;
  final int totalQuestions;

  // 생성자
  StudentScore({required this.score, required this.totalQuestions});

  @override
  _StudentScoreState createState() => _StudentScoreState();
}

class _StudentScoreState extends State<StudentScore> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('학생 결과')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '퀴즈 결과',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              '총 문제 수: ${widget.totalQuestions}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              '맞힌 문제 수: ${widget.score}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 홈 화면으로 돌아가기
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB8E0FF),
                foregroundColor: const Color(0xFF212121),
              ),
              child: Text('홈으로 돌아가기'),
            ),
          ],
        ),
      ),
    );
  }
}

