import { Text, View, Alert } from "react-native";
import { Button } from "@react-navigation/elements";
import { useState } from "react";
import { useAegis } from "@cavos/aegis"
import { router } from "expo-router";

export default function WalletPage() {
  const { aegisAccount, isConnected, currentAddress, error } = useAegis();
  const [isExecuting, setIsExecuting] = useState(false);
  const [balance, setBalance] = useState<string | null>(null);

  const getBalance = async () => {
    if (!isConnected) {
      Alert.alert("Error", "No wallet connected");
      return;
    }

    try {
      setIsExecuting(true);
      // Example: Get ETH balance
      const ethBalance = await aegisAccount.getTokenBalance('0x4718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d');
      setBalance(ethBalance);
    } catch (error) {
      Alert.alert("Error", "Failed to get balance");
    } finally {
      setIsExecuting(false);
    }
  };

  const executeTestTransaction = async () => {
    if (!isConnected) {
      Alert.alert("Error", "No wallet connected");
      return;
    }

    try {
      setIsExecuting(true);

      // Example transaction - calling a simple contract method
      // This is just an example - replace with your actual contract calls
      // The SDK automatically uses the connected private key from context
      // You don't need to pass it again or retrieve it from storage!

      Alert.alert("Success", "This is where you'd execute a real transaction using the SDK");

    } catch (error) {
      Alert.alert("Error", "Transaction failed");
    } finally {
      setIsExecuting(false);
    }
  };

  if (!isConnected) {
    return (
      <View style={{ flex: 1, justifyContent: "center", alignItems: "center", padding: 20 }}>
        <Text style={{ fontSize: 18, marginBottom: 20, textAlign: "center" }}>
          No wallet connected
        </Text>
        <Button
          variant="filled"
          color="#007AFF"
          onPress={() => router.push("/")}
        >
          Go to Home
        </Button>
      </View>
    );
  }

  return (
    <View style={{ flex: 1, padding: 20 }}>
      <Text style={{ fontSize: 20, marginBottom: 20, textAlign: "center" }}>
        Wallet Operations
      </Text>

      {error && (
        <Text style={{ color: 'red', marginBottom: 10, textAlign: 'center' }}>
          {error}
        </Text>
      )}

      <View style={{ marginBottom: 20 }}>
        <Text style={{ fontWeight: 'bold' }}>Connected Address:</Text>
        <Text style={{ fontSize: 12, marginTop: 5 }}>{currentAddress}</Text>
      </View>

      {balance && (
        <View style={{ marginBottom: 20 }}>
          <Text style={{ fontWeight: 'bold' }}>ETH Balance:</Text>
          <Text style={{ marginTop: 5 }}>{balance} ETH</Text>
        </View>
      )}

      <Button
        variant="filled"
        color="#28a745"
        onPress={getBalance}
        disabled={isExecuting}
        style={{ marginVertical: 5 }}
      >
        {isExecuting ? "Loading..." : "Get ETH Balance"}
      </Button>

      <Button
        variant="filled"
        color="#ffc107"
        onPress={executeTestTransaction}
        disabled={isExecuting}
        style={{ marginVertical: 5 }}
      >
        {isExecuting ? "Executing..." : "Execute Test Transaction"}
      </Button>

      <Button
        variant="filled"
        color="#6c757d"
        onPress={() => router.push("/")}
        style={{ marginVertical: 5 }}
      >
        Back to Home
      </Button>

      <View style={{ marginTop: 30, padding: 15, backgroundColor: '#f8f9fa', borderRadius: 8 }}>
        <Text style={{ fontSize: 14, textAlign: 'center', color: '#6c757d' }}>
          💡 Notice: The SDK maintains your private key and connection state across all pages!
          You can navigate anywhere in the app and perform transactions without re-connecting.
        </Text>
      </View>
    </View>
  );
}