const jwt = require('jsonwebtoken');

const authenticate = async (req, res, next) => {
    console.log("auth : " , req.headers.cookies);
    const token = req.headers.cookies?.accessToken;
    console.log(req.headers);
    if (token) {
        jwt.verify(token, process.env.jWT_SECRET_KEY, (err, payload) => {
            if (err) {
                // res.status(403).json({ message: "Invalid Token" });
                next();
            } else {
                req.user = payload;
                next();
            }
        })
    } else {
        next();
    }
}

module.exports = authenticate;