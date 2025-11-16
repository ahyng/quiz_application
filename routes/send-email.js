// // // email.js
// // // const { google } = require("googleapis");
// // // const nodemailer = require("nodemailer"); // 메시지 인코딩에 사용
// // // require("dotenv").config();

// // // const oAuth2Client = new google.auth.OAuth2(
// // //   process.env.GMAIL_CLIENT_ID,
// // //   process.env.GMAIL_CLIENT_SECRET,
// // //   process.env.GMAIL_REDIRECT_URI
// // // );

// // // oAuth2Client.setCredentials({ refresh_token: process.env.GMAIL_REFRESH_TOKEN });

// // // async function sendEmail(to) {
// // //   const OTP = Math.floor(1000 + Math.random() * 9000);

// // //   try {
// // //     const gmail = google.gmail({ version: "v1", auth: oAuth2Client });

// // //     const subject = "퀴즈팩토리 본인 인증 번호 발송";
// // //     const encodedSubject = `=?UTF-8?B?${Buffer.from(subject).toString("base64")}?=`;

// // //     const mail = [
// // //       `From: Quiz Factory <${process.env.GMAIL_USER}>`,
// // //       `To: ${to}`,
// // //       `Subject: ${encodedSubject}`,
// // //       "MIME-Version: 1.0",
// // //       "Content-Type: text/html; charset=UTF-8",
// // //       "",
// // //       `
// // //         <div style="background-color: #A4C3FF; padding: 30px;">
// // //           <div style="text-align: center; padding: 30px; background-color: white; border-radius: 10px;">
// // //             <h1 style="color: #1A237E; font-size: 28px; margin-bottom: 20px; font-weight: bold;">
// // //               QUIZ FACTORY
// // //             </h1>
// // //             <p style="font-size: 15px;">안녕하세요. 퀴즈팩토리입니다.</p>
// // //             <p style="font-size: 15px;">어플 내에서 다음 인증 번호를 입력해 주세요.</p>
// // //             <p style="font-size: 20px; font-weight: bold;">인증 번호</p>
// // //             <p style="color: blue; font-size: 30px; font-weight: bold;">${OTP}</p>
// // //             <p style="font-size: 15px;">이용해 주셔서 감사합니다.</p>
// // //           </div>
// // //         </div>
// // //       `
// // //     ].join("\n");

// // //     // Base64url 인코딩
// // //     const encodedMessage = Buffer.from(mail)
// // //       .toString("base64")
// // //       .replace(/\+/g, "-")
// // //       .replace(/\//g, "_")
// // //       .replace(/=+$/, "");

// // //     // Gmail API 호출
// // //     const result = await gmail.users.messages.send({
// // //       userId: "me",
// // //       requestBody: {
// // //         raw: encodedMessage,
// // //       },
// // //     });

// // //     console.log("메일 전송 성공:", result.data.id);
// // //     return { success: true, otp: OTP };
// // //   } catch (err) {
// // //     console.error("메일 전송 실패:", err);
// // //     return { success: false, error: err.message };
// // //   }
// // // }

// // const { Resend } = require("resend");
// // require("dotenv").config();

// // const resend = new Resend(process.env.RESEND_API_KEY);

// // async function sendEmail(to) {
// //   const OTP = Math.floor(1000 + Math.random() * 9000);

// //   try {
// //     const data = await resend.emails.send({
// //       from: "onboarding@resend.dev",
// //       to: to,
// //       subject: "인증번호 안내",
// //       html: `
// //         <div style="background:#A4C3FF;padding:30px;">
// //           <div style="background:#fff;padding:30px;border-radius:10px;text-align:center;">
// //             <h2 style="color:#1A237E;">이메일 인증번호</h2>
// //             <p style="font-size:32px;font-weight:bold;">${OTP}</p>
// //             <p style="color:#555;">5분 이내에 입력해주세요.</p>
// //           </div>
// //         </div>
// //       `,
// //     });

// //     console.log("메일 전송 성공:", data);
// //     return { success: true, otp: OTP };
// //   } catch (err) {
// //     console.error("메일 전송 실패:", err);
// //     return { success: false, error: err.message };
// //   }
// // }

// // module.exports = sendEmail;

// const nodemailer = require('nodemailer');
// require('dotenv').config();


// const sendEmail = async (email) => {
//   console.log(email);
//   const transporter = nodemailer.createTransport({
//       service: 'gmail', 
//       port: 465,
//       secure: true,
//       auth: {
//         user: 'corangstudio@gmail.com', 
//         pass: process.env.EMAIL_PWD
//       }
//   });

//   const OTP = Math.floor(1000 + Math.random() * 9000);

//   const mailOptions = {
//     from: 'corangstudio@gmail.com', 
//     to: email, 
//     subject: '퀴즈팩토리 본인 인증 번호 발송', // 메일 제목
//   //   text: '인증번호는' + OTP + '입니다. 해당 인증번호를 앱에서 입력해 주세요.', 
//     html: `
//           <div style="background-color: #A4C3FF; padding: 30px;">
//           <div style="text-align: center; padding: 30px; background-color: white; border-radius: 10px;">
            
//             <!-- 앱 이름 표시 -->
//             <h1 style="color: rgb(26, 35, 126); font-size: 28px; margin-bottom: 20px; font-weight: bold;">
//               QUIZ FACTORY
//             </h1>

//             <!-- 본문 내용 -->
//             <p style="font-size: 15px;">안녕하세요. 퀴즈팩토리입니다.</p>
//             <p style="font-size: 15px;">어플 내에서 다음 인증 번호를 입력해 주세요.</p>
//             <p style="font-size: 20px; font-weight: bold;">인증 번호</p>
//             <p style="color: blue; font-size: 30px; font-weight: bold;">${OTP}</p>
//             <p style="font-size: 15px;">저희 어플을 이용해 주셔서 감사합니다.</p>
            
//           </div>
//         </div>
//         `
//   };

//   try {
//       await transporter.sendMail(mailOptions); 
//       return { success: true, otp: OTP }; 
//   } catch (error) {
//       console.error('메일 전송 실패:', error);
//       return { success: false };
// }


// }
    
// module.exports = sendEmail;


