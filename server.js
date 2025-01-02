const express = require('express')
const mongoose = require('mongoose');
const bcrypt = require("bcrypt");
require("dotenv").config();


const app = express();
const port = 8080;
const salt = 10;

const User = require('./models/user');
app.use(express.json());

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
    dbConnect();
})


// 회원가입
app.post('/sign-up', async (req, res) => {
    console.log(await req.body);
    const hashedPwd = await bcrypt.hash(req.body.password, salt);

    const idCheck = await User.findOne({userId : req.body.userId});

    // id 중복확인
    if (idCheck) {
        console.log('idCheck failed');
        res.json({idCheck : 'failed'});
    } else {
        User.create({userId : req.body.userId, password : hashedPwd});
        res.json({signUp : 'succeed'});
    }
    
})

// 로그인
app.post('/sign-in', async (req, res) => {
    console.log(req.body);
    const loginPwd = await req.body.password;
    
    const user = await User.findOne({userId : req.body.userId});

    if (user) {
        const checkPwd = await bcrypt.compare(loginPwd, user.password);
        if (checkPwd) {
            console.log('succeed');
            res.json({signIn : 'succeed'});
        } else {
            console.log('failed');
            res.json({signIn : 'failed'});
        }
    } else {
        console.log('user not found');
        res.json({signIn : 'user not found'});
    }
})

