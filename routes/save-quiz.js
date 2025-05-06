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

    console.log('user1:', req.user);

    await Quiz.create({userId : req.user? req.user.userId : "Anonymous", title : req.body.title, quiz : req.body.quizList, code : randomCode});
    console.log('created');
    res.status(200).json({code : randomCode});
    
})

module.exports = router;