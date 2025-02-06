const express = require('express');
const Quiz = require('../models/quiz');

const router = express.Router();

// 코드 입력 받기, 해당 문제 quiz 수정
router.post('/', async (req, res) => {
    console.log(await req.body);
    const quizCode = await req.body.code;
    const newQuiz = await req.body.quiz;

    try {
        const result = await Quiz.findOneAndUpdate(
            {code : quizCode},
            {$set : {quiz : newQuiz}},
            {new : true}
        );
        if (result) {
            res.status(200).json({success : true});
        } else {
            res.status(404).json({success : false, detail : 'There is no such quiz'});
        }
        
    } catch (e) {
        return res.status(500).json({ success: false, details: e });
    }
})

module.exports = router;