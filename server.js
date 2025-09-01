const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const cookieParser = require('cookie-parser');

require("dotenv").config();

const app = express();
const port = 3000;

app.use(express.json());
app.use(express.urlencoded({extended : true}));
app.use(cors({
    origin: '*',
    credentials: true, 
  }));
app.use(cookieParser());

const dbConnect = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_URI, {
            maxPoolSize: 20,
            serverSelectionTimeoutMS: 5000,  // 서버 선택 타임아웃
            socketTimeoutMS: 45000,          // 소켓 읽기/쓰기 타임아웃
            connectTimeoutMS: 30000,         // 연결 시도 타임아웃
            bufferCommands: false,           // 끊긴 후 버퍼링 안 함
            retryWrites: true,
            retryReads: true,
        });
        console.log('db connected');
    } catch (e) {
        console.log(e);
    }
}

dbConnect();

// client.on('connect', () => {
//     console.log('Connected to Redis');
// });

app.listen(port, () => {
    console.log(`Example app listening on port ${port}`)
})

app.get('/', (req, res) => {
    res.send('Hello World!');
})

const signUpRoutes = require('./routes/sign-up');
const signInRoutes = require('./routes/sign-in');
const main = require('./routes/main');
const saveQuiz = require('./routes/save-quiz');
const findQuiz = require('./routes/find-quiz');
const evaluate = require('./routes/evaluate');
const deleteQuiz = require('./routes/delete-quiz');
const updateQuiz = require('./routes/update-quiz');
const ranking = require('./routes/ranking');
const rankingDetail = require('./routes/ranking-detail');
const sendEmail = require('./routes/email-check');
const changePassword = require('./routes/change-password');
const deleteAccount = require('./routes/delete-account');
const otpCheck = require('./routes/otp-check');
const requestResetPwd = require('./routes/request-reset-pwd');

app.use('/sign-up', signUpRoutes);
app.use('/sign-in', signInRoutes);
app.use('/main', main);
app.use('/write', saveQuiz);
app.use('/find-quiz', findQuiz);
app.use('/evaluate', evaluate);
app.use('/delete-quiz', deleteQuiz);
app.use('/update-quiz', updateQuiz);
app.use('/ranking', ranking);
app.use('/ranking-detail', rankingDetail);
app.use('/send-email', sendEmail);
app.use('/change-password', changePassword);
app.use('/delete-account', deleteAccount);
app.use('/otp-check', otpCheck);
app.use('/request-reset-pwd', requestResetPwd); // 비밀번호 변경시 otp 전송