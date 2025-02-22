const jwt = require('jsonwebtoken');

const authenticate = async (req, res, next) => {
    const auth = req.headers.authorization;
    const token = auth && auth.split(" ")[1];

    console.log(req.headers);
    if (token) {
        jwt.verify(token, process.env.jWT_SECRET_KEY, (err, payload) => {
            if (err) {
                res.status(401).json({ message: "Invalid Token" });
                console.log('err');
            } else {
                req.user = payload;
                console.log('req.user:', req.user);
                next();
            }
        })
    } else {
        res.status(401).json({message : 'Invalid or expired token'});
    }
}

module.exports = authenticate;