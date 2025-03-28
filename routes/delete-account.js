const express = require('express');
const User = require('../models/user');
const client = require('./redis-client');

const router = express.Router();

router.post('/', async (req, res) => {
    console.log(req.body);
    try {
        await client.del(`refresh:${req.body.userId}`);
        const result = await User.findOneAndDelete({ userId: req.body.userId });
        if (result) {
            console.log("delete-account succeed");
            res.status(200).json({succeed : true});
        } else {
            console.log("can't find account");
            res.status(404).json({succeed : false});
        }
    } catch (e) {
        console.log(e);
        res.status(500).json({message : e});
    }
})

module.exports = router;