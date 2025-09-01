const { createClient } = require('redis');
require('dotenv').config();

const redisClient = createClient(
  {
    host: "redis",        
    port: 6379,
    password: process.env.REDIS_PASSWORD
  }
); 

redisClient.on('error', (err) => console.error('Redis Client Error', err));

(async () => {
  await redisClient.connect(); // 연결
  console.log('Connected to Redis');
})();

module.exports = redisClient;