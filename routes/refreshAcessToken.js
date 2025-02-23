const express = require('express');
const jwt = require('jsonwebtoken');
const client = require('./redis-client');

const router = express.Router();

// accessToken 재생성
router.post('/', async (req, res) => {
    const refreshToken = await client.get(`refresh:${req.body.userId}`);

    if (!refreshToken) {
        res.status(401).json({message : "No refreshToken"});
    }

    jwt.verify(refreshToken, process.env.jWT_SECRET_KEY, (err, user) => {
        if (err) {
            res.status(403).json({message : "Invalid refreshToken"});
        }

        const newAccessToken = jwt.sign({userId : user.id, role : 'user'});

        res.json({ accessToken : newAccessToken });
    })
})

module.exports = router;