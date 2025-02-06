const express = require('express');
const jwt = require('jsonwebtoken');

const router = express.Router();

// accessToken 재생성
router.post('/', (req, res) => {
    const refreshToken = req.cookies.refreshToken;

    if (!refreshToken) {
        res.status(401).json({message : "No refreshToken"});
    }

    jwt.verify(refreshToken, process.env.jWT_SECRET_KEY, (err, user) => {
        if (err) {
            res.status(403).json({message : "Invalid refreshToken"});
        }

        const newAccessToken = jwt.sign({userId : user.id, role : 'user'});
        res.cookie("accessToken", newAccessToken, {
            httpOnly: true,
            secure: true,
            sameSite: "Strict"
        });

        res.json({ message: "AccessToken refreshed" });
    })
})

module.exports = router;