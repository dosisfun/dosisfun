import React, { useState, useEffect } from 'react';
import { View, Text, ScrollView, TouchableOpacity, StyleSheet, Alert, ActivityIndicator } from 'react-native';
import { useFonts, PixelifySans_400Regular } from '@expo-google-fonts/pixelify-sans';
import { router } from 'expo-router';
import { useBlackMarket } from '@/contexts/BlackMarketContext';
import { useCharacter } from '@/contexts/CharacterContext';
import { MarketListing } from '@/types/black-market';

export default function BlackMarketScreen() {
  const { state, fetchListings, buyDrug, formatPrice, clearError } = useBlackMarket();
  const { selectedCharacter } = useCharacter();
  const [googleFontsLoaded] = useFonts({
    PixelifySans_400Regular,
  });

  const [selectedListing, setSelectedListing] = useState<MarketListing | null>(null);
  const [showBuyModal, setShowBuyModal] = useState(false);
  const [buying, setBuying] = useState(false);

  useEffect(() => {
    fetchListings();
  }, []);

  const handleBuyDrug = async (listing: MarketListing) => {
    if (!selectedCharacter) {
      Alert.alert('Error', 'No character selected');
      return;
    }

    setBuying(true);
    try {
      await buyDrug({
        buyer_nft_token_id: selectedCharacter.tokenId,
        listing_id: listing.id
      });
      
      Alert.alert('Success', 'Drug purchased successfully!');
      setShowBuyModal(false);
      setSelectedListing(null);
      
      // Refresh listings
      await fetchListings();
    } catch (error) {
      Alert.alert('Error', `Failed to buy drug: ${error}`);
    } finally {
      setBuying(false);
    }
  };

  const renderListingCard = (listing: MarketListing) => (
    <TouchableOpacity
      key={listing.id}
      style={styles.listingCard}
      onPress={() => {
        setSelectedListing(listing);
        setShowBuyModal(true);
      }}
    >
      <View style={styles.listingHeader}>
        <Text style={styles.drugId}>Drug #{listing.drug_id}</Text>
        <Text style={styles.price}>{formatPrice(listing.price)} STRK</Text>
      </View>
      
      <View style={styles.listingInfo}>
        <Text style={styles.sellerInfo}>Seller: {listing.seller_nft_token_id.slice(0, 8)}...</Text>
        <Text style={styles.status}>
          {listing.is_active ? 'Available' : 'Sold'}
        </Text>
      </View>
      
      <View style={styles.listingFooter}>
        <Text style={styles.timestamp}>
          Listed: {new Date(listing.listed_timestamp * 1000).toLocaleDateString()}
        </Text>
      </View>
    </TouchableOpacity>
  );

  const renderBuyModal = () => {
    if (!selectedListing) return null;

    return (
      <View style={styles.modalOverlay}>
        <View style={styles.modalContent}>
          <Text style={styles.modalTitle}>Buy Drug #{selectedListing.drug_id}</Text>
          
          <View style={styles.modalInfo}>
            <Text style={styles.modalText}>Price: {formatPrice(selectedListing.price)} STRK</Text>
            <Text style={styles.modalText}>Seller: {selectedListing.seller_nft_token_id.slice(0, 12)}...</Text>
            <Text style={styles.modalText}>Your NFT: {selectedCharacter?.tokenId.slice(0, 12)}...</Text>
          </View>
          
          <View style={styles.modalButtons}>
            <TouchableOpacity
              style={[styles.button, styles.cancelButton]}
              onPress={() => {
                setShowBuyModal(false);
                setSelectedListing(null);
              }}
            >
              <Text style={styles.buttonText}>Cancel</Text>
            </TouchableOpacity>
            
            <TouchableOpacity
              style={[styles.button, styles.buyButton]}
              onPress={() => handleBuyDrug(selectedListing)}
              disabled={buying}
            >
              {buying ? (
                <ActivityIndicator color="#FFFFFF" />
              ) : (
                <Text style={styles.buttonText}>Buy</Text>
              )}
            </TouchableOpacity>
          </View>
        </View>
      </View>
    );
  };

  if (state.loading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#FFFFFF" />
        <Text style={styles.loadingText}>Loading Black Market...</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity 
          style={styles.backButton}
          onPress={() => router.push('/game-menu')}
        >
          <Text style={styles.backButtonText}>← Back to Menu</Text>
        </TouchableOpacity>
        <Text style={styles.title}>Black Market</Text>
        <Text style={styles.subtitle}>Buy and sell drugs</Text>
      </View>

      <ScrollView style={styles.listingsContainer}>
        {state.listings.length === 0 ? (
          <View style={styles.emptyContainer}>
            <Text style={styles.emptyText}>No listings available</Text>
          </View>
        ) : (
          state.listings.map(renderListingCard)
        )}
      </ScrollView>

      {showBuyModal && renderBuyModal()}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#1a1a1a',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#1a1a1a',
  },
  loadingText: {
    color: '#FFFFFF',
    fontSize: 16,
    marginTop: 10,
    fontFamily: 'PixelifySans_400Regular',
  },
  header: {
    padding: 20,
    backgroundColor: '#2a2a2a',
    borderBottomWidth: 2,
    borderBottomColor: '#444',
  },
  backButton: {
    alignSelf: 'flex-start',
    marginBottom: 10,
  },
  backButtonText: {
    fontSize: 16,
    color: '#00AAFF',
    fontFamily: 'PixelifySans_400Regular',
    fontWeight: 'bold',
  },
  title: {
    fontSize: 24,
    color: '#FFFFFF',
    fontFamily: 'PixelifySans_400Regular',
    fontWeight: 'bold',
    textAlign: 'center',
  },
  subtitle: {
    fontSize: 16,
    color: '#CCCCCC',
    fontFamily: 'PixelifySans_400Regular',
    textAlign: 'center',
    marginTop: 5,
  },
  listingsContainer: {
    flex: 1,
    padding: 15,
  },
  listingCard: {
    backgroundColor: '#2a2a2a',
    borderRadius: 10,
    padding: 15,
    marginBottom: 15,
    borderWidth: 2,
    borderColor: '#444',
  },
  listingHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 10,
  },
  drugId: {
    fontSize: 18,
    color: '#FFFFFF',
    fontFamily: 'PixelifySans_400Regular',
    fontWeight: 'bold',
  },
  price: {
    fontSize: 16,
    color: '#00FF00',
    fontFamily: 'PixelifySans_400Regular',
    fontWeight: 'bold',
  },
  listingInfo: {
    marginBottom: 10,
  },
  sellerInfo: {
    fontSize: 14,
    color: '#CCCCCC',
    fontFamily: 'PixelifySans_400Regular',
  },
  status: {
    fontSize: 14,
    color: '#FFA500',
    fontFamily: 'PixelifySans_400Regular',
    fontWeight: 'bold',
  },
  listingFooter: {
    borderTopWidth: 1,
    borderTopColor: '#444',
    paddingTop: 10,
  },
  timestamp: {
    fontSize: 12,
    color: '#888888',
    fontFamily: 'PixelifySans_400Regular',
  },
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingTop: 100,
  },
  emptyText: {
    fontSize: 18,
    color: '#888888',
    fontFamily: 'PixelifySans_400Regular',
    textAlign: 'center',
  },
  modalOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: 'rgba(0, 0, 0, 0.8)',
    justifyContent: 'center',
    alignItems: 'center',
    zIndex: 1000,
  },
  modalContent: {
    backgroundColor: '#2a2a2a',
    borderRadius: 15,
    padding: 20,
    width: '90%',
    borderWidth: 2,
    borderColor: '#444',
  },
  modalTitle: {
    fontSize: 20,
    color: '#FFFFFF',
    fontFamily: 'PixelifySans_400Regular',
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 20,
  },
  modalInfo: {
    marginBottom: 20,
  },
  modalText: {
    fontSize: 16,
    color: '#CCCCCC',
    fontFamily: 'PixelifySans_400Regular',
    marginBottom: 10,
  },
  modalButtons: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  button: {
    paddingHorizontal: 20,
    paddingVertical: 10,
    borderRadius: 8,
    minWidth: 100,
    alignItems: 'center',
  },
  cancelButton: {
    backgroundColor: '#666666',
  },
  buyButton: {
    backgroundColor: '#00AA00',
  },
  buttonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontFamily: 'PixelifySans_400Regular',
    fontWeight: 'bold',
  },
});
