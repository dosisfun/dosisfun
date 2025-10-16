import React, { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, StyleSheet, Alert, ActivityIndicator, ScrollView } from 'react-native';
import { useFonts, PixelifySans_400Regular } from '@expo-google-fonts/pixelify-sans';
import { router } from 'expo-router';
import { useBlackMarket } from '@/contexts/BlackMarketContext';
import { useCharacter } from '@/contexts/CharacterContext';

export default function ListDrugScreen() {
  const { listDrug, parsePrice } = useBlackMarket();
  const { selectedCharacter } = useCharacter();
  const [googleFontsLoaded] = useFonts({
    PixelifySans_400Regular,
  });

  const [drugId, setDrugId] = useState('');
  const [price, setPrice] = useState('');
  const [listing, setListing] = useState(false);

  const handleListDrug = async () => {
    if (!selectedCharacter) {
      Alert.alert('Error', 'No character selected');
      return;
    }

    if (!drugId.trim()) {
      Alert.alert('Error', 'Please enter a drug ID');
      return;
    }

    if (!price.trim()) {
      Alert.alert('Error', 'Please enter a price');
      return;
    }

    const drugIdNum = parseInt(drugId);
    if (isNaN(drugIdNum) || drugIdNum <= 0) {
      Alert.alert('Error', 'Please enter a valid drug ID');
      return;
    }

    setListing(true);
    try {
      const priceInWei = parsePrice(price);
      
      await listDrug({
        nft_token_id: selectedCharacter.tokenId,
        drug_id: drugIdNum,
        price: priceInWei
      });
      
      Alert.alert('Success', 'Drug listed successfully!');
      
      // Reset form
      setDrugId('');
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
          <Text style={styles.label}>Drug ID</Text>
          <TextInput
            style={styles.input}
            value={drugId}
            onChangeText={setDrugId}
            placeholder="Enter drug ID (e.g., 1, 2, 3...)"
            placeholderTextColor="#888888"
            keyboardType="numeric"
          />
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
          style={[styles.button, listing && styles.buttonDisabled]}
          onPress={handleListDrug}
          disabled={listing || !selectedCharacter}
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
});
