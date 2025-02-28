const express = require('express');
const Quiz = require('../models/quiz');
const nameCheck = require('../middleware/name-check');

const router = express.Router();

// 문제 채점
router.post('/', nameCheck, async (req, res) => {
    console.log(req.body);
    const inputCode = req.body.code;
    const findQuiz = await Quiz.findOne({code : inputCode});
    const userName = req.body.name;

    const userAnswers = req.body.userAnswers;

    console.log("findQuiz:", findQuiz);
    console.log("userAns:", userAnswers);
    // 맞은 개수
    let score = 0;
    let perfectScore = false;
    
    // 각 문제를 맞았는지 / 틀렸는지
    let scoreDetails = [];

    const nameCheck = await Quiz.findOne({ 
        code: req.body.code, 
        "result.name": req.body.name
    });

    if (nameCheck) {
        res.status(409).json({message : "exist name"})
    }

    for (let i=0; i< findQuiz.quiz.length; i++) {
        if (findQuiz.quiz[i].answer == userAnswers[i]) {
            score += 1;
        } 
        scoreDetails.push({
            number : i,
            userAnswer : userAnswers[i],
            correctAnswer : findQuiz.quiz[i].answer,
        });
        console.log(i);
        console.log(score);
    }

    if (score == findQuiz.quiz.length) {
        perfectScore = true;
    }

    console.log("score :", score);
    console.log("scoreDetails:", scoreDetails);
    console.log("code", inputCode);

    console.log("username", userName);
    
    // 퀴즈 데이터에 각 학생의 점수 저장
    await Quiz.findOneAndUpdate(
        {code : inputCode},
        {$push : {result : {
            name : userName,
            score : score,
            perfectScore : perfectScore,
            scoreDetails : scoreDetails,
        }}},
        { new: true, upsert: true }
    );


    const updatedQuiz = await Quiz.findOne({ code: inputCode });
    console.log("업데이트된 퀴즈 데이터:", updatedQuiz.result);

    // 점수, 각 문제에 대한 채점 결과 반환
    res.status(200).json({score : score, scoreDetails : scoreDetails});
})

module.exports = router;