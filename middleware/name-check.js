const express = require('express');
const Quiz = require('../models/quiz');

const nameCheck = async (req, res, next) => {
    console.log(req.body);
    const inputCode = req.body.code;
    const userName = req.body.name;

    try {
        const nameCheck = await Quiz.findOne({ 
            code: inputCode, 
            "result.name": userName
        });
    
        if (nameCheck) {
            res.status(409).json({message : "exist name"});
        } else {
            next();
        }
    } catch (e) {
        console.log(e);
        res.status(500).json({message : e});
    }
    
}

module.exports = nameCheck;