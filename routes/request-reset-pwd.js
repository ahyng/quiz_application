// const express = require('express');
// const sendEmail = require('./send-email');
// const router = express.Router();
// const redisClient = require('./redis-client');

// router.post('/', async (req, res) => {
    
//     try {
//         if (req.body.email) {
//             const send = await sendEmail(req.body.email);
//             await redisClient.setEx(`otp:${req.body.email}`, 180, String(send.otp));
//             return res.status(200).json({success : true});
//         } else {
//             return res.status(400).json({success : false});
//         }
//     } catch (e) {
//         return res.status(500).json({message : e});
//     }

    
// })

// module.exports = router;