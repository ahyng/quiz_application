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
    //   text: '인증번호는' + OTP + '입니다. 해당 인증번호를 앱에서 입력해 주세요.', 
      html: `
            <div style="background-color : #A4C3FF; padding: 30px;">
            <div style="text-align : center; padding: 30px; background-color : white">
            <p style="font-size : 15px;">퀴즈앱 본인 인증 메일입니다.</p>
            <p style="font-size : 15px">어플 내에서 다음 인증번호를 입력해 주세요.</p>
            <p style="font-size : 20px; font-weight : bold">인증번호</p>
            <p style="color : blue; font-size : 30px; font-weight : bold">${OTP}</p>
            <p style="font-size : 15px">저희 어플을 이용해 주셔서 감사합니다.</p>
            </div>
            </div>
            `
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


