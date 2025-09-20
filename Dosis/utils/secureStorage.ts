import * as SecureStore from 'expo-secure-store';

const PRIVATE_KEY_STORAGE_KEY = 'user_private_key';

/**
 * Securely stores a private key using Expo SecureStore
 * @param privateKey - The private key to store
 * @returns Promise that resolves when the key is stored
 */
export async function storePrivateKey(privateKey: string): Promise<void> {
  try {
    await SecureStore.setItemAsync(PRIVATE_KEY_STORAGE_KEY, privateKey);
  } catch (error) {
    throw new Error(`Failed to store private key: ${error}`);
  }
}

/**
 * Retrieves the stored private key from Expo SecureStore
 * @returns Promise that resolves to the private key or null if not found
 */
export async function getPrivateKey(): Promise<string | null> {
  try {
    return await SecureStore.getItemAsync(PRIVATE_KEY_STORAGE_KEY);
  } catch (error) {
    throw new Error(`Failed to retrieve private key: ${error}`);
  }
}

/**
 * Removes the stored private key from Expo SecureStore
 * @returns Promise that resolves when the key is deleted
 */
export async function deletePrivateKey(): Promise<void> {
  try {
    await SecureStore.deleteItemAsync(PRIVATE_KEY_STORAGE_KEY);
  } catch (error) {
    throw new Error(`Failed to delete private key: ${error}`);
  }
}

/**
 * Checks if a private key is stored
 * @returns Promise that resolves to true if a private key exists, false otherwise
 */
export async function hasPrivateKey(): Promise<boolean> {
  try {
    const key = await SecureStore.getItemAsync(PRIVATE_KEY_STORAGE_KEY);
    return key !== null;
  } catch (error) {
    return false;
  }
}