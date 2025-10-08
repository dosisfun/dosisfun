import { Stack } from "expo-router";
import { AegisProvider } from "@cavos/aegis"
import { StatusBar } from "expo-status-bar";
import { CharacterProvider } from "../contexts/CharacterContext";

export default function RootLayout() {
  return (
    <AegisProvider
      config={{
        network: (process.env.EXPO_PUBLIC_STARKNET_NETWORK as any) || '',
        appName: process.env.EXPO_PUBLIC_AEGIS_APP_NAME || '',
        appId: process.env.EXPO_PUBLIC_AEGIS_APP_ID || '',
      }}
    >
      <CharacterProvider>
        <StatusBar hidden/>
        <Stack>
          <Stack.Screen name="index" options={{ headerShown: false }} />
          <Stack.Screen name="nft-validation" options={{ headerShown: false }} />
          <Stack.Screen name="onboarding/intro-complete" options={{ headerShown: false }} />
          <Stack.Screen name="wallet" options={{ headerShown: false }} />
        </Stack>
      </CharacterProvider>
    </AegisProvider>
  );
}
