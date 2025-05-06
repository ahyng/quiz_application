const express = require('express')
const bcrypt = require("bcrypt");
const User = require('../models/user');

const router = express.Router();

const salt = 10;

router.post('/', async (req, res) => {
    console.log(req.body);
    const pwdCheck = req.body.newPassword.length >= 8;

    if (!pwdCheck) {
        res.status(400).json({success : false, message : "pwd length"});
    } else {
        const hashedPwd = await bcrypt.hash(req.body.newPassword, salt);

        try {
            await User.findOneAndUpdate(
                { email : req.body.email }, 
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