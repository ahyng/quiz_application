const express = require('express');
const authenticate = require('../middleware/auth');

const router = express.Router();

router.post('/', authenticate, async (req, res) => {
    try {
        if (!req.user || !req.user.userId) {
            return res.status(400).json({ error: '유저 정보가 없습니다.' });
        }
        res.status(200).json({ userId: req.user.userId });
    } catch (e) {
        res.status(500).json({ message : e });
    }
});

module.exports = router;
