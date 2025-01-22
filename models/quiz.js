const mongoose = require("mongoose");

const quizSchema = new mongoose.Schema(
    {
        email : {
            type : String,
            required : true,
        },
        quiz : [
            {
                number : {
                    type : Number,
                    required : true,
                },
                question : {
                    type : String,
                    required : true,
                },
                answer : {
                    type : String,
                    required : true,
                }
            }
        ],
        code : {
            type : String,
            required : true,
        }
    }
);

const Quiz = mongoose.model("Quiz", quizSchema);
module.exports = Quiz;
