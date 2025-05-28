const express = require('express')
const bcrypt = require("bcrypt");
const User = require('../models/user');
const sendEmail = require('./send-email');

const router = express.Router();

const salt = 10;

// 회원가입
router.post('/', async (req, res) => {
    console.log(req.body);
    const pwdCheck = req.body.password.trim().length >= 8;

        if (!pwdCheck) {
            res.status(400).json({success : false, message : "pwd length"});
        } else {

            try {
                const hashedPwd = await bcrypt.hash(req.body.password.trim(), salt);
                User.create({userId : req.body.email.trim(), password : hashedPwd});
                return res.status(200).json({success : true});
            } catch(e) {
                return res.status(500).json({message : e});
            }
            
        }
    }
)

module.exports = router;