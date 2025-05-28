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
        const hashedPwd = await bcrypt.hash(req.body.newPassword.trim(), salt);

        try {
            await User.findOneAndUpdate(
                { userId : req.body.email.trim() }, 
                { password: hashedPwd }, 
                { new: true } 
            );

            return res.status(200).json({success : true});
        } catch (e) {
            console.log(e);
            return res.status(500);
        }
    }
})

module.exports = router;