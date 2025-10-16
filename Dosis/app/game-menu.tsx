import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet, ScrollView } from 'react-native';
import { useFonts, PixelifySans_400Regular } from '@expo-google-fonts/pixelify-sans';
import { router } from 'expo-router';
import { useCharacter } from '@/contexts/CharacterContext';

export default function GameMenuScreen() {
  const { selectedCharacter } = useCharacter();
  const [googleFontsLoaded] = useFonts({
    PixelifySans_400Regular,
  });

  const menuItems = [
    {
      title: 'Black Market',
      subtitle: 'Buy and sell drugs',
      route: '/black-market',
      color: '#AA0000',
      icon: '💊'
    },
    {
      title: 'List Drug',
      subtitle: 'Put your drugs on sale',
      route: '/list-drug',
      color: '#00AA00',
      icon: '📝'
    },
    {
      title: 'Buy Ingredients',
      subtitle: 'Purchase crafting materials',
      route: '/buy-ingredient',
      color: '#0088FF',
      icon: '🧪'
    },
    {
      title: 'Drug Crafting',
      subtitle: 'Create and progress drugs',
      route: '/drug-crafting',
      color: '#AA00AA',
      icon: '⚗️'
    },
    {
      title: 'Wallet',
      subtitle: 'View your wallet',
      route: '/wallet',
      color: '#00AAFF',
      icon: '💰'
    },
  ];

  const handleMenuPress = (route: string) => {
    if (!selectedCharacter) {
      alert('Please select a character first');
      return;
    }
    router.push(route as any);
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Dosis Game</Text>
        <Text style={styles.subtitle}>Choose your action</Text>
      </View>

      {selectedCharacter ? (
        <View style={styles.characterInfo}>
          <Text style={styles.characterTitle}>Selected Character:</Text>
          <Text style={styles.characterText}>
            Token ID: {selectedCharacter.tokenId.slice(0, 12)}...
          </Text>
        </View>
      ) : (
        <View style={styles.noCharacterWarning}>
          <Text style={styles.warningText}>
            ⚠️ No character selected. Please select a character first.
          </Text>
        </View>
      )}

      <View style={styles.menuContainer}>
        {menuItems.map((item, index) => (
          <TouchableOpacity
            key={index}
            style={[styles.menuItem, { borderLeftColor: item.color }]}
            onPress={() => handleMenuPress(item.route)}
            disabled={!selectedCharacter}
          >
            <View style={styles.menuItemContent}>
              <Text style={styles.menuIcon}>{item.icon}</Text>
              <View style={styles.menuTextContainer}>
                <Text style={styles.menuTitle}>{item.title}</Text>
                <Text style={styles.menuSubtitle}>{item.subtitle}</Text>
              </View>
              <Text style={styles.menuArrow}>→</Text>
            </View>
          </TouchableOpacity>
        ))}
      </View>

      <View style={styles.footer}>
        <Text style={styles.footerText}>
          Built with Starknet & Aegis SDK
        </Text>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#1a1a1a',
  },
  header: {
    padding: 30,
    backgroundColor: '#2a2a2a',
    borderBottomWidth: 2,
    borderBottomColor: '#444',
    alignItems: 'center',
  },
  title: {
    fontSize: 32,
    color: '#FFFFFF',
    fontFamily: 'PixelifySans_400Regular',
    fontWeight: 'bold',
    textAlign: 'center',
  },
  subtitle: {
    fontSize: 18,
    color: '#CCCCCC',
    fontFamily: 'PixelifySans_400Regular',
    textAlign: 'center',
    marginTop: 5,
  },
  characterInfo: {
    backgroundColor: '#2a2a2a',
    margin: 20,
    padding: 15,
    borderRadius: 10,
    borderWidth: 2,
    borderColor: '#444',
  },
  characterTitle: {
    fontSize: 16,
    color: '#FFA500',
    fontFamily: 'PixelifySans_400Regular',
    fontWeight: 'bold',
    marginBottom: 5,
  },
  characterText: {
    fontSize: 14,
    color: '#CCCCCC',
    fontFamily: 'PixelifySans_400Regular',
  },
  noCharacterWarning: {
    backgroundColor: '#4a2a2a',
    margin: 20,
    padding: 15,
    borderRadius: 10,
    borderWidth: 2,
    borderColor: '#AA4444',
  },
  warningText: {
    fontSize: 16,
    color: '#FFAAAA',
    fontFamily: 'PixelifySans_400Regular',
    textAlign: 'center',
    fontWeight: 'bold',
  },
  menuContainer: {
    padding: 20,
  },
  menuItem: {
    backgroundColor: '#2a2a2a',
    borderRadius: 10,
    marginBottom: 15,
    borderLeftWidth: 5,
    borderWidth: 2,
    borderColor: '#444',
  },
  menuItemContent: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 20,
  },
  menuIcon: {
    fontSize: 24,
    marginRight: 15,
  },
  menuTextContainer: {
    flex: 1,
  },
  menuTitle: {
    fontSize: 20,
    color: '#FFFFFF',
    fontFamily: 'PixelifySans_400Regular',
    fontWeight: 'bold',
    marginBottom: 5,
  },
  menuSubtitle: {
    fontSize: 14,
    color: '#CCCCCC',
    fontFamily: 'PixelifySans_400Regular',
  },
  menuArrow: {
    fontSize: 20,
    color: '#888888',
    fontFamily: 'PixelifySans_400Regular',
  },
  footer: {
    padding: 20,
    alignItems: 'center',
  },
  footerText: {
    fontSize: 12,
    color: '#666666',
    fontFamily: 'PixelifySans_400Regular',
  },
});
