const express = require('express');
const Quiz = require('../models/quiz');

const router = express.Router();

// 코드 입력 받기, 해당 문제 삭제
router.post('/', async (req, res) => {
    console.log(await req.body);
    const deleteCode = await req.body.code;

    try {
        const result = await Quiz.deleteOne({code : deleteCode});
        if (result.deletedCount === 0) {
            res.status(404).json({success : false, detail : 'There is no such quiz'});
        } else {
            res.status(200).json({success : true});
        }
        
    } catch (e) {
        return res.status(500).json({ success: false, details: e });
    }
})

module.exports = router;