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

        // if (req.body.title && req.body.quizList) {
            await Quiz.create({userId :  req.user.userId, title : req.body.title, quiz : req.body.quizList, code : randomCode});
            console.log('quiz created');

            if (res.locals.newAccessToken) {
                return res.status(201).json({code : randomCode, accessToken : res.locals.newAccessToken});
            }
            return res.status(200).json({code : randomCode});
        // } else {
        //     return res.status(400).json({message : "quiz save failed"});
        // }
        
    } catch (e) {
        console.log('quiz save failed');
        return res.status(500).json({message : 'failed'});
    }
})

module.exports = router;