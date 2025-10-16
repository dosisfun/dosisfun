import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { useFonts, PixelifySans_400Regular } from '@expo-google-fonts/pixelify-sans';
import { getContractStatus } from '../constants/contracts';

export default function ContractStatus() {
  const [googleFontsLoaded] = useFonts({
    PixelifySans_400Regular,
  });

  const contractStatus = getContractStatus();

  if (!googleFontsLoaded) {
    return null;
  }

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Contract Status</Text>
      <View style={styles.statusList}>
        <View style={styles.statusItem}>
          <Text style={styles.contractName}>NFT Contract:</Text>
          <Text style={[styles.status, contractStatus.nft ? styles.deployed : styles.notDeployed]}>
            {contractStatus.nft ? '✅ Deployed' : '❌ Not Deployed'}
          </Text>
        </View>
        
        <View style={styles.statusItem}>
          <Text style={styles.contractName}>Drug Crafting:</Text>
          <Text style={[styles.status, contractStatus.drugCrafting ? styles.deployed : styles.notDeployed]}>
            {contractStatus.drugCrafting ? '✅ Deployed' : '❌ Not Deployed'}
          </Text>
        </View>
        
        <View style={styles.statusItem}>
          <Text style={styles.contractName}>Black Market:</Text>
          <Text style={[styles.status, contractStatus.blackMarket ? styles.deployed : styles.notDeployed]}>
            {contractStatus.blackMarket ? '✅ Deployed' : '❌ Not Deployed'}
          </Text>
        </View>
        
        <View style={styles.statusItem}>
          <Text style={styles.contractName}>Recipe System:</Text>
          <Text style={[styles.status, contractStatus.recipeSystem ? styles.deployed : styles.notDeployed]}>
            {contractStatus.recipeSystem ? '✅ Deployed' : '❌ Not Deployed'}
          </Text>
        </View>
        
        <View style={styles.statusItem}>
          <Text style={styles.contractName}>Player Token:</Text>
          <Text style={[styles.status, contractStatus.playerToken ? styles.deployed : styles.notDeployed]}>
            {contractStatus.playerToken ? '✅ Deployed' : '❌ Not Deployed'}
          </Text>
        </View>
      </View>
      
      {!contractStatus.drugCrafting || !contractStatus.blackMarket ? (
        <View style={styles.warningContainer}>
          <Text style={styles.warningText}>
            ⚠️ Some contracts are not deployed yet.
          </Text>
          <Text style={styles.warningSubtext}>
            To deploy contracts, go to DosisContracts/ and run the deployment scripts.
          </Text>
          <Text style={styles.warningSubtext}>
            Then update the contract addresses in your .env file.
          </Text>
        </View>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#2a2a2a',
    borderRadius: 10,
    padding: 15,
    margin: 10,
    borderWidth: 2,
    borderColor: '#444',
  },
  title: {
    fontSize: 18,
    color: '#FFFFFF',
    fontFamily: 'PixelifySans_400Regular',
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 15,
  },
  statusList: {
    gap: 8,
  },
  statusItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  contractName: {
    fontSize: 14,
    color: '#CCCCCC',
    fontFamily: 'PixelifySans_400Regular',
  },
  status: {
    fontSize: 14,
    fontFamily: 'PixelifySans_400Regular',
    fontWeight: 'bold',
  },
  deployed: {
    color: '#00FF00',
  },
  notDeployed: {
    color: '#FF6347',
  },
  warningContainer: {
    marginTop: 15,
    padding: 10,
    backgroundColor: '#4a2a2a',
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#AA4444',
  },
  warningText: {
    fontSize: 12,
    color: '#FFAAAA',
    fontFamily: 'PixelifySans_400Regular',
    textAlign: 'center',
    marginBottom: 5,
  },
  warningSubtext: {
    fontSize: 10,
    color: '#FFAAAA',
    fontFamily: 'PixelifySans_400Regular',
    textAlign: 'center',
    marginBottom: 2,
    fontStyle: 'italic',
  },
});
