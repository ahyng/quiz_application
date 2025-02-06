const express = require('express')
const bcrypt = require("bcrypt");
const jwt = require('jsonwebtoken');
const User = require('../models/user');


const router = express.Router();

const jwtSecretKey = process.env.jWT_SECRET_KEY;


// 로그인
router.post('/', async (req, res) => {
    console.log(await req.body);
    const loginPwd = await req.body.password;
    const user = await User.findOne({userId : req.body.userId});

    if (user) {
        const checkPwd = await bcrypt.compare(loginPwd, user.password);
        if (checkPwd) {
            const payload = {
                userId : req.body.userId,
                role : "user"
            };

            const accessToken = jwt.sign(payload, jwtSecretKey, {expiresIn : '1h'});
            const refreshToken = jwt.sign(payload, jwtSecretKey, { expiresIn: '60d' });

            res.cookie("accessToken", accessToken, {
                httpOnly: true,  // JavaScript에서 접근 불가 (보안 강화)
                secure: false,    // HTTPS에서만 전송
                sameSite: "None"
              });
              
            res.cookie("refreshToken", refreshToken, {
                httpOnly: true,
                secure: false,
                sameSite: "None"
            });

            console.log('succeed');
            res.status(200).json({success : true, token : accessToken});
        } else {
            console.log('failed');
            res.status(401).json({success : false, message : "invalid pwd"});
        }
    } else {
        console.log('user not found');
        res.status(401).json({success : false, message : "user not found"});
    }
})

module.exports = router;