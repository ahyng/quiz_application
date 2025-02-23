const express = require('express')
const client = require('./redis-client');

const router = express.Router();

router.post('/', async (req, res) => {
    try {
        await client.del(`refresh:${req.body.userId}`);
        console.log('logout succeed');
        res.status(200).json({success : true});
    } catch (e) {
        console.log(e);
        res.status(500).json({message : e});
    }
})
