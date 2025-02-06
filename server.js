const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const cookieParser = require('cookie-parser');

require("dotenv").config();

const app = express();
const port = 8080;

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

const signUpRoutes = require('./routes/sign-up');
const signInRoutes = require('./routes/sign-in');
const main = require('./routes/main');
const refreshAcessToken = require('./routes/refreshAcessToken');
const saveQuiz = require('./routes/save-quiz');
const findQuiz = require('./routes/find-quiz');
const evaluate = require('./routes/evaluate');
const deleteQuiz = require('./routes/delete-quiz');
const updateQuiz = require('./routes/update-quiz');

app.use('/sign-up', signUpRoutes);
app.use('/sign-in', signInRoutes);
app.use('/main', main);
app.use('/refresh', refreshAcessToken);
app.use('/write', saveQuiz);
app.use('/find-quiz', findQuiz);
app.use('/evaluate', evaluate);
app.use('/delete-quiz', deleteQuiz);
app.use('/update-quiz', updateQuiz);