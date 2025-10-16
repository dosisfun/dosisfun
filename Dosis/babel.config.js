module.exports = function (api) {
  api.cache(true);
  return {
    presets: ['babel-preset-expo'],
    plugins: [
      // Ensure environment variables are properly handled
      ['transform-inline-environment-variables', {
        include: ['EXPO_PUBLIC_*']
      }]
    ],
  };
};
