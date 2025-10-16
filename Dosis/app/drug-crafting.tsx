import React, { useState, useEffect } from 'react';
import { View, Text, TextInput, TouchableOpacity, StyleSheet, Alert, ActivityIndicator, ScrollView } from 'react-native';
import { useFonts, PixelifySans_400Regular } from '@expo-google-fonts/pixelify-sans';
import { router } from 'expo-router';
import { useDrugCrafting } from '@/contexts/DrugCraftingContext';
import { useCharacter } from '@/contexts/CharacterContext';
import { StartCraftingData } from '@/types/drug-crafting';
import { useAegis } from '@cavos/aegis';
import { getBalanceInStrk, formatBalance } from '@/utils/walletUtils';

export default function DrugCraftingScreen() {
  const { 
    state, 
    startCrafting, 
    progressCraft, 
    cancelCrafting, 
    fetchActiveSession, 
    getCraftingProgress,
    formatTime 
  } = useDrugCrafting();
  const { selectedCharacter } = useCharacter();
  const { aegisAccount } = useAegis();
  const [googleFontsLoaded] = useFonts({
    PixelifySans_400Regular,
  });

  // Start crafting form
  const [drugName, setDrugName] = useState('');
  const [baseIngredients, setBaseIngredients] = useState('');
  const [drugIngredientIds, setDrugIngredientIds] = useState('');
  const [starting, setStarting] = useState(false);

  // Progress crafting
  const [progressing, setProgressing] = useState(false);
  const [canceling, setCanceling] = useState(false);
  const [balance, setBalance] = useState<string>('0');
  const [loadingBalance, setLoadingBalance] = useState(false);

  useEffect(() => {
    if (selectedCharacter) {
      fetchActiveSession(selectedCharacter.tokenId);
    }
  }, [selectedCharacter]);

  // Load balance when the component is mounted
  useEffect(() => {
    const loadBalance = async () => {
      if (aegisAccount) {
        setLoadingBalance(true);
        try {
          const currentBalance = await getBalanceInStrk(aegisAccount);
          setBalance(currentBalance);
        } catch (error) {
          console.error('Error loading balance:', error);
          setBalance('0');
        } finally {
          setLoadingBalance(false);
        }
      }
    };

    loadBalance();
  }, [aegisAccount]);

  const handleStartCrafting = async () => {
    if (!selectedCharacter) {
      Alert.alert('Error', 'No character selected');
      return;
    }

    if (!drugName.trim()) {
      Alert.alert('Error', 'Please enter a drug name');
      return;
    }

    if (!baseIngredients.trim()) {
      Alert.alert('Error', 'Please enter base ingredients in format: "1,5 2,3 3,2"');
      return;
    }

    if (!drugIngredientIds.trim()) {
      Alert.alert('Error', 'Please enter drug ingredient IDs');
      return;
    }

    // Parse base ingredients (format: "1,5 2,3 3,2" for ingredient_id,quantity pairs)
    let baseIngredientsArray;
    try {
      baseIngredientsArray = baseIngredients.split(' ').map(pair => {
        const [id, quantity] = pair.split(',');
        
        // Validate that both id and quantity exist and are not empty
        if (!id || !quantity || id.trim() === '' || quantity.trim() === '') {
          throw new Error(`Invalid ingredient format: "${pair}". Expected format: "id,quantity"`);
        }
        
        return {
          ingredient_id: parseInt(id.trim()),
          quantity: parseInt(quantity.trim())
        };
      }).filter(item => !isNaN(item.ingredient_id) && !isNaN(item.quantity));
    } catch (error) {
      Alert.alert('Error', `Invalid base ingredients format: ${error.message}`);
      return;
    }

    // Parse drug ingredient IDs (format: "1,2,3,4")
    let drugIngredientIdsArray;
    try {
      drugIngredientIdsArray = drugIngredientIds.split(',').map(id => {
        const trimmedId = id.trim();
        if (!trimmedId) {
          throw new Error('Empty ingredient ID found');
        }
        const parsedId = parseInt(trimmedId);
        if (isNaN(parsedId)) {
          throw new Error(`Invalid ingredient ID: "${trimmedId}"`);
        }
        return parsedId;
      });
    } catch (error) {
      Alert.alert('Error', `Invalid drug ingredient IDs format: ${error.message}`);
      return;
    }

    // Validate that we have ingredients
    if (baseIngredientsArray.length === 0) {
      Alert.alert('Error', 'No valid base ingredients found. Please check the format.');
      return;
    }

    if (drugIngredientIdsArray.length === 0) {
      Alert.alert('Error', 'No valid drug ingredient IDs found. Please check the format.');
      return;
    }

    setStarting(true);
    try {
      const craftingData: StartCraftingData = {
        nft_token_id: selectedCharacter.tokenId,
        name: drugName,
        base_ingredients: baseIngredientsArray,
        drug_ingredient_ids: drugIngredientIdsArray
      };

      await startCrafting(craftingData);
      
      Alert.alert('Success', 'Crafting started successfully!');
      
      // Reset form
      setDrugName('');
      setBaseIngredients('');
      setDrugIngredientIds('');
      
      // Refresh active session
      await fetchActiveSession(selectedCharacter.tokenId);
    } catch (error) {
      Alert.alert('Error', `Failed to start crafting: ${error}`);
    } finally {
      setStarting(false);
    }
  };

  const handleProgressCraft = async () => {
    if (!selectedCharacter) return;

    // Check if there's an active session first
    if (!state.activeSession) {
      Alert.alert('No Active Session', 'You need to start a crafting session first.');
      return;
    }

    setProgressing(true);
    try {
      await progressCraft(selectedCharacter.tokenId);
      Alert.alert('Success', 'Crafting progressed!');
      
      // Refresh active session
      await fetchActiveSession(selectedCharacter.tokenId);
    } catch (error) {
      let errorMessage = 'Failed to progress craft. ';
      
      if (error.toString().includes('AVNU paymaster')) {
        errorMessage += 'This might be due to insufficient STRK balance for gas fees or network issues.';
      } else if (error.toString().includes('no active session')) {
        errorMessage += 'No active crafting session found.';
      } else {
        errorMessage += error.toString();
      }
      
      Alert.alert('Error', errorMessage);
    } finally {
      setProgressing(false);
    }
  };

  const handleCancelCrafting = async () => {
    if (!selectedCharacter) return;

    Alert.alert(
      'Cancel Crafting',
      'Are you sure you want to cancel the current crafting session?',
      [
        { text: 'No', style: 'cancel' },
        {
          text: 'Yes',
          style: 'destructive',
          onPress: async () => {
            setCanceling(true);
            try {
              await cancelCrafting(selectedCharacter.tokenId);
              Alert.alert('Success', 'Crafting cancelled!');
              
              // Refresh active session
              await fetchActiveSession(selectedCharacter.tokenId);
            } catch (error) {
              Alert.alert('Error', `Failed to cancel crafting: ${error}`);
            } finally {
              setCanceling(false);
            }
          }
        }
      ]
    );
  };

  const renderActiveSession = () => {
    if (!state.activeSession) return null;

    const progress = getCraftingProgress();
    if (!progress) return null;

    return (
      <View style={styles.sessionCard}>
        <Text style={styles.sessionTitle}>Active Crafting Session</Text>
        
        <View style={styles.sessionInfo}>
          <Text style={styles.sessionText}>Drug: {state.activeSession.drug_name}</Text>
          <Text style={styles.sessionText}>
            Progress: {progress.progress_percentage}% ({progress.session.steps_completed}/{progress.session.total_steps_required} steps)
          </Text>
          <Text style={styles.sessionText}>Time Elapsed: {formatTime(progress.time_elapsed)}</Text>
          {progress.estimated_time_remaining > 0 && (
            <Text style={styles.sessionText}>Estimated Remaining: {formatTime(progress.estimated_time_remaining)}</Text>
          )}
        </View>

        <View style={styles.progressBar}>
          <View 
            style={[
              styles.progressFill, 
              { width: `${progress.progress_percentage}%` }
            ]} 
          />
        </View>

        <View style={styles.sessionButtons}>
          {progress.next_step_available && (
            <TouchableOpacity
              style={[styles.button, styles.progressButton]}
              onPress={handleProgressCraft}
              disabled={progressing}
            >
              {progressing ? (
                <ActivityIndicator color="#FFFFFF" />
              ) : (
                <Text style={styles.buttonText}>Progress</Text>
              )}
            </TouchableOpacity>
          )}
          
          <TouchableOpacity
            style={[styles.button, styles.cancelButton]}
            onPress={handleCancelCrafting}
            disabled={canceling}
          >
            {canceling ? (
              <ActivityIndicator color="#FFFFFF" />
            ) : (
              <Text style={styles.buttonText}>Cancel</Text>
            )}
          </TouchableOpacity>
        </View>
      </View>
    );
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity 
          style={styles.backButton}
          onPress={() => router.push('/game-menu')}
        >
          <Text style={styles.backButtonText}>← Back to Menu</Text>
        </TouchableOpacity>
        <Text style={styles.title}>Drug Crafting</Text>
        <Text style={styles.subtitle}>Create and progress your drugs</Text>
      </View>

      {state.activeSession && state.activeSession.drug_name !== '0' ? (
        renderActiveSession()
      ) : (
        <View style={styles.form}>
          <Text style={styles.formTitle}>Start New Crafting Session</Text>
          
          <View style={styles.statusBox}>
            <Text style={styles.statusText}>
              ℹ️ No active crafting session found for your character.
            </Text>
          </View>

          <View style={styles.balanceBox}>
            <Text style={styles.balanceTitle}>Wallet Balance:</Text>
            <Text style={styles.balanceText}>
              {loadingBalance ? 'Loading...' : formatBalance(balance)}
            </Text>
            {parseFloat(balance) < 0.001 && (
              <Text style={styles.lowBalanceWarning}>
                ⚠️ Low balance! You need at least 0.001 STRK for transactions.
              </Text>
            )}
          </View>
          
          <View style={styles.inputGroup}>
            <Text style={styles.label}>Drug Name</Text>
            <TextInput
              style={styles.input}
              value={drugName}
              onChangeText={setDrugName}
              placeholder="Enter drug name (e.g., 'Cocaine')"
              placeholderTextColor="#888888"
            />
          </View>

          <View style={styles.inputGroup}>
            <Text style={styles.label}>Base Ingredients</Text>
            <TextInput
              style={styles.input}
              value={baseIngredients}
              onChangeText={setBaseIngredients}
              placeholder="Format: '1,5 2,3 3,2' (ingredient_id,quantity)"
              placeholderTextColor="#888888"
            />
          </View>

          <View style={styles.inputGroup}>
            <Text style={styles.label}>Drug Ingredient IDs</Text>
            <TextInput
              style={styles.input}
              value={drugIngredientIds}
              onChangeText={setDrugIngredientIds}
              placeholder="Format: '1,2,3,4' (comma-separated IDs)"
              placeholderTextColor="#888888"
            />
          </View>

          <View style={styles.infoBox}>
            <Text style={styles.infoTitle}>Your NFT:</Text>
            <Text style={styles.infoText}>
              {selectedCharacter ? `Token ID: ${selectedCharacter.tokenId.slice(0, 12)}...` : 'No character selected'}
            </Text>
          </View>

          <View style={styles.helpBox}>
            <Text style={styles.helpTitle}>Help:</Text>
            <Text style={styles.helpText}>• Base Ingredients: ingredient_id,quantity pairs separated by spaces</Text>
            <Text style={styles.helpText}>• Example: "1,5 2,3" means 5 of ingredient 1, 3 of ingredient 2</Text>
            <Text style={styles.helpText}>• Drug Ingredient IDs: comma-separated list of ingredient IDs</Text>
          </View>

          <TouchableOpacity
            style={[styles.button, styles.startButton, starting && styles.buttonDisabled]}
            onPress={handleStartCrafting}
            disabled={starting || !selectedCharacter}
          >
            {starting ? (
              <ActivityIndicator color="#FFFFFF" />
            ) : (
              <Text style={styles.buttonText}>Start Crafting</Text>
            )}
          </TouchableOpacity>
        </View>
      )}
    </ScrollView>
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
    padding: 20,
  },
  formTitle: {
    fontSize: 20,
    color: '#FFFFFF',
    fontFamily: 'PixelifySans_400Regular',
    fontWeight: 'bold',
    marginBottom: 20,
    textAlign: 'center',
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
  helpBox: {
    backgroundColor: '#2a2a2a',
    borderWidth: 2,
    borderColor: '#444',
    borderRadius: 8,
    padding: 15,
    marginBottom: 30,
  },
  helpTitle: {
    fontSize: 16,
    color: '#FFFFFF',
    fontFamily: 'PixelifySans_400Regular',
    fontWeight: 'bold',
    marginBottom: 10,
  },
  helpText: {
    fontSize: 14,
    color: '#CCCCCC',
    fontFamily: 'PixelifySans_400Regular',
    marginBottom: 5,
  },
  statusBox: {
    backgroundColor: '#2a2a2a',
    borderWidth: 2,
    borderColor: '#444',
    borderRadius: 8,
    padding: 15,
    marginBottom: 20,
  },
  statusText: {
    fontSize: 14,
    color: '#FFA500',
    fontFamily: 'PixelifySans_400Regular',
    textAlign: 'center',
  },
  balanceBox: {
    backgroundColor: '#2a2a2a',
    borderWidth: 2,
    borderColor: '#444',
    borderRadius: 8,
    padding: 15,
    marginBottom: 20,
  },
  balanceTitle: {
    fontSize: 16,
    color: '#FFFFFF',
    fontFamily: 'PixelifySans_400Regular',
    fontWeight: 'bold',
    marginBottom: 5,
  },
  balanceText: {
    fontSize: 18,
    color: '#00FF00',
    fontFamily: 'PixelifySans_400Regular',
    fontWeight: 'bold',
  },
  lowBalanceWarning: {
    fontSize: 12,
    color: '#FF6347',
    fontFamily: 'PixelifySans_400Regular',
    marginTop: 5,
    fontStyle: 'italic',
  },
  sessionCard: {
    backgroundColor: '#2a2a2a',
    borderWidth: 2,
    borderColor: '#444',
    borderRadius: 10,
    padding: 20,
    margin: 20,
  },
  sessionTitle: {
    fontSize: 20,
    color: '#FFFFFF',
    fontFamily: 'PixelifySans_400Regular',
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 15,
  },
  sessionInfo: {
    marginBottom: 15,
  },
  sessionText: {
    fontSize: 16,
    color: '#CCCCCC',
    fontFamily: 'PixelifySans_400Regular',
    marginBottom: 8,
  },
  progressBar: {
    height: 20,
    backgroundColor: '#444',
    borderRadius: 10,
    marginBottom: 20,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    backgroundColor: '#00AA00',
    borderRadius: 10,
  },
  sessionButtons: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  button: {
    paddingHorizontal: 20,
    paddingVertical: 12,
    borderRadius: 8,
    minWidth: 100,
    alignItems: 'center',
  },
  startButton: {
    backgroundColor: '#00AA00',
  },
  progressButton: {
    backgroundColor: '#0088FF',
  },
  cancelButton: {
    backgroundColor: '#AA0000',
  },
  buttonDisabled: {
    backgroundColor: '#666666',
  },
  buttonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontFamily: 'PixelifySans_400Regular',
    fontWeight: 'bold',
  },
});
