const { getDefaultConfig } = require('expo/metro-config');

const config = getDefaultConfig(__dirname);

// Ensure environment variables are properly resolved
config.resolver.platforms = ['ios', 'android', 'native', 'web'];

module.exports = config;
