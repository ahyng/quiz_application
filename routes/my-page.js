const express = require('express');
const authenticate = require('../middleware/auth');

const router = express.Router();

router.post('/', authenticate, async (req, res) => {

    console.log(req.headers);
    console.log('user: ', req.user);

    res.status(200).json({email : req.user.userId});
})

module.exports = router;