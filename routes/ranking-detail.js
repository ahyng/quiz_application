const express = require('express');
const Quiz = require('../models/quiz');
const router = express.Router();

router.post("/", async (req, res) => {
    console.log("detail page:", req.body);
    const inputCode = req.body.code;
    const userName = req.body.name;

    try {
        const data = await Quiz.findOne(
            { code: inputCode }, 
            { "result": { $elemMatch: { name: userName } }}
        );
    
        console.log(data);
        console.log("data:", data.result[0].scoreDetails);
        return res.status(200).json({data : data.result[0].scoreDetails});
    } catch (e) {
        console.log(e);
        return res.status(500).json({message : e});
    }

})

module.exports = router;