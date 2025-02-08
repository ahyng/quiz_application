const mongoose = require("mongoose");

const quizSchema = new mongoose.Schema(
    {
        userId : {
            type : String,
            required : true,
        },
        title : {
            type : String,
        },
        quiz : [
            {
                // number : {
                //     type : Number,
                //     required : true,
                // },
                question : {
                    type : String,
                    required : true,
                },
                answer : {
                    type : String,
                    required : true,
                },
                isMultipleChoice : {
                    type : Boolean,
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
                    type : Number,
                    required : true,
                },
                scoreDetails : {
                    type : [
                        {
                            number : {
                                type : Number,
                            },
                            isCorrect : {
                                type : Boolean,
                            }
                        }
                    ],
                    required : true,
                }
            }
        ],
        code : {
            type : String,
            required : true,
        },
    }
);

const Quiz = mongoose.model("Quiz", quizSchema);
module.exports = Quiz;
