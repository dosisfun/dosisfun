# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

DOSIS.FUN is a blockchain-based underground survival RPG game with three main components:
- **DosisContracts**: Dojo-based game logic smart contracts (Cairo)
- **dosisnft**: NFT contracts for player items (Cairo/Starknet)
- **Dosis**: Mobile application (React Native/Expo)
- **dosisfun-web**: Marketing/landing website (Next.js)

This is a monorepo with separate package managers for each component.

## Repository Structure

```
dosis/
├── dosisfun/                    # Main game mono-repo (has git)
│   ├── DosisContracts/          # Dojo game contracts (Cairo)
│   ├── dosisnft/                # NFT contracts (Cairo/Starknet)
│   └── Dosis/                   # Mobile app (Expo/React Native)
└── dosisfun-web/                # Marketing website (Next.js)
```

## Development Commands

### DosisContracts (Dojo Game Contracts)
**Directory:** `dosisfun/DosisContracts/`

```bash
# Build contracts
sozo build

# Run tests
sozo test

# Deploy to local Katana
sozo migrate --profile dev

# Deploy to Sepolia testnet
sozo migrate --profile sepolia

# Deploy to mainnet
sozo migrate --profile mainnet

# Start local Starknet node (separate terminal)
katana --disable-fee

# Start Torii indexer (requires world contract address)
torii --world <CONTRACT_ADDRESS> --rpc-url http://localhost:5050
```

### dosisnft (NFT Contracts)
**Directory:** `dosisfun/dosisnft/`

```bash
# Run tests
snforge test

# Build contracts
scarb build

# Declare contract (Sepolia example - see README.md for full commands)
sncast --account <ACCOUNT> declare --url <RPC_URL> --contract-name MyToken

# Deploy contract
sncast --account <ACCOUNT> deploy --url <RPC_URL> --class-hash <HASH> --arguments <ARGS>
```

### Dosis Mobile App (Expo/React Native)
**Directory:** `dosisfun/Dosis/`

```bash
# Install dependencies
npm install

# Start development server
npm start

# Run on Android
npm run android

# Run on iOS
npm run ios

# Run on web
npm run web

# Lint code
npm run lint
```

### dosisfun-web (Next.js Website)
**Directory:** `dosisfun-web/`

```bash
# Install dependencies
npm install

# Start development server (with Turbopack)
npm run dev

# Build for production
npm run build

# Start production server
npm start

# Lint code
npm run lint
```

## Architecture

### DosisContracts (Dojo ECS Architecture)

Uses Entity-Component-System pattern with Dojo Engine v1.7.0-alpha.4:

**Models (ECS Components):**
- `Player`: Player stats, level, experience, reputation
- `Drug`: Drug items with type, rarity, purity, quantity
- `DrugInventory`: Player's drug collection
- `Recipe`: Crafting recipes with ingredients and difficulty

**Systems (ECS Systems):**
- `player_token.cairo`: Player spawning and stats
- `drug_crafting.cairo`: Core crafting mechanics (`craft_drug`)
- `recipe_system.cairo`: Recipe management (`create_recipe`, `get_recipe`, `initialize_default_recipes`)
- `minter.cairo`: NFT minting system

**Key Types:**
- DrugType: Stimulant, Depressant, Hallucinogen, Opioid, Cannabis, Synthetic
- DrugRarity: Common, Uncommon, Rare, Epic, Legendary
- DrugState: Raw, Processing, Refined, Pure, Masterpiece
- CraftingResult: CriticalFailure, Failure, Success, CriticalSuccess

**Game Mechanics:**
- Experience system with exponential leveling (max level 255)
- Crafting with success/failure based on recipe difficulty and player level
- Pseudo-random number generation using block data
- Reputation system tied to successful crafts

### dosisnft (NFT Contracts)

Starknet NFT implementation using OpenZeppelin 2.0.0 and Graffiti for on-chain rendering.

**Key files:**
- `src/token.cairo`: Main NFT contract (MyToken) with ERC721, access control, pausable, and upgradeable features
- `src/models.cairo`: NFT data models including CharacterStats and Drug structures
- `src/formater.cairo`: SVG formatting for on-chain graphics

**CharacterStats Model:**
- `owner`: ContractAddress
- `character_name`: ByteArray
- `cash`: u256 currency amount
- `level`: u8 (1-255)
- `experience`: u16 experience points
- `reputation`: u16 (0-1000)
- `total_drugs_created`: u32
- `successful_crafts`: u32
- `failed_crafts`: u32
- `creation_timestamp`: u64
- `last_active_timestamp`: u64
- `is_minted`: bool
- `is_active`: bool

**Access Control:**
- `DEFAULT_ADMIN_ROLE`: Full admin privileges
- `DOSIS_CONTRACT_ROLE`: Dosis contract permissions
- `MINT_ROLE`: Minting permissions

**Features:**
- Upgradeable contract pattern
- Pausable functionality for emergency stops
- Role-based access control
- Mint price and treasury management
- On-chain SVG metadata generation

### Dosis Mobile App

Expo/React Native app using:
- `@cavos/aegis` for Starknet wallet integration (configured for SN_SEPOLIA)
- Expo Router for navigation
- Expo Secure Store for sensitive data storage

**Navigation structure:**
- `/` (index): Main game screen
- `/wallet`: Wallet management
- `/nft-validation`: NFT verification flow
- `/onboarding/intro-complete`: Post-onboarding screen

**Key utilities:**
- `utils/secureStorage.ts`: Secure key/wallet storage
- `utils/utils.ts`: General utilities

**Wallet Configuration:**
- Network: SN_SEPOLIA (Starknet Sepolia testnet)
- App Name: 'dosisfun'
- Integrated paymaster for gasless transactions

### dosisfun-web (Next.js Website)

Marketing website with:
- Next.js 15 with Turbopack
- Tailwind CSS v4
- Theme provider for light/dark mode
- React 19

**Pages:**
- `/`: Landing page
- `/mint`: NFT minting page
- `/black-market`: Black market feature page

## Important Notes

- **DosisContracts** depends on **dosisnft** via local path dependency (`dosis_nft = { path = "../dosis_nft" }`)
- Cairo version varies: DosisContracts uses 2.12.2, dosisnft also uses 2.12.2
- Dojo version: v1.7.0-alpha.4 (alpha release)
- Mobile app is configured for landscape orientation only
- Starknet network: Currently using Sepolia testnet (SN_SEPOLIA)
- All three main components use TypeScript/Cairo with strict typing

## Prerequisites

**For DosisContracts:**
- Rust (latest stable)
- Cairo 2.12.2
- Dojo v1.7.0-alpha.4
- Install: `curl -L https://install.dojoengine.org | bash && dojoup install`

**For dosisnft:**
- Scarb (Cairo package manager)
- Starknet Foundry (snforge/sncast)

**For Dosis mobile app:**
- Node.js
- Expo CLI
- iOS/Android development environment

**For dosisfun-web:**
- Node.js
- npm/yarn/pnpm
