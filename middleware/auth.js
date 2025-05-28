const jwt = require('jsonwebtoken');
require('dotenv').config(); 

const authenticate = (req, res, next) => {
    const accessAuth = req.headers.accesstoken;
    const refreshAuth = req.headers.refreshtoken;
    const accessToken = accessAuth && accessAuth.split(" ")[1];
    const refreshToken = refreshAuth && refreshAuth.split(" ")[1];

    console.log(req.headers);
    if (accessToken) {
        jwt.verify(accessToken, `${process.env.JWT_SECRET_KEY}`, async (err, payload) => {
            if (err) {
                try {
                    if (!refreshToken) {
                        return res.status(401).json({message : 'no refreshToken'});
                    }

                    jwt.verify(refreshToken, `${process.env.JWT_SECRET_KEY}`, (err, user) => {
                        if (err) {
                            console.error("Error verifying refresh token:", err);
                            return res.status(401).json({ message: 'Invalid refreshToken' });
                        }

                        // accessToken 발급    
                        const newAccessToken = jwt.sign({ userId: user.userId }, `${process.env.JWT_SECRET_KEY}`, { expiresIn: '1h' });
                        req.user = user;
                        res.locals.newAccessToken = newAccessToken;
                        next();
                        // return res.status(201).json({accessToken : newAccessToken});
                    });
                } catch(e) {
                    console.log(e);
                    return res.status(500).json({message : e});
                }
            } else {
                console.log('auth: succeed');
                req.user = payload;
                console.log('req.user:', req.user);
                next();
            }
        })
    } else {
        return res.status(401).json({message : 'Invalid or expired token'});
    }
}

module.exports = authenticate;