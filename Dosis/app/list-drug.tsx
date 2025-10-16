import React, { useState, useEffect } from 'react';
import { View, Text, TextInput, TouchableOpacity, StyleSheet, Alert, ActivityIndicator, ScrollView } from 'react-native';
import { useFonts, PixelifySans_400Regular } from '@expo-google-fonts/pixelify-sans';
import { router } from 'expo-router';
import { useBlackMarket } from '@/contexts/BlackMarketContext';
import { useCharacter } from '@/contexts/CharacterContext';
import { useDrugCrafting } from '@/contexts/DrugCraftingContext';

export default function ListDrugScreen() {
  const { listDrug, parsePrice } = useBlackMarket();
  const { selectedCharacter } = useCharacter();
  const { state: craftingState, fetchPlayerDrugs, fetchDrugDetails } = useDrugCrafting();
  const [googleFontsLoaded] = useFonts({
    PixelifySans_400Regular,
  });

  const [selectedDrugId, setSelectedDrugId] = useState<number | null>(null);
  const [price, setPrice] = useState('');
  const [listing, setListing] = useState(false);
  const [loadingDrugs, setLoadingDrugs] = useState(false);

  // Load user's drugs when component mounts
  useEffect(() => {
    const loadUserDrugs = async () => {
      if (selectedCharacter) {
        setLoadingDrugs(true);
        try {
          await fetchPlayerDrugs(selectedCharacter.tokenId);
        } catch (error) {
          console.error('Error loading user drugs:', error);
        } finally {
          setLoadingDrugs(false);
        }
      }
    };

    loadUserDrugs();
  }, [selectedCharacter]);

  const handleListDrug = async () => {
    if (!selectedCharacter) {
      Alert.alert('Error', 'No character selected');
      return;
    }

    if (!selectedDrugId) {
      Alert.alert('Error', 'Please select a drug to list');
      return;
    }

    if (!price.trim()) {
      Alert.alert('Error', 'Please enter a price');
      return;
    }

    setListing(true);
    try {
      const priceInWei = parsePrice(price);
      
      await listDrug({
        nft_token_id: selectedCharacter.tokenId,
        drug_id: selectedDrugId,
        price: priceInWei
      });
      
      Alert.alert('Success', 'Drug listed successfully!');
      
      // Reset form
      setSelectedDrugId(null);
      setPrice('');
    } catch (error) {
      Alert.alert('Error', `Failed to list drug: ${error}`);
    } finally {
      setListing(false);
    }
  };

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity 
          style={styles.backButton}
          onPress={() => router.push('/game-menu')}
        >
          <Text style={styles.backButtonText}>← Back to Menu</Text>
        </TouchableOpacity>
        <Text style={styles.title}>List Drug</Text>
        <Text style={styles.subtitle}>Put your drugs on the market</Text>
      </View>

      <ScrollView style={styles.form}>
        <View style={styles.inputGroup}>
          <Text style={styles.label}>Select Drug to List</Text>
          {loadingDrugs ? (
            <View style={styles.loadingContainer}>
              <ActivityIndicator color="#FFFFFF" />
              <Text style={styles.loadingText}>Loading your drugs...</Text>
            </View>
          ) : craftingState.playerDrugs.length === 0 ? (
            <View style={styles.emptyContainer}>
              <Text style={styles.emptyText}>No drugs available to list</Text>
              <Text style={styles.emptySubtext}>Craft some drugs first!</Text>
            </View>
          ) : (
            <ScrollView style={styles.drugList} horizontal showsHorizontalScrollIndicator={false}>
              {craftingState.playerDrugs.map((drugId) => {
                const drugDetails = craftingState.drugDetails[drugId];
                return (
                  <TouchableOpacity
                    key={drugId}
                    style={[
                      styles.drugCard,
                      selectedDrugId === drugId && styles.drugCardSelected
                    ]}
                    onPress={() => {
                      setSelectedDrugId(drugId);
                      if (!drugDetails) {
                        fetchDrugDetails(drugId);
                      }
                    }}
                  >
                    <Text style={styles.drugId}>Drug #{drugId}</Text>
                    {drugDetails ? (
                      <>
                        <Text style={styles.drugName}>{drugDetails.name}</Text>
                        <Text style={styles.drugRarity}>Rarity: {drugDetails.rarity}</Text>
                        <Text style={styles.drugPurity}>Purity: {drugDetails.purity}%</Text>
                      </>
                    ) : (
                      <Text style={styles.drugLoading}>Loading details...</Text>
                    )}
                  </TouchableOpacity>
                );
              })}
            </ScrollView>
          )}
        </View>

        <View style={styles.inputGroup}>
          <Text style={styles.label}>Price (STRK)</Text>
          <TextInput
            style={styles.input}
            value={price}
            onChangeText={setPrice}
            placeholder="Enter price in STRK (e.g., 0.1)"
            placeholderTextColor="#888888"
            keyboardType="decimal-pad"
          />
        </View>

        <View style={styles.infoBox}>
          <Text style={styles.infoTitle}>Your NFT:</Text>
          <Text style={styles.infoText}>
            {selectedCharacter ? `Token ID: ${selectedCharacter.tokenId.slice(0, 12)}...` : 'No character selected'}
          </Text>
        </View>

        <TouchableOpacity
          style={[styles.button, (listing || !selectedDrugId) && styles.buttonDisabled]}
          onPress={handleListDrug}
          disabled={listing || !selectedCharacter || !selectedDrugId}
        >
          {listing ? (
            <ActivityIndicator color="#FFFFFF" />
          ) : (
            <Text style={styles.buttonText}>List Drug</Text>
          )}
        </TouchableOpacity>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#1a1a1a',
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
  form: {
    flex: 1,
    padding: 20,
  },
  inputGroup: {
    marginBottom: 20,
  },
  label: {
    fontSize: 16,
    color: '#FFFFFF',
    fontFamily: 'PixelifySans_400Regular',
    fontWeight: 'bold',
    marginBottom: 8,
  },
  input: {
    backgroundColor: '#2a2a2a',
    borderWidth: 2,
    borderColor: '#444',
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
    color: '#FFFFFF',
    fontFamily: 'PixelifySans_400Regular',
  },
  infoBox: {
    backgroundColor: '#2a2a2a',
    borderWidth: 2,
    borderColor: '#444',
    borderRadius: 8,
    padding: 15,
    marginBottom: 30,
  },
  infoTitle: {
    fontSize: 14,
    color: '#FFA500',
    fontFamily: 'PixelifySans_400Regular',
    fontWeight: 'bold',
    marginBottom: 5,
  },
  infoText: {
    fontSize: 14,
    color: '#CCCCCC',
    fontFamily: 'PixelifySans_400Regular',
  },
  button: {
    backgroundColor: '#00AA00',
    borderRadius: 8,
    padding: 15,
    alignItems: 'center',
  },
  buttonDisabled: {
    backgroundColor: '#666666',
  },
  buttonText: {
    color: '#FFFFFF',
    fontSize: 18,
    fontFamily: 'PixelifySans_400Regular',
    fontWeight: 'bold',
  },
  loadingContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 20,
  },
  loadingText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontFamily: 'PixelifySans_400Regular',
    marginLeft: 10,
  },
  emptyContainer: {
    backgroundColor: '#2a2a2a',
    borderWidth: 2,
    borderColor: '#444',
    borderRadius: 8,
    padding: 20,
    alignItems: 'center',
  },
  emptyText: {
    fontSize: 16,
    color: '#FFA500',
    fontFamily: 'PixelifySans_400Regular',
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 5,
  },
  emptySubtext: {
    fontSize: 14,
    color: '#CCCCCC',
    fontFamily: 'PixelifySans_400Regular',
    textAlign: 'center',
  },
  drugList: {
    maxHeight: 200,
  },
  drugCard: {
    backgroundColor: '#2a2a2a',
    borderWidth: 2,
    borderColor: '#444',
    borderRadius: 8,
    padding: 15,
    marginRight: 10,
    minWidth: 150,
    alignItems: 'center',
  },
  drugCardSelected: {
    borderColor: '#00AA00',
    backgroundColor: '#2a4a2a',
  },
  drugId: {
    fontSize: 16,
    color: '#FFFFFF',
    fontFamily: 'PixelifySans_400Regular',
    fontWeight: 'bold',
    marginBottom: 5,
  },
  drugName: {
    fontSize: 14,
    color: '#00AAFF',
    fontFamily: 'PixelifySans_400Regular',
    fontWeight: 'bold',
    marginBottom: 3,
  },
  drugRarity: {
    fontSize: 12,
    color: '#FFA500',
    fontFamily: 'PixelifySans_400Regular',
    marginBottom: 2,
  },
  drugPurity: {
    fontSize: 12,
    color: '#00FF00',
    fontFamily: 'PixelifySans_400Regular',
  },
  drugLoading: {
    fontSize: 12,
    color: '#888888',
    fontFamily: 'PixelifySans_400Regular',
    fontStyle: 'italic',
  },
});
