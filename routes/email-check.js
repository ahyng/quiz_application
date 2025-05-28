const express = require('express')
const bcrypt = require("bcrypt");
const User = require('../models/user');
const sendEmail = require('./send-email');
const redisClient = require('./redis-client');

const router = express.Router();

const salt = 10;

// 회원가입 - 이메일 확인
router.post('/', async (req, res) => {
    console.log(req.body);

    try {
        const idCheck = await User.findOne({userId : req.body.email});
    
        if (idCheck) {
            return res.status(409).json({success : false, message : "id exists"});
        } else {
            const send = await sendEmail(req.body.email);
            console.log('send:', send);
            await redisClient.setEx(`otp:${req.body.email}`, 180, String(send.otp));
            if (send.success) {
                return res.status(200).json({success : true, otp : send.otp});
            }
        }
    } catch (e) {
        return res.status(500).json({message : e});
    }
    
})

module.exports = router;