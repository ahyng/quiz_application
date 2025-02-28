const express = require('express');
const Quiz = require('../models/quiz');

const router = express.Router();

router.post("/", async (req, res) => {
    console.log(req.body);

    try {
        const data = await Quiz.findOne({ 
            code: inputCode, 
            "result.name": userName
        });
    
        console.log(data);
        res.status(200).json({data : data.scoreDetails});
    } catch (e) {
        console.log(e);
        res.status(500).json({message : e});
    }

})

module.exports = router;