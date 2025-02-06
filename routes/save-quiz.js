const express = require('express');

const Quiz = require('../models/quiz');
const authenticate = require('../middleware/auth');

const router = express.Router();

// 퀴즈 저장
router.post('/', authenticate, async (req, res) => {
    console.log("body : " , req.body);

    let randomCode = Math.random().toString(36).slice(2);
    let codeCheck = await Quiz.findOne({code : randomCode});

    while (codeCheck) {
        randomCode = Math.random().toString(36).slice(2);
        codeCheck = await Quiz.findOne({code : randomCode});
    }

    Quiz.create({userId : req.user? req.user.userId : "anonymous", quiz : req.body.quizList, code : randomCode});
    res.status(200).json({code : randomCode});
    
})

module.exports = router;