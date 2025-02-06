const express = require('express');
const Quiz = require('../models/quiz');
const authenticate = require('../middleware/auth');

const router = express.Router();

// 문제 채점
router.post('/', authenticate, async (req, res) => {
    const inputCode = await req.body.code;
    const findQuiz = await Quiz.findOne({code : inputCode});
    
    const userAnswers = await req.body.userAnswers;

    console.log("findQuiz:", findQuiz);
    console.log("userAns:", userAnswers);
    // 맞은 개수
    let score = 0;
    
    // 각 문제를 맞았는지 / 틀렸는지
    let scoreDetails = [];

    console.log("findquizlength:", findQuiz.quiz.length);

    for (let i=0; i< findQuiz.quiz.length; i++) {
        if (findQuiz.quiz[i].answer == userAnswers[i]) {
            scoreDetails.push({
                number : i,
                isCorrect : true,
            });
            score += 1;
        } else {
            scoreDetails.push({
                number : i,
                isCorrect : false,
            });
        }
        console.log(i);
        console.log(score);
    }

    console.log("score :", score);
    console.log("scoreDetails:", scoreDetails);

    // 퀴즈 데이터에 각 학생의 점수 저장
    Quiz.findOneAndUpdate(
        {code : inputCode},
        {$push : {result : {
            userId : "anonymous",
            score : score,
            scoreDetails : scoreDetails,
        }}},
    );

    // 점수, 각 문제에 대한 채점 결과 반환
    res.status(200).json({score : score, scoreDetails : scoreDetails});
})

module.exports = router;