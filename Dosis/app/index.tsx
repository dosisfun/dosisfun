import React, { useEffect, useState } from 'react';
import { View, Text, Image, Dimensions, StatusBar } from 'react-native';
import { router } from 'expo-router';
import { useAegis } from '@cavos/aegis';
import { getPrivateKey, storePrivateKey } from '../utils/secureStorage';
import * as Font from 'expo-font';

const { width, height } = Dimensions.get('window');

export default function Index() {
  const { deployWallet, connectWallet, aegisAccount } = useAegis();
  const [fontsLoaded, setFontsLoaded] = useState(false);
  const [progress, setProgress] = useState(0);

  useEffect(() => {
    loadFonts();
  }, []);

  useEffect(() => {
    if (fontsLoaded) {
      startWalletConnection();
    }
  }, [fontsLoaded]);

  const loadFonts = async () => {
    try {
      await Font.loadAsync({
        'RamaGothicBold': require('../assets/fonts/ramagothicbold.ttf'),
      });
      setFontsLoaded(true);
    } catch (error) {
      console.error('Error loading fonts:', error);
      setFontsLoaded(true);
    }
  };

  const startWalletConnection = async () => {
    try {
      // Start progress animation
      const progressInterval = setInterval(() => {
        setProgress(prev => {
          if (prev >= 100) {
            clearInterval(progressInterval);
            return 100;
          }
          return prev + 2.5;
        });
      }, 100);

      const storedPrivateKey = await getPrivateKey();

      if (storedPrivateKey) {
        await connectWallet(storedPrivateKey);
      } else {
        const newPrivateKey = await deployWallet();
        if (newPrivateKey) {
          await storePrivateKey(newPrivateKey);
          console.log('New private key stored securely');
        }
      }

      console.log(aegisAccount.address);

      setTimeout(() => {
        // router.replace('/nft-validation');
      }, 4000);

    } catch (error) {
      console.error('Wallet connection error:', error);
      setTimeout(() => {
        // router.replace('/nft-validation');
      }, 4000);
    }
  };

  return (
    <View style={{
      flex: 1,
      backgroundColor: '#000000',
      justifyContent: 'center',
      alignItems: 'center',
      paddingHorizontal: 40,
    }}>
      <StatusBar hidden />

      {/* Title */}
      <Text style={{
        fontSize: 48,
        color: '#D301F2',
        fontFamily: fontsLoaded ? 'RamaGothicBold' : 'System',
        fontWeight: 'bold',
        textAlign: 'center',
        marginBottom: 60,
        letterSpacing: 2,
      }}>
        DOSIS.FUN
      </Text>

      {/* Token Image */}
      <Image
        source={require('../assets/images/logo.png')}
        style={{
          width: 120,
          height: 120,
          marginBottom: 40,
        }}
        resizeMode="contain"
      />

      {/* Progress Bar */}
      <View style={{
        width: width * 0.7,
        height: 8,
        backgroundColor: '#333333',
        borderRadius: 4,
        marginBottom: 20,
        overflow: 'hidden',
      }}>
        <View style={{
          width: `${progress}%`,
          height: '100%',
          backgroundColor: '#D301F2',
          borderRadius: 4,
        }} />
      </View>

      {/* Loading Text */}
      <View style={{
        flexDirection: 'row',
        alignItems: 'center',
      }}>
        <Image
          source={require('../assets/images/token.png')}
          style={{
            width: 24,
            height: 24,
            marginRight: 10,
          }}
          resizeMode="contain"
        />
        <Text style={{
          fontSize: 18,
          color: '#D301F2',
          fontFamily: 'System',
          textAlign: 'center',
        }}>
          loading...
        </Text>
      </View>
    </View>
  );
}
