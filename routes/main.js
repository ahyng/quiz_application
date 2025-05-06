const express = require('express');
const authenticate = require('../middleware/auth');

const Quiz = require('../models/quiz');

const router = express.Router();

// 퀴즈 목록 가져오기
router.get('/', authenticate, async (req, res) => {

    console.log('메인 화면입니다.');

    try {
        
        const findData = await Quiz.find({userId : req.user.userId}).select('title code');
        console.log('퀴즈 찾기');
        console.log('find:', findData);
        if (findData) {
            res.status(200).json({success : true, quiz : findData});
        } else {
            res.status(401).json({success : false, detail : "quiz not found"});
        }
    
    } catch (e) {
        res.status(500).json({success : false, details : e});
    }
})

module.exports = router;