const express = require('express')
const bcrypt = require("bcrypt");
const User = require('../models/user');

const router = express.Router();

const salt = 10;

router.post('/', async (req, res) => {
    console.log(req.body);
    const pwdCheck = req.body.password.length >= 8;

    if (!pwdCheck) {
        res.status(400).json({success : false, message : "pwd length"});
    } else {
        const hashedPwd = await bcrypt.hash(req.body.password, salt);

        try {
            await User.findOneAndUpdate(
                { userId : req.body.userId }, 
                { password: hashedPwd }, 
                { new: true } 
            );

            res.status(200).json({success : true});
        } catch (e) {
            console.log(e);
            res.status(500);
        }
    }
})

module.exports = router;