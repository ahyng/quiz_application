const express = require('express')
const mongoose = require('mongoose');
const bcrypt = require("bcrypt");
const cors = require('cors');
const jwt = require('jsonwebtoken');

require("dotenv").config();

const app = express();
const port = 8080;
const salt = 10;
const jwtSecretKey = process.env.jWT_SECRET_KEY;

const User = require('./models/user');
const Quiz = require('./models/quiz');
app.use(express.json());
app.use(cors());

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

const authenticate = (req, res, next) => {
    const token = req.cookies.accessToken;
    if (token) {
        jwt.verify(token, process.env.jWT_SECRET_KEY, (err, payload) => {
            if (err) {
                return res.status(403).json({ message: "Invalid Token" });
            } else {
                req.user = payload;
                next();
            }
        })
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
            const refreshToken = jwt.sign(payload, jwtSecretKey, { expiresIn: '7d' });

            res.cookie("accessToken", accessToken, {
                httpOnly: true,  // JavaScript에서 접근 불가 (보안 강화)
                secure: true,    // HTTPS에서만 전송
                sameSite: "Strict"
              });
              
            res.cookie("refreshToken", refreshToken, {
                httpOnly: true,
                secure: true,
                sameSite: "Strict"
            });

            console.log('succeed');
            res.status(200).json({success : true, token : token});
        } else {
            console.log('failed');
            res.status(401).json({success : false, message : "invalid pwd"});
        }
    } else {
        console.log('user not found');
        res.status(401).json({success : false, message : "user not found"});
    }
})

// 퀴즈 목록 가져오기
app.get('/main', authenticate, async (req, res) => {
    
    const current_Id = await req.user.userId;

    try {
        const findData = await Quiz.find({userId : current_Id})
        if (findData) {
            res.status(200).json({success : true, data : findData});
        } else {
            res.status(401).json({success : false, detail : "quiz not found"});
        }
        
    } catch (e) {
        res.status(500).json({success : false, details : e});
    }
})


// 퀴즈 저장
app.post('/write', authenticate, async (req, res) => {
    console.log(await req.body, req.user);

    // userId는 추후에 현재 로그인된 userId로 바꿀 예정
    Quiz.create({userId : req.user.userId, quiz : req.body.quiz, code : req.body.code});

    // 문제 하나씩 받는 코드
    // try {
    //     // 첫번째 문제에서는 퀴즈 생성
    //     if (req.body.number == 1) {
    //         let randomCode = Math.random().toString(36).slice(2);
    //         let codeCheck = await Quiz.findOne({code : randomCode});

    //         while (codeCheck) {
    //             randomCode = Math.random().toString(36).slice(2);
    //             codeCheck = await Quiz.findOne({code : randomCode});
    //         }

    //         await Quiz.create({userId : "anonymous", 
    //             quiz : [
    //                 {
    //                     number : req.body.number,
    //                     question : req.body.question,
    //                     answer : req.body.answer,
    //                     questionType : req.body.questionType,
    //                     options : req.body.options,
    //                 }
    //             ],
    //             code : randomCode,
    //         });
    //         res.status(200).json({success : true});
    //     } else {
    //         // 2번째 문제부터는 만든 퀴즈에 문제 추가
    //         const current_code = req.body.code;
    //         console.log(req.body);
    //         const updated = await Quiz.findOneAndUpdate(
    //             {code : current_code},
    //             {$push : {quiz : {
    //                 number : req.body.number,
    //                 question : req.body.question,
    //                 answer : req.body.answer,
    //                 questionType : req.body.questionType,
    //                 options : req.body.options,
    //             }}},
    //             { new : true }
    //         )
            
    //         if (updated) {
    //             res.status(200).json({success : true});
    //         } else {
    //             res.status(404).json({success : false});
    //         }
    //     }
    // } catch (e) {
    //     return res.status(500).json({ success: false, details: e });
    // }
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
    console.log(await req.body);
    const findQuiz = await Quiz.findOne({code : req.body.code}).quiz;

    // 맞은 개수
    let result = 0;
    for (let i=0; i<findQuiz.length; i++) {
        if (findQuiz[i].answer == req.body.quiz[i].answer) {
            result += 1;
        }
    }

    // 퀴즈 데이터에 각 학생의 점수 저장
    Quiz.findOneAndUpdate(
        {code : req.body.code},
        {$push : {result : {
            userId : req.user.userId,
            score : result,
        }}},
    );

    // 맞은 개수 반환
    res.status(200).json({result : result});
})