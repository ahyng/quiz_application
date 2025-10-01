const nodemailer = require('nodemailer');
require('dotenv').config();


const sendEmail = async (email) => {
  console.log(email);
  const transporter = nodemailer.createTransport({
      service: 'gmail', 
      port: 465,
      secure: true,
      auth: {
        user: 'corangstudio@gmail.com', 
        pass: process.env.EMAIL_PWD
      }
  });

  const OTP = Math.floor(1000 + Math.random() * 9000);

  const mailOptions = {
    from: 'corangstudio@gmail.com', 
    to: email, 
    subject: '퀴즈팩토리 본인 인증 번호 발송', // 메일 제목
  //   text: '인증번호는' + OTP + '입니다. 해당 인증번호를 앱에서 입력해 주세요.', 
    html: `
          <div style="background-color: #A4C3FF; padding: 30px;">
          <div style="text-align: center; padding: 30px; background-color: white; border-radius: 10px;">
            
            <!-- 앱 이름 표시 -->
            <h1 style="color: rgb(26, 35, 126); font-size: 28px; margin-bottom: 20px; font-weight: bold;">
              QUIZ FACTORY
            </h1>

            <!-- 본문 내용 -->
            <p style="font-size: 15px;">안녕하세요. 퀴즈팩토리입니다.</p>
            <p style="font-size: 15px;">어플 내에서 다음 인증 번호를 입력해 주세요.</p>
            <p style="font-size: 20px; font-weight: bold;">인증 번호</p>
            <p style="color: blue; font-size: 30px; font-weight: bold;">${OTP}</p>
            <p style="font-size: 15px;">저희 어플을 이용해 주셔서 감사합니다.</p>
            
          </div>
        </div>
        `
  };

  try {
      await transporter.sendMail(mailOptions); 
      return { success: true, otp: OTP }; 
  } catch (error) {
      console.error('메일 전송 실패:', error);
      return { success: false };
}


}
    
module.exports = sendEmail;


