const express = require('express');
const Quiz = require('../models/quiz');

const router = express.Router();

router.post("/", async (req, res) => {
    console.log(req.body);

    const quiz = await Quiz.findOne({code : req.body.code});

    if (quiz) {
        quiz.result.sort((a, b) => {
            console.log(a);
            console.log(b);
            if (b.score !== a.score) {
                return b.score - a.score;
            }
            return a.name.localeCompare(b.name);
        })

        let rank = 1;
        let prevScore = -1;
        let currentRank = 1;

        quiz.result.forEach((entry, index) => {
            if (prevScore !== entry.score) {
                rank = currentRank;
            }

            entry.rank = rank;
            prevScore = entry.score;
            currentRank++;
        })

        console.log("result:", quiz.result);
        res.status(200).json({ranking : quiz.result});
    }
})

module.exports = router;