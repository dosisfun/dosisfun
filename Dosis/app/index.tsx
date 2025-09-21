import React, { useEffect, useState } from 'react';
import { View, Text, Image, Dimensions, StatusBar, TouchableOpacity, Alert } from 'react-native';
import { router } from 'expo-router';
import { useAegis } from '@cavos/aegis';
import { getPrivateKey, storePrivateKey } from '../utils/secureStorage';
import * as Font from 'expo-font';
import * as Clipboard from 'expo-clipboard';

const { width, height } = Dimensions.get('window');

export default function Index() {
  const { deployWallet, connectWallet, aegisAccount } = useAegis();
  const [fontsLoaded, setFontsLoaded] = useState(false);
  const [progress, setProgress] = useState(0);
  const [addressCopied, setAddressCopied] = useState(false);
  const [walletAddress, setWalletAddress] = useState('0x06S...oF2');
  const [isLoading, setIsLoading] = useState(true);

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
        'PixelifySans-Regular': require('../assets/fonts/PixelifySans-Regular.ttf'),
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
      setWalletAddress(aegisAccount.address || '0x06S...oF2');

      setTimeout(() => {
        setIsLoading(false);
        // router.replace('/nft-validation');
      }, 4000);

    } catch (error) {
      console.error('Wallet connection error:', error);
      setTimeout(() => {
        setIsLoading(false);
        // router.replace('/nft-validation');
      }, 4000);
    }
  };

  const copyAddressToClipboard = async () => {
    try {
      await Clipboard.setStringAsync(walletAddress);
      setAddressCopied(true);
      setTimeout(() => {
        setAddressCopied(false);
      }, 2000);
    } catch (error) {
      console.error('Error copying to clipboard:', error);
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

  return (
    <View style={{
      flex: 1,
      backgroundColor: '#000000',
      justifyContent: 'center',
      alignItems: 'center',
      paddingHorizontal: 40,
    }}>
      <StatusBar hidden />

      {/* Cassette Image */}
      <Image
        source={require('../assets/images/cassette.png')}
        style={{
          width: 200,
          height: 200,
          marginBottom: 40,
        }}
        resizeMode="contain"
      />

      {/* Main Text */}
      <Text style={{
        fontSize: 18,
        color: '#FFFFFF',
        fontFamily: fontsLoaded ? 'PixelifySans-Regular' : 'System',
        textAlign: 'center',
        marginBottom: 30,
        lineHeight: 24,
      }}>
        SEND A CHARACTER NFT HERE TO CONTINUE...
      </Text>

      {/* Address with Copy Button */}
      <TouchableOpacity
        onPress={copyAddressToClipboard}
        style={{
          flexDirection: 'row',
          alignItems: 'center',
          backgroundColor: 'rgba(255, 255, 255, 0.1)',
          paddingHorizontal: 20,
          paddingVertical: 12,
          borderRadius: 8,
        }}
      >
        <Text style={{
          fontSize: 16,
          color: '#D301F2',
          fontFamily: fontsLoaded ? 'PixelifySans-Regular' : 'System',
          marginRight: 10,
        }}>
          {walletAddress}
        </Text>
        <Text style={{
          fontSize: 16,
          color: '#D301F2',
          fontFamily: fontsLoaded ? 'PixelifySans-Regular' : 'System',
        }}>
          ⧉
        </Text>
      </TouchableOpacity>

      {/* Copy Notification */}
      {addressCopied && (
        <View style={{
          position: 'absolute',
          top: '45%',
          left: '50%',
          transform: [{ translateX: -152 }, { translateY: -14 }],
          backgroundColor: '#1F1F1F',
          paddingHorizontal: 20,
          paddingVertical: 6,
          borderRadius: 8,
          width: 305,
          height: 28,
        }}>
          <Text style={{
            fontSize: 12,
            color: '#FFFFFF',
            fontFamily: fontsLoaded ? 'PixelifySans-Regular' : 'System',
            textAlign: 'center',
            lineHeight: 16,
          }}>
            ADDRESS COPIED TO CLIPBOARD
          </Text>
        </View>
      )}

      {/* Footer Text */}
      <View style={{
        position: 'absolute',
        bottom: 20,
        flexDirection: 'row',
        alignItems: 'center',
      }}>
        <Text style={{
          fontSize: 12,
          color: 'rgba(255, 255, 255, 0.6)',
          fontFamily: fontsLoaded ? 'PixelifySans-Regular' : 'System',
        }}>
          dosis.fun [mobile] / no nft found / copy
        </Text>
      </View>
    </View>
  );
}
