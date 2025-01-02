const express = require('express')
const mongoose = require('mongoose');
const bcrypt = require("bcrypt");
require("dotenv").config();

const app = express();
const port = 8080;
const salt = 10;

const User = require('./models/user');

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
    console.log(req.body);
    const hashedPwd = await bcrypt.hash(req.body.password, salt);

    User.create({userId : req.body.userId, password : hashedPwd});
})

// 로그인
app.post('/sign-in', (req, res) => {
    console.log(req.body);
    const loginPwd = req.body.password;
    
    const user = User.findOne({userId : req.body.uwerId});

    if (user) {
        const checkPwd = bcrypt.compare(user.password, loginPwd);
        if (checkPwd) {
            console.log('succeed');
        } else {
            console.log('failed');
        }
    } else {
        console.log('user not found');
    }
})

