const express = require('express');

const Quiz = require('../models/quiz');
const authenticate = require('../middleware/auth');

const router = express.Router();

// 퀴즈 저장
router.post('/', authenticate, async (req, res) => {
    console.log("body : " , req.body);

    try {

        if (req.user) {
            
        }
        let randomCode = Math.random().toString(36).slice(2);
        let codeCheck = await Quiz.findOne({code : randomCode});

        while (codeCheck) {
            randomCode = Math.random().toString(36).slice(2);
            codeCheck = await Quiz.findOne({code : randomCode});
        }

        console.log('user1:', req.user);

        await Quiz.create({userId :  req.user.userId, title : req.body.title, quiz : req.body.quizList, code : randomCode});
        console.log('created');

        if (res.locals.newAccessToken) {
            res.status(201).json({code : randomCode, accesstoken : res.locals.newAccessToken});
        }
        res.status(200).json({code : randomCode});
    } catch (e) {
        console.log('quiz save failed');
        res.status(500).json({message : failed});
    }
})

module.exports = router;