const express = require('express')
const mongoose = require('mongoose');
const bcrypt = require("bcrypt");
const cors = require('cors');
const jwt = require('jsonwebtoken');
const cookieParser = require('cookie-parser');

require("dotenv").config();

const app = express();
const port = 8080;
const salt = 10;
const jwtSecretKey = process.env.jWT_SECRET_KEY;

const User = require('./models/user');
const Quiz = require('./models/quiz');
app.use(express.json());
app.use(express.urlencoded({extended : true}));
app.use(cors({credentials : true}));
app.use(cookieParser());


const dbConnect = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('db connected');
    } catch (e) {
        console.log(e);
    }
}

dbConnect();

app.listen(port, () => {
    console.log(`Example app listening on port ${port}`)
})

// app.get('/', (req, res) => {
//     res.send('Hello World!');
// })

const authenticate = async (req, res, next) => {
    console.log("auth : " , req.cookies);
    const token = req.cookies?.accessToken;
    if (token) {
        jwt.verify(token, process.env.jWT_SECRET_KEY, (err, payload) => {
            if (err) {
                // res.status(403).json({ message: "Invalid Token" });
                next();
            } else {
                req.user = payload;
                next();
            }
        })
    } else {
        next();
    }
}

// 회원가입
app.post('/sign-up', async (req, res) => {
    console.log(await req.body);
    const pwdCheck = req.body.password.length >= 8;
    const idCheck = await User.findOne({userId : req.body.userId});

    if (idCheck) {
        res.status(409).json({success : false, message : "id exists"});
    } else if (!pwdCheck) {
        res.status(400).json({success : false, message : "pwd length"});
    } else {
        const hashedPwd = await bcrypt.hash(req.body.password, salt);
        User.create({userId : req.body.userId, password : hashedPwd});
        res.status(200).json({success : true, message : "succeed"});
    }
})

// 로그인
app.post('/sign-in', async (req, res) => {
    console.log(await req.body);
    const loginPwd = await req.body.password;
    const user = await User.findOne({userId : req.body.userId});

    if (user) {
        const checkPwd = await bcrypt.compare(loginPwd, user.password);
        if (checkPwd) {
            const payload = {
                userId : req.body.userId,
                role : "user"
            };

            const accessToken = jwt.sign(payload, jwtSecretKey, {expiresIn : '1h'});
            const refreshToken = jwt.sign(payload, jwtSecretKey, { expiresIn: '60d' });

            res.cookie("accessToken", accessToken, {
                httpOnly: true,  // JavaScript에서 접근 불가 (보안 강화)
                secure: false,    // HTTPS에서만 전송
                sameSite: "None"
              });
              
            res.cookie("refreshToken", refreshToken, {
                httpOnly: true,
                secure: false,
                sameSite: "None"
            });

            console.log('succeed');
            res.status(200).json({success : true, token : accessToken});
        } else {
            console.log('failed');
            res.status(401).json({success : false, message : "invalid pwd"});
        }
    } else {
        console.log('user not found');
        res.status(401).json({success : false, message : "user not found"});
    }
})

// accessToken 재생성
app.post('/refresh', (req, res) => {
    const refreshToken = req.cookies.refreshToken;

    if (!refreshToken) {
        res.status(401).json({message : "No refreshToken"});
    }

    jwt.verify(refreshToken, process.env.jWT_SECRET_KEY, (err, user) => {
        if (err) {
            res.status(403).json({message : "Invalid refreshToken"});
        }

        const newAccessToken = jwt.sign({userId : user.id, role : 'user'});
        res.cookie("accessToken", newAccessToken, {
            httpOnly: true,
            secure: true,
            sameSite: "Strict"
        });

        res.json({ message: "AccessToken refreshed" });
    })
})

// 퀴즈 목록 가져오기
app.post('/main', authenticate, async (req, res) => {
    
    // const current_Id = await req.user.userId;

    try {
        const findData = await Quiz.find({userId : "anonymous"});
        if (findData) {
            res.status(200).json({success : true, quiz : findData});
        } else {
            res.status(401).json({success : false, detail : "quiz not found"});
        }
        
    } catch (e) {
        res.status(500).json({success : false, details : e});
    }
})


// 퀴즈 저장
app.post('/write', authenticate, async (req, res) => {
    console.log("body : " , req.body);

    let randomCode = Math.random().toString(36).slice(2);
    let codeCheck = await Quiz.findOne({code : randomCode});

    while (codeCheck) {
        randomCode = Math.random().toString(36).slice(2);
        codeCheck = await Quiz.findOne({code : randomCode});
    }

    Quiz.create({userId : req.user? req.user.userId : "anonymous", quiz : req.body.quizList, code : randomCode});
    res.status(200).json({code : randomCode});
    
})

// 코드 입력 받기, 해당 문제 반환
app.post('/code', async (req, res) => {
    console.log(await req.body);
    const inputCode = await req.body.code;

    try {
        const findQuiz = await Quiz.findOne({code : inputCode});
        console.log(findQuiz.quiz);

        if (findQuiz) {
            res.status(200).json({success : true, quiz : findQuiz.quiz});
        } else {
            res.status(404).json({success : false, details : "Quiz not found"});
        }
    } catch (e) {
        return res.status(500).json({ success: false, details: e });
    }
})

// 문제 채점
app.post('/solve-quiz', authenticate, async (req, res) => {
    const inputCode = await req.body.code;
    const findQuiz = await Quiz.findOne({code : inputCode});
    
    const userAnswers = await req.body.userAnswers;

    console.log("findQuiz:", findQuiz);
    console.log("userAns:", userAnswers);
    // 맞은 개수
    let score = 0;
    
    // 각 문제를 맞았는지 / 틀렸는지
    let scoreDetails = [];

    console.log("findquizlength:", findQuiz.quiz.length);

    for (let i=0; i< findQuiz.quiz.length; i++) {
        if (findQuiz.quiz[i].answer == userAnswers[i]) {
            scoreDetails.push({
                number : i,
                isCorrect : true,
            });
            score += 1;
        } else {
            scoreDetails.push({
                number : i,
                isCorrect : false,
            });
        }
        console.log(i);
        console.log(score);
    }

    console.log("score :", score);
    console.log("scoreDetails:", scoreDetails);

    // 퀴즈 데이터에 각 학생의 점수 저장
    Quiz.findOneAndUpdate(
        {code : inputCode},
        {$push : {result : {
            userId : "anonymous",
            score : score,
            scoreDetails : scoreDetails,
        }}},
    );

    // 점수, 각 문제에 대한 채점 결과 반환
    res.status(200).json({score : score, scoreDetails : scoreDetails});
})