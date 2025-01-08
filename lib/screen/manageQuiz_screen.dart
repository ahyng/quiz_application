import 'package:flutter/material.dart';

class ManageQuiz extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('퀴즈 만들기')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Center(child: Text('화면 구성')),
          ),
          Align(
            alignment: Alignment.bottomCenter,  // 버튼을 화면 하단 중앙으로 배치
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/make_quiz');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB8E0FF),
                  foregroundColor: const Color(0xFF212121),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),  // borderRadius를 크게 설정하여 동그란 모양
                  ),
                  minimumSize: Size(60, 60),  // 너비와 높이를 동일하게 설정
                ),
                child: Text('+', style: TextStyle(fontSize: 20)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
