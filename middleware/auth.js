const jwt = require('jsonwebtoken');

const authenticate = async (req, res, next) => {
    console.log("auth : " , req.cookies); 
    const token = req.headers.accesstoken;
    console.log(token);

    console.log(req.headers);
    if (token) {
        jwt.verify(token, process.env.jWT_SECRET_KEY, (err, payload) => {
            if (err) {
                // res.status(403).json({ message: "Invalid Token" });
                console.log('err');
            } else {
                req.user = payload;
                console.log('req.user:', req.user);
                next();
            }
        })
    } else {
        next();
    }
}

module.exports = authenticate;