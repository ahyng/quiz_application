const express = require('express')
const mongoose = require('mongoose');
require("dotenv").config();

const app = express();
const port = 8080;

mongoose.connect(process.env.MONGODB_URI)
.then(console.log('db connected'));

app.get('/', (req, res) => {
    res.send('Hello World!');
    dbConnect();
})
  
app.listen(port, () => {
    console.log(`Example app listening on port ${port}`)
})

