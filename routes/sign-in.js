const express = require('express')
const bcrypt = require("bcrypt");
const jwt = require('jsonwebtoken');
const User = require('../models/user');

const router = express.Router();

const jwtSecretKey = process.env.JWT_SECRET_KEY;

// 로그인
router.post('/', async (req, res) => {
    console.log(req.body);
    const loginPwd = req.body.password;
    const user = await User.findOne({userId : req.body.userId});
    console.log(user);

    if (user) {
        const checkPwd = await bcrypt.compare(loginPwd, user.password);
        if (checkPwd) {
            const payload = {
                userId : req.body.userId,
                role : "user"
            };

            const accessToken = jwt.sign(payload, jwtSecretKey, {expiresIn : '1m'});
            const refreshToken = jwt.sign(payload, jwtSecretKey, { expiresIn: '5m' });

            console.log('succeed');
            res.status(200).json({success : true, accessToken : accessToken, refreshToken : refreshToken});
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