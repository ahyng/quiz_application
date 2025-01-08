const mongoose = require("mongoose");

const quizSchema = new mongoose.Schema(
    {
        email : {
            type : String,
            required : true,
        },
        quiz : [],
        code : {
            type : String,
            required : true,
        }
    }
);

const Quiz = mongoose.model("Quiz", quizSchema);
module.exports = Quiz;
