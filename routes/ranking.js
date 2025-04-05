const express = require('express');
const Quiz = require('../models/quiz');

const router = express.Router();

router.post("/", async (req, res) => {
    console.log(req.body);

    const quiz = await Quiz.findOne({ code: req.body.code });

    if (quiz) {
        quiz.result.sort((a, b) => b.score - a.score); // 정렬

        console.log("result:", quiz.result);
        console.log(quiz.result);
        res.status(200).json({ ranking: quiz.result });
    } else {
        res.status(404).json({ success: false, detail: '퀴즈를 찾을 수 없습니다.' });
    }
});

module.exports = router;