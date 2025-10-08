import { useState, useEffect, useRef } from 'react';
import { View, Text, Image, StatusBar, TouchableOpacity, Animated, ScrollView } from 'react-native';
import { useFonts, PixelifySans_400Regular } from '@expo-google-fonts/pixelify-sans';
import { useAegis } from '@cavos/aegis';
import * as Clipboard from 'expo-clipboard';
import { formatAddress } from '@/utils/utils';
import { router } from 'expo-router';
import { NFTData } from '../types/nft';
import { getImageUrl, fetchUserNFTs } from '../services/NFT.service';
import { useCharacter } from '../contexts/CharacterContext';

export default function NFTValidation() {
  const { aegisAccount } = useAegis();
  const { setSelectedCharacter } = useCharacter();
  const [addressCopied, setAddressCopied] = useState(false);
  const [isLoadingNFTs, setIsLoadingNFTs] = useState(true);
  const [nfts, setNfts] = useState<NFTData[]>([]);
  const [selectedNFT, setSelectedNFT] = useState<NFTData | null>(null);
  const [nftError, setNftError] = useState<string | null>(null);
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

    // Fetch NFTs when component mounts
    fetchNFTs();
  }, [floatAnim]);

  const fetchNFTs = () => {
    if (!aegisAccount.address) {
      setIsLoadingNFTs(false);
      return;
    }

    setIsLoadingNFTs(true);
    setNftError(null);

    fetchUserNFTs(aegisAccount.address)
      .then((userNFTs) => {
        setNfts(userNFTs);
        setIsLoadingNFTs(false);
        console.log('NFTs fetched successfully:', userNFTs.length);
      })
      .catch((error) => {
        console.error('Error fetching NFTs:', error);
        setNftError(error.message || 'Failed to fetch NFTs');
        setNfts([]);
        setIsLoadingNFTs(false);
      });
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
      // Save selected character to context
      setSelectedCharacter(selectedNFT);

      // Navigate to intro screen with character data
      router.push({
        pathname: '/onboarding/intro-complete',
        params: { characterId: selectedNFT.tokenId }
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
        <Animated.View
          style={{
            width: 200,
            height: 200,
            marginBottom: 40,
            transform: [{ translateY: floatAnim }],
          }}
        >
          <Image
            source={require('../assets/images/cassette.png')}
            style={{
              width: 200,
              height: 200,
            }}
            resizeMode="contain"
          />
        </Animated.View>

        {/* Loading Text */}
        <Text style={{
          fontSize: 18,
          color: '#FFFFFF',
          fontFamily: googleFontsLoaded ? 'PixelifySans_400Regular' : 'System',
          textAlign: 'center',
          marginBottom: 30,
          lineHeight: 24,
        }}>
          {nftError ? 'ERROR LOADING NFTS...' : 'CHECKING FOR CHARACTER NFTS...'}
        </Text>

        {/* Error message */}
        {nftError && (
          <Text style={{
            fontSize: 14,
            color: '#FF6B6B',
            fontFamily: googleFontsLoaded ? 'PixelifySans_400Regular' : 'System',
            textAlign: 'center',
            marginBottom: 20,
            paddingHorizontal: 20,
          }}>
            {nftError}
          </Text>
        )}

        {/* Retry button */}
        {nftError && (
          <TouchableOpacity
            onPress={fetchNFTs}
            style={{
              backgroundColor: '#D301F2',
              paddingHorizontal: 20,
              paddingVertical: 10,
              borderRadius: 8,
              marginTop: 10,
            }}
          >
            <Text style={{
              fontSize: 14,
              color: '#FFFFFF',
              fontFamily: googleFontsLoaded ? 'PixelifySans_400Regular' : 'System',
              fontWeight: 'bold',
            }}>
              RETRY
            </Text>
          </TouchableOpacity>
        )}

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
        <Animated.View
          style={{
            width: 200,
            height: 200,
            marginBottom: 40,
            transform: [{ translateY: floatAnim }],
          }}
        >
          <Image
            source={require('../assets/images/cassette.png')}
            style={{
              width: 200,
              height: 200,
            }}
            resizeMode="contain"
          />
        </Animated.View>

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
          {nfts.map((nft: NFTData) => (
            <TouchableOpacity
              key={nft.tokenId}
              onPress={() => setSelectedNFT(nft)}
              style={{
                width: 150,
                height: 150,
                borderRadius: 12,
                overflow: 'hidden',
                borderWidth: selectedNFT?.tokenId === nft.tokenId ? 3 : 2,
                borderColor: selectedNFT?.tokenId === nft.tokenId ? '#D301F2' : 'rgba(255, 255, 255, 0.3)',
                backgroundColor: 'rgba(255, 255, 255, 0.1)',
              }}
            >
              <Image
                source={{ uri: getImageUrl(nft.image) }}
                style={{
                  width: '100%',
                  height: '100%',
                }}
                resizeMode="cover"
                onError={(error: any) => {
                  console.error('Error loading NFT image:', error);
                }}
              />
              {selectedNFT?.tokenId === nft.tokenId && (
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