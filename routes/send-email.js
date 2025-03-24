const nodemailer = require('nodemailer');
require('dotenv').config();

const express = require('express');
const router = express.Router();

router.post('/', async (req, res) => {
    console.log(req.body);

    const transporter = nodemailer.createTransport({
        service: 'gmail', 
        auth: {
          user: 'ahyng1@gmail.com', 
          pass: process.env.EMAIL_PWD 
        }
    });

    const OTP = Math.floor(1000 + Math.random() * 9000);
    
    const mailOptions = {
      from: 'ahyng1@gmail.com', 
      to: req.body.email, 
      subject: '퀴즈앱 본인인증번호 발송', // 메일 제목
      text: '인증번호는' + OTP + '입니다. 해당 인증번호를 앱에서 입력해 주세요.', 
    };
    
    transporter.sendMail(mailOptions, function(error, info){
        if (error) {
            console.log(error);
            res.status(500);
        } else {
            console.log('Email sent: ' + info.response);
            res.status(200).json({otp : OTP});
        }
    });
});

module.exports = router;


