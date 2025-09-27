import { Stack } from "expo-router";
import { AegisProvider } from "@cavos/aegis"
import { StatusBar } from "expo-status-bar";

export default function RootLayout() {
  return (
    <AegisProvider
      config={{
        network: 'SN_SEPOLIA',
        appName: 'dosisfun',
        appId: 'app-pwoeZT2RJ5SbVrz9yMdzp8sRXYkLrL6Z',
        paymasterApiKey: 'c37c52b7-ea5a-4426-8121-329a78354b0b',
      }}
    >
      <StatusBar hidden/>
      <Stack>
        <Stack.Screen name="index" options={{ headerShown: false }} />
        <Stack.Screen name="nft-validation" options={{ headerShown: false }} />
        <Stack.Screen name="onboarding/intro-complete" options={{ headerShown: false }} />
        <Stack.Screen name="wallet" options={{ headerShown: false }} />
      </Stack>
    </AegisProvider>
  );
}
