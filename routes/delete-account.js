const express = require('express');
const User = require('../models/user');
const authenticate = require('../middleware/auth');

const router = express.Router();

router.post('/', authenticate, async (req, res) => {
    console.log(req.header);
    try {
        const result = await User.findOneAndDelete({ userId:  req.user.userId});
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