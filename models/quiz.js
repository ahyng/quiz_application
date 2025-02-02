const mongoose = require("mongoose");

const quizSchema = new mongoose.Schema(
    {
        userId : {
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
                },
                questionType : {
                    type : String,
                    required : true,
                }, 
                options : {
                    type : [String],
                    required : false,
                }
            }
        ],
        result : [
            {
                userId : {
                    type: String,
                    required : true,
                },
                score : {
                    type : number,
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
