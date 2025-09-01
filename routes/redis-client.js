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
  let connected = false;
  while (!connected) {
    try {
      await redisClient.connect();
      console.log('Connected to Redis');
      connected = true;
    } catch (err) {
      console.log('Waiting for Redis to be ready...');
      await new Promise(res => setTimeout(res, 1000));
    }
  }
})();

module.exports = redisClient;