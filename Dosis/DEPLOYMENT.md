# Contract Deployment Guide

## Prerequisites

1. Make sure you have the Dojo CLI installed
2. Ensure you have a Starknet wallet with some STRK tokens for deployment
3. Have your private key or seed phrase ready

## Deployment Steps

### 1. Navigate to the Contracts Directory

```bash
cd DosisContracts/
```

### 2. Configure Your Environment

Create a `.env` file in the `DosisContracts/` directory with your private key:

```bash
# DosisContracts/.env
PRIVATE_KEY=your_private_key_here
```

### 3. Deploy to Sepolia Testnet

```bash
# Deploy all contracts
dojo build
dojo migrate --name sepolia
```

### 4. Get Contract Addresses

After deployment, you'll see output with contract addresses. Copy these addresses and update your `.env` file in the main Dosis directory:

```bash
# Update Dosis/.env with the deployed addresses
EXPO_PUBLIC_DRUG_CRAFTING_CONTRACT=0x_deployed_address_here
EXPO_PUBLIC_BLACK_MARKET_CONTRACT=0x_deployed_address_here
EXPO_PUBLIC_RECIPE_SYSTEM_CONTRACT=0x_deployed_address_here
EXPO_PUBLIC_PLAYER_TOKEN_CONTRACT=0x_deployed_address_here
```

### 5. Restart the Application

After updating the contract addresses, restart your Expo development server:

```bash
cd Dosis/
npx expo start --clear
```

## Contract Addresses

Once deployed, you should see contract addresses like:

- **Drug Crafting System**: `0x...`
- **Black Market System**: `0x...`
- **Recipe System**: `0x...`
- **Player Token System**: `0x...`

## Verification

After deployment, the Contract Status component in the app will show:
- ✅ Deployed for contracts that are successfully deployed
- ❌ Not Deployed for contracts that still need deployment

## Troubleshooting

### Common Issues

1. **"Contract not found" errors**: Make sure the contract addresses in your `.env` file are correct
2. **Deployment fails**: Check that you have enough STRK tokens for gas fees
3. **Environment variables not loading**: Restart the development server with `--clear` flag

### Getting Help

If you encounter issues:
1. Check the Dojo documentation
2. Verify your Starknet wallet has sufficient funds
3. Ensure your private key is correct
4. Check the Starknet Sepolia network status
