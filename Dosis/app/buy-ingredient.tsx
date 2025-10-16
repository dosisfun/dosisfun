import React, { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, StyleSheet, Alert, ActivityIndicator, ScrollView } from 'react-native';
import { useFonts, PixelifySans_400Regular } from '@expo-google-fonts/pixelify-sans';
import { router } from 'expo-router';
import { useBlackMarket } from '@/contexts/BlackMarketContext';
import { useCharacter } from '@/contexts/CharacterContext';

export default function BuyIngredientScreen() {
  const { buyIngredient } = useBlackMarket();
  const { selectedCharacter } = useCharacter();
  const [googleFontsLoaded] = useFonts({
    PixelifySans_400Regular,
  });

  const [ingredientId, setIngredientId] = useState('');
  const [quantity, setQuantity] = useState('');
  const [buying, setBuying] = useState(false);

  const handleBuyIngredient = async () => {
    if (!selectedCharacter) {
      Alert.alert('Error', 'No character selected');
      return;
    }

    if (!ingredientId.trim()) {
      Alert.alert('Error', 'Please enter an ingredient ID');
      return;
    }

    if (!quantity.trim()) {
      Alert.alert('Error', 'Please enter a quantity');
      return;
    }

    const ingredientIdNum = parseInt(ingredientId);
    const quantityNum = parseInt(quantity);

    if (isNaN(ingredientIdNum) || ingredientIdNum <= 0) {
      Alert.alert('Error', 'Please enter a valid ingredient ID');
      return;
    }

    if (isNaN(quantityNum) || quantityNum <= 0) {
      Alert.alert('Error', 'Please enter a valid quantity');
      return;
    }

    setBuying(true);
    try {
      await buyIngredient({
        nft_token_id: selectedCharacter.tokenId,
        ingredient_id: ingredientIdNum,
        quantity: quantityNum
      });
      
      Alert.alert('Success', 'Ingredient purchased successfully!');
      
      // Reset form
      setIngredientId('');
      setQuantity('');
    } catch (error) {
      Alert.alert('Error', `Failed to buy ingredient: ${error}`);
    } finally {
      setBuying(false);
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
        <Text style={styles.title}>Buy Ingredient</Text>
        <Text style={styles.subtitle}>Purchase ingredients for crafting</Text>
      </View>

      <ScrollView style={styles.form}>
        <View style={styles.inputGroup}>
          <Text style={styles.label}>Ingredient ID</Text>
          <TextInput
            style={styles.input}
            value={ingredientId}
            onChangeText={setIngredientId}
            placeholder="Enter ingredient ID (e.g., 1, 2, 3...)"
            placeholderTextColor="#888888"
            keyboardType="numeric"
          />
        </View>

        <View style={styles.inputGroup}>
          <Text style={styles.label}>Quantity</Text>
          <TextInput
            style={styles.input}
            value={quantity}
            onChangeText={setQuantity}
            placeholder="Enter quantity (e.g., 5, 10, 20...)"
            placeholderTextColor="#888888"
            keyboardType="numeric"
          />
        </View>

        <View style={styles.infoBox}>
          <Text style={styles.infoTitle}>Your NFT:</Text>
          <Text style={styles.infoText}>
            {selectedCharacter ? `Token ID: ${selectedCharacter.tokenId.slice(0, 12)}...` : 'No character selected'}
          </Text>
        </View>

        <View style={styles.ingredientList}>
          <Text style={styles.ingredientTitle}>Available Ingredients:</Text>
          <Text style={styles.ingredientItem}>• ID 1: Ephedrine (Common)</Text>
          <Text style={styles.ingredientItem}>• ID 2: Coca Leaves (Rare)</Text>
          <Text style={styles.ingredientItem}>• ID 3: Pseudoephedrine (Common)</Text>
          <Text style={styles.ingredientItem}>• ID 4: Lime (Common)</Text>
          <Text style={styles.ingredientItem}>• ID 5: Opium (Epic)</Text>
          <Text style={styles.ingredientItem}>• ID 6: Acetic Anhydride (Rare)</Text>
        </View>

        <TouchableOpacity
          style={[styles.button, buying && styles.buttonDisabled]}
          onPress={handleBuyIngredient}
          disabled={buying || !selectedCharacter}
        >
          {buying ? (
            <ActivityIndicator color="#FFFFFF" />
          ) : (
            <Text style={styles.buttonText}>Buy Ingredient</Text>
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
    marginBottom: 20,
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
  ingredientList: {
    backgroundColor: '#2a2a2a',
    borderWidth: 2,
    borderColor: '#444',
    borderRadius: 8,
    padding: 15,
    marginBottom: 30,
  },
  ingredientTitle: {
    fontSize: 16,
    color: '#FFFFFF',
    fontFamily: 'PixelifySans_400Regular',
    fontWeight: 'bold',
    marginBottom: 10,
  },
  ingredientItem: {
    fontSize: 14,
    color: '#CCCCCC',
    fontFamily: 'PixelifySans_400Regular',
    marginBottom: 5,
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
