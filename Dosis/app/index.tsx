import React, { useEffect, useState } from 'react';
import { View, Text, Image, Dimensions, StatusBar, TouchableOpacity, Alert } from 'react-native';
import { router } from 'expo-router';
import { useAegis } from '@cavos/aegis';
import { getPrivateKey, storePrivateKey } from '../utils/secureStorage';
import * as Font from 'expo-font';
import { useFonts, PixelifySans_400Regular } from '@expo-google-fonts/pixelify-sans';
import * as Clipboard from 'expo-clipboard';
import { Asset } from 'expo-asset';

const { width, height } = Dimensions.get('window');

export default function Index() {
  const { deployWallet, connectWallet, aegisAccount } = useAegis();
  const [fontsLoaded, setFontsLoaded] = useState(false);
  const [assetsLoaded, setAssetsLoaded] = useState(false);
  const [progress, setProgress] = useState(0);
  const [addressCopied, setAddressCopied] = useState(false);
  const [walletAddress, setWalletAddress] = useState('0x06S...oF2');
  const [isLoading, setIsLoading] = useState(true);

  const [googleFontsLoaded] = useFonts({
    PixelifySans_400Regular,
  });

  useEffect(() => {
    loadFonts();
    preloadAssets();
  }, []);

  useEffect(() => {
    if (fontsLoaded && assetsLoaded) {
      startWalletConnection();
    }
  }, [fontsLoaded, assetsLoaded]);

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

  const preloadAssets = async () => {
    try {
      const imageAssets = [
        require('../assets/images/logo.png'),
        require('../assets/images/token.png'),
        require('../assets/images/cassette.png'),
      ];

      const cacheImages = imageAssets.map(image => {
        return Asset.fromModule(image).downloadAsync();
      });

      await Promise.all(cacheImages);
      setAssetsLoaded(true);
      console.log('All assets preloaded successfully');
    } catch (error) {
      console.error('Error preloading assets:', error);
      setAssetsLoaded(true); // Continue even if preloading fails
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
      setWalletAddress(aegisAccount.address || '0x06S...oF2');

      setTimeout(() => {
        setIsLoading(false);
        router.replace('/nft-validation');
      }, 4000);

    } catch (error) {
      console.error('Wallet connection error:', error);
      setTimeout(() => {
        setIsLoading(false);
        router.replace('/nft-validation');
      }, 4000);
    }
  };

  if (isLoading) {
    return (
      <View style={{
        flex: 1,
        backgroundColor: '#000000',
        justifyContent: 'center',
        alignItems: 'center',
        paddingHorizontal: 40,
      }}>
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
}
