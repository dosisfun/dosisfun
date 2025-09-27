import React, { useState, useEffect, useRef } from 'react';
import { View, Text, Image, StatusBar, TouchableOpacity, Animated, ScrollView } from 'react-native';
import { useFonts, PixelifySans_400Regular } from '@expo-google-fonts/pixelify-sans';
import { useAegis } from '@cavos/aegis';
import * as Clipboard from 'expo-clipboard';
import { formatAddress } from '@/utils/utils';
import { router } from 'expo-router';

// Mock NFT data
const mockNFTs = [
  { id: 1, name: 'Peter', image: require('../assets/images/p1.png') },
  { id: 4, name: 'Mariah', image: require('../assets/images/p4.png') },
  { id: 20, name: 'Will', image: require('../assets/images/p20.png') },
];

export default function NFTValidation() {
  const { aegisAccount } = useAegis();
  const [addressCopied, setAddressCopied] = useState(false);
  const [isLoadingNFTs, setIsLoadingNFTs] = useState(true);
  const [nfts, setNfts] = useState([]);
  const [selectedNFT, setSelectedNFT] = useState<any>(null);
  const floatAnim = useRef(new Animated.Value(0)).current;

  const [googleFontsLoaded] = useFonts({
    PixelifySans_400Regular,
  });

  useEffect(() => {
    const floatingAnimation = () => {
      Animated.sequence([
        Animated.timing(floatAnim, {
          toValue: -10,
          duration: 2000,
          useNativeDriver: true,
        }),
        Animated.timing(floatAnim, {
          toValue: 10,
          duration: 2000,
          useNativeDriver: true,
        }),
        Animated.timing(floatAnim, {
          toValue: 0,
          duration: 2000,
          useNativeDriver: true,
        }),
      ]).start(() => floatingAnimation());
    };

    floatingAnimation();

    // Simulate fetching NFTs
    fetchNFTs();
  }, [floatAnim]);

  const fetchNFTs = async () => {
    try {
      setIsLoadingNFTs(true);
      // Simulate API delay
      await new Promise(resolve => setTimeout(resolve, 2000));
      setNfts(mockNFTs as typeof nfts);
      setIsLoadingNFTs(false);
    } catch (error) {
      console.error('Error fetching NFTs:', error);
      setIsLoadingNFTs(false);
    }
  };

  const copyAddressToClipboard = async () => {
    try {
      await Clipboard.setStringAsync(formatAddress(aegisAccount.address || ""));
      setAddressCopied(true);
      setTimeout(() => {
        setAddressCopied(false);
      }, 2000);
    } catch (error) {
      console.error('Error copying to clipboard:', error);
    }
  };

  const handleContinueWithCharacter = () => {
    if (selectedNFT) {
      // Navigate to intro screen with character data
      router.push({
        pathname: '/onboarding/intro-complete',
        params: { characterId: selectedNFT.id.toString() }
      });
    }
  };

  if (isLoadingNFTs) {
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
        <Animated.Image
          source={require('../assets/images/cassette.png')}
          style={{
            width: 200,
            height: 200,
            marginBottom: 40,
            transform: [{ translateY: floatAnim }],
          }}
          resizeMode="contain"
        />

        {/* Loading Text */}
        <Text style={{
          fontSize: 18,
          color: '#FFFFFF',
          fontFamily: googleFontsLoaded ? 'PixelifySans_400Regular' : 'System',
          textAlign: 'center',
          marginBottom: 30,
          lineHeight: 24,
        }}>
          CHECKING FOR CHARACTER NFTS...
        </Text>

      </View>
    );
  }

  if (nfts.length === 0) {
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
        <Animated.Image
          source={require('../assets/images/cassette.png')}
          style={{
            width: 200,
            height: 200,
            marginBottom: 40,
            transform: [{ translateY: floatAnim }],
          }}
          resizeMode="contain"
        />

        {/* Main Text */}
        <Text style={{
          fontSize: 18,
          color: '#FFFFFF',
          fontFamily: googleFontsLoaded ? 'PixelifySans_400Regular' : 'System',
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
            fontFamily: googleFontsLoaded ? 'PixelifySans_400Regular' : 'System',
            marginRight: 10,
          }}>
            {formatAddress(aegisAccount.address || "")}
          </Text>
          <Text style={{
            fontSize: 16,
            color: '#D301F2',
            fontFamily: googleFontsLoaded ? 'PixelifySans_400Regular' : 'System',
          }}>
            ⧉
          </Text>
        </TouchableOpacity>

        {/* Copy Notification */}
        {addressCopied && (
          <View style={{
            position: 'absolute',
            top: '50%',
            alignSelf: 'center',
            transform: [{ translateY: -14 }],
            backgroundColor: '#1F1F1F',
            paddingHorizontal: 20,
            paddingVertical: 6,
            borderRadius: 8,
            alignItems: 'center',
            justifyContent: 'center',
          }}>
            <Text style={{
              fontSize: 12,
              color: '#FFFFFF',
              fontFamily: googleFontsLoaded ? 'PixelifySans_400Regular' : 'System',
              textAlign: 'center',
            }}>
              ADDRESS COPIED TO CLIPBOARD
            </Text>
          </View>
        )}
      </View>
    );
  }

  return (
    <View style={{
      flex: 1,
      backgroundColor: '#000000',
      paddingHorizontal: 20,
    }}>
      {/* NFT Grid */}
      <ScrollView
        contentContainerStyle={{
          flexGrow: 1,
          justifyContent: 'center',
          alignItems: 'center',
          paddingBottom: 100,
        }}
        showsVerticalScrollIndicator={false}
      >
        <Text style={{
          fontSize: 24,
          color: '#D301F2',
          fontFamily: googleFontsLoaded ? 'PixelifySans_400Regular' : 'System',
          textAlign: 'center',
          marginBottom: 40,
          marginTop: 40,
        }}>
          SELECT YOUR CHARACTER
        </Text>
        <View style={{
          flexDirection: 'row',
          flexWrap: 'wrap',
          justifyContent: 'center',
          gap: 20,
        }}>
          {nfts.map((nft: any) => (
            <TouchableOpacity
              key={nft.id}
              onPress={() => setSelectedNFT(nft)}
              style={{
                width: 150,
                height: 150,
                borderRadius: 12,
                overflow: 'hidden',
                borderWidth: selectedNFT?.id === nft.id ? 3 : 2,
                borderColor: selectedNFT?.id === nft.id ? '#D301F2' : 'rgba(255, 255, 255, 0.3)',
                backgroundColor: 'rgba(255, 255, 255, 0.1)',
              }}
            >
              <Image
                source={nft.image}
                style={{
                  width: '100%',
                  height: '100%',
                }}
                resizeMode="cover"
              />
              {selectedNFT?.id === nft.id && (
                <View style={{
                  position: 'absolute',
                  top: 5,
                  right: 5,
                  backgroundColor: '#D301F2',
                  borderRadius: 10,
                  width: 20,
                  height: 20,
                  justifyContent: 'center',
                  alignItems: 'center',
                }}>
                  <Text style={{ color: '#FFFFFF', fontSize: 12, fontWeight: 'bold' }}>✓</Text>
                </View>
              )}
            </TouchableOpacity>
          ))}
        </View>

        {selectedNFT && (
          <View style={{
            marginTop: 40,
            alignItems: 'center',
          }}>
            <Text style={{
              fontSize: 16,
              color: '#FFFFFF',
              fontFamily: googleFontsLoaded ? 'PixelifySans_400Regular' : 'System',
              textAlign: 'center',
              marginBottom: 20,
            }}>
              Selected: {selectedNFT.name}
            </Text>
            <TouchableOpacity
              onPress={handleContinueWithCharacter}
              style={{
                backgroundColor: '#D301F2',
                paddingHorizontal: 30,
                paddingVertical: 15,
                borderRadius: 8,
              }}
            >
              <Text style={{
                fontSize: 16,
                color: '#FFFFFF',
                fontFamily: googleFontsLoaded ? 'PixelifySans_400Regular' : 'System',
                fontWeight: 'bold',
              }}>
                CONTINUE WITH {selectedNFT.name.toUpperCase()}
              </Text>
            </TouchableOpacity>
          </View>
        )}
      </ScrollView>

      {/* Copy Notification */}
      {addressCopied && (
        <View style={{
          position: 'absolute',
          top: '50%',
          alignSelf: 'center',
          transform: [{ translateY: -14 }],
          backgroundColor: '#1F1F1F',
          paddingHorizontal: 20,
          paddingVertical: 6,
          borderRadius: 8,
          alignItems: 'center',
          justifyContent: 'center',
        }}>
          <Text style={{
            fontSize: 12,
            color: '#FFFFFF',
            fontFamily: googleFontsLoaded ? 'PixelifySans_400Regular' : 'System',
            textAlign: 'center',
          }}>
            ADDRESS COPIED TO CLIPBOARD
          </Text>
        </View>
      )}

    </View>
  );
}