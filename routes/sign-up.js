const express = require('express')
const bcrypt = require("bcrypt");
const User = require('../models/user');

const router = express.Router();

const salt = 10;

// 회원가입
router.post('/', async (req, res) => {
    console.log(req.body);
    const pwdCheck = req.body.password.length >= 8;
    const idCheck = await User.findOne({userId : req.body.email});

    if (idCheck) {
        res.status(409).json({success : false, message : "id exists"});
    } else if (!pwdCheck) {
        res.status(400).json({success : false, message : "pwd length"});
    } else {
        const hashedPwd = await bcrypt.hash(req.body.password, salt);
        User.create({userId : req.body.email, password : hashedPwd});
        res.status(200).json({success : true, message : "succeed"});
    }
})

module.exports = router;