const { createClient } = require('redis');
require('dotenv').config();

const client = createClient({
    username: process.env.REDIS_USERNAME,
    password: process.env.REDIS_PASSWORD,
    socket: {
        host: process.env.REDIS_HOST,
        port: process.env.REDIS_PORT
    }
});

client.on('error', (err) => console.error('Redis Client Error', err));

(async () => {
  let connected = false;
  while (!connected) {
    try {
      await client.connect();
      console.log('Connected to Redis');
      connected = true;
    } catch (err) {
      console.log('Waiting for Redis to be ready...');
      await new Promise(res => setTimeout(res, 1000));
    }
  }
})();

module.exports = client;