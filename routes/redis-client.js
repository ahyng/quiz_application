const redis = require('redis');

const client = redis.createClient({legacyMode: true , port: 6379 });
client.connect();

client.on('connect', () => {
    console.log('Connected to Redis');
});

client.on('error', (err) => {
    console.error('Redis connection error:', err);
});

module.exports = client;