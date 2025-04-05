const { createClient } = require('redis');

const redisClient = createClient(); 

redisClient.on('error', (err) => console.error('Redis Client Error', err));

(async () => {
  await redisClient.connect(); // 연결
  console.log('Connected to Redis');
})();

module.exports = redisClient;