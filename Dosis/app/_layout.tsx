import { Stack } from "expo-router";
import { AegisProvider } from "@cavos/aegis"
import { StatusBar } from "expo-status-bar";
import { CharacterProvider } from "../contexts/CharacterContext";
import { BlackMarketProvider } from "../contexts/BlackMarketContext";
import { DrugCraftingProvider } from "../contexts/DrugCraftingContext";
import { AEGIS_CONFIG, NETWORK_CONFIG } from "../constants/contracts";

export default function RootLayout() {
  return (
    <AegisProvider
      config={{
        network: NETWORK_CONFIG.name,
        appName: AEGIS_CONFIG.appName,
        appId: AEGIS_CONFIG.appId,
        // Temporarily disable paymaster to avoid AVNU errors
        // paymasterApiKey: AEGIS_CONFIG.paymasterApiKey,
      }}
    >
      <CharacterProvider>
        <BlackMarketProvider>
          <DrugCraftingProvider>
            <StatusBar hidden/>
            <Stack>
              <Stack.Screen name="index" options={{ headerShown: false }} />
              <Stack.Screen name="nft-validation" options={{ headerShown: false }} />
              <Stack.Screen name="onboarding/intro-complete" options={{ headerShown: false }} />
              <Stack.Screen name="game-menu" options={{ headerShown: false }} />
              <Stack.Screen name="black-market" options={{ headerShown: false }} />
              <Stack.Screen name="list-drug" options={{ headerShown: false }} />
              <Stack.Screen name="buy-ingredient" options={{ headerShown: false }} />
              <Stack.Screen name="drug-crafting" options={{ headerShown: false }} />
              <Stack.Screen name="wallet" options={{ headerShown: false }} />
            </Stack>
          </DrugCraftingProvider>
        </BlackMarketProvider>
      </CharacterProvider>
    </AegisProvider>
  );
}
