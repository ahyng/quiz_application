const express = require('express');
const authenticate = require('../middleware/auth');

const Quiz = require('../models/quiz');

const router = express.Router();

// 퀴즈 목록 가져오기
router.post('/', authenticate, async (req, res) => {
    
    // const current_Id = await req.user.userId;

    try {
        const findData = await Quiz.find({userId : "anonymous"});
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