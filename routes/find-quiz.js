const express = require('express');
const Quiz = require('../models/quiz');

const router = express.Router();

// 코드 입력 받기, 해당 문제 반환
router.post('/', async (req, res) => {
    console.log(await req.body);
    const inputCode = await req.body.code;

    try {
        const findQuiz = await Quiz.findOne({code : inputCode});
        console.log(findQuiz.quiz);

        if (findQuiz) {
            res.status(200).json({success : true, quiz : findQuiz.quiz});
        } else {
            res.status(404).json({success : false, details : "Quiz not found"});
        }
    } catch (e) {
        return res.status(500).json({ success: false, details: e });
    }
})

module.exports = router;