// const express = require('express');
// const redisClient = require('./redis-client');
// const router = express.Router();

// // 회원가입
// router.post('/', async (req, res) => {
//     console.log(req.body);
//     const otp = req.body.otp;

//     try {
//         const savedOtp = await redisClient.get(`otp:${req.body.email}`);

//         console.log(otp, savedOtp);
//         if (String(otp) === savedOtp) {
//             return res.status(200).json({success : true});
//         } else {
//             return res.status(400).json({success : false});
//         }
//     } catch (e) {
//         console.log(e);
//         return res.status(500).json({message : e});
//     }
// })

// module.exports = router;