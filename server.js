const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const cookieParser = require('cookie-parser');
const redis = require('redis');

require("dotenv").config();

const app = express();
const port = 8080;
const client = redis.createClient();

app.use(express.json());
app.use(express.urlencoded({extended : true}));
app.use(cors({
    origin: '*',
    credentials: true, 
  }));
app.use(cookieParser());

const redisConnect = async () => {
    try {
        await client.connect();
        console.log('redis connected');
    } catch (e) {
        console.log(e);
    }
}

const dbConnect = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('db connected');
    } catch (e) {
        console.log(e);
    }
}

dbConnect();
redisConnect();

app.listen(port, () => {
    console.log(`Example app listening on port ${port}`)
})

// app.get('/', (req, res) => {
//     res.send('Hello World!');
// })

const authenticate = require('./middleware/auth');
const signUpRoutes = require('./routes/sign-up');
const signInRoutes = require('./routes/sign-in');
const main = require('./routes/main');
const refreshAcessToken = require('./routes/refreshAcessToken');
const saveQuiz = require('./routes/save-quiz');
const findQuiz = require('./routes/find-quiz');
const evaluate = require('./routes/evaluate');
const deleteQuiz = require('./routes/delete-quiz');
const updateQuiz = require('./routes/update-quiz');

app.use(authenticate);

app.use('/sign-up', signUpRoutes);
app.use('/sign-in', signInRoutes);
app.use('/main', main);
app.use('/refresh', refreshAcessToken);
app.use('/write', saveQuiz);
app.use('/find-quiz', findQuiz);
app.use('/evaluate', evaluate);
app.use('/delete-quiz', deleteQuiz);
app.use('/update-quiz', updateQuiz);