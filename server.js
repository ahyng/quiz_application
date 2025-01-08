const express = require('express')
const mongoose = require('mongoose');
const bcrypt = require("bcrypt");
const cors = require('cors');


require("dotenv").config();

const app = express();
const port = 8080;
const salt = 10;

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

app.get('/', (req, res) => {
    res.send('Hello World!');
})


// 회원가입
app.post('/sign-up', async (req, res) => {
    console.log(await req.body);
    const hashedPwd = await bcrypt.hash(req.body.password, salt);

    const emailCheck = await User.findOne({email : req.body.email});

    if (emailCheck) {
        res.status(409).json({success : false, message : "email exists"});
    } else {
        User.create({email : req.body.email, password : hashedPwd});
        res.status(200).json({success : true, message : "succeed"});
    }
})

// 로그인
app.post('/sign-in', async (req, res) => {
    console.log(req.body);
    const loginPwd = await req.body.password;
    
    const user = await User.findOne({email : req.body.email});

    if (user) {
        const checkPwd = await bcrypt.compare(loginPwd, user.password);
        if (checkPwd) {
            console.log('succeed');
            res.status(200).json({success : true});
        } else {
            console.log('failed');
            res.status(401).json({success : false});
        }
    } else {
        console.log('user not found');
        res.status(401).json({success : false});
    }
})


// 퀴즈 저장
app.post('/write', async (req, res) => {
    console.log(req.body);
    const items = [];
    for(let i=0; i<req.body.items.length; i++) {
        const item = {key : req.body.items[i].key, question : req.body.items[i].question, answer : req.body.items[i].answer};
        items.push(item);
    }

    let randomCode = Math.random().toString(36).slice(2);
    let codeCheck = await Quiz.findOne({code : randomCode});

    while (codeCheck) {
        randomCode = Math.random().toString(36).slice(2);
        codeCheck = await Quiz.findOne({code : randomCode});
    }

    Quiz.create({email : req.body.email, quiz : items, code : randomCode});
    res.send('succeed');
})

// 코드 입력 받기
app.post('/code', async (req, res) => {
    console.log(req.body);
    const inputCode = req.body.code;
    const findQuiz = await Quiz.findOne({code : inputCode});

    console.log(findQuiz);
    res.send(findQuiz);
})
