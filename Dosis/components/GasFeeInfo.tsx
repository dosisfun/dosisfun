import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { useFonts, PixelifySans_400Regular } from '@expo-google-fonts/pixelify-sans';

export default function GasFeeInfo() {
  const [googleFontsLoaded] = useFonts({
    PixelifySans_400Regular,
  });

  if (!googleFontsLoaded) {
    return null;
  }

  return (
    <View style={styles.container}>
      <Text style={styles.title}>💡 Gas Fee Information</Text>
      <Text style={styles.text}>
        • Transactions require STRK tokens for gas fees
      </Text>
      <Text style={styles.text}>
        • Ensure your wallet has sufficient STRK balance
      </Text>
      <Text style={styles.text}>
        • You can get testnet STRK from Starknet faucets
      </Text>
      <Text style={styles.text}>
        • If paymaster fails, transactions will use your STRK
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#2a2a2a',
    borderRadius: 10,
    padding: 15,
    margin: 10,
    borderWidth: 2,
    borderColor: '#444',
  },
  title: {
    fontSize: 14,
    color: '#FFFFFF',
    fontFamily: 'PixelifySans_400Regular',
    fontWeight: 'bold',
    marginBottom: 10,
  },
  text: {
    fontSize: 12,
    color: '#CCCCCC',
    fontFamily: 'PixelifySans_400Regular',
    marginBottom: 5,
  },
});
