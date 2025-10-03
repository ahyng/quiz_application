// email.js
const nodemailer = require("nodemailer");
const { google } = require("googleapis");

const oAuth2Client = new google.auth.OAuth2(
  process.env.GMAIL_CLIENT_ID,
  process.env.GMAIL_CLIENT_SECRET,
  process.env.GMAIL_REDIRECT_URI
);

oAuth2Client.setCredentials({ refresh_token: process.env.GMAIL_REFRESH_TOKEN });

async function sendEmail(to) {
  const OTP = Math.floor(1000 + Math.random() * 9000);

  try {
    const accessToken = await oAuth2Client.getAccessToken();

    const transporter = nodemailer.createTransport({
      service: "gmail",
      auth: {
        type: "OAuth2",
        user: process.env.GMAIL_USER,         
        clientId: process.env.GMAIL_CLIENT_ID,
        clientSecret: process.env.GMAIL_CLIENT_SECRET,
        refreshToken: process.env.GMAIL_REFRESH_TOKEN,
        accessToken: accessToken.token,        
      },
    });

    const info = await transporter.sendMail({
      from: process.env.GMAIL_USER,
      to ,
      subject: "퀴즈팩토리 본인 인증 번호 발송",
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
        `,
    });

    console.log("메일 전송 성공:", info.messageId);
    return { success: true, otp: OTP };
  } catch (err) {
    console.error("메일 전송 실패:", err);
    return { success: false, error: err.message };
  }
}

module.exports = sendEmail;