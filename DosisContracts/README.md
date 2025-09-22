# Dosis Game - Smart Contract Architecture

## 📁 Directory Structure

```
src/
├── lib.cairo                 # Main contract entry point
├── constants.cairo           # Game configuration constants
├── store.cairo              # Data access layer (Dojo World interface)
├── models/                  
│   ├── player.cairo         # Player data structure
│   ├── drug.cairo           # Drug and inventory models
│   └── recipe.cairo         # Recipe data structure
├── systems/                 
│   ├── player.cairo         # Player management system
│   ├── drug_crafting.cairo  # Core crafting mechanics
│   └── recipe_system.cairo  # Recipe management system
├── types/                   
│   ├── drug_type.cairo      # Drug enums and types
│   └── recipe.cairo         # Recipe-related types
├── helpers/                 
│   ├── experience_utils.cairo # XP calculation helpers
│   ├── pseudo_random.cairo  # Random number generation
│   └── timestamp.cairo      # Time utilities
├── utils/                   
│   └── string.cairo         # String manipulation
└── tests/                   
    ├── test_player.cairo    # Player model tests
    ├── test_drug.cairo      # Drug model tests
    ├── test_recipe.cairo    # Recipe model tests
    ├── test_drug_crafting.cairo # Crafting system tests
    └── test_recipe_system.cairo # Recipe system tests
```

## Core Components

### Models (ECS Components)

#### **Player Model** (`models/player.cairo`)
```cairo
struct Player {
    address: ContractAddress,     # Player's wallet address
    level: u8,                   # Current level (1-255)
    experience: u16,             # Current XP points
    total_drugs_created: u32,    # Lifetime drugs crafted
    successful_crafts: u32,      # Successful crafting attempts
    failed_crafts: u32,          # Failed crafting attempts
    last_active_timestamp: u64,  # Last activity time
    creation_timestamp: u64,     # Account creation time
    reputation: u16              # Player reputation score
}
```

#### **Drug Model** (`models/drug.cairo`)
```cairo
struct Drug {
    id: u32,                    # Unique drug ID
    owner: ContractAddress,     # Owner's address
    name: felt252,              # Drug name
    drug_type: DrugType,        # Type (Stimulant, Depressant, etc.)
    rarity: DrugRarity,         # Rarity level
    purity: u8,                 # Purity percentage (0-100)
    quantity: u32,              # Amount created
    state: DrugState,           # Processing state
    creation_timestamp: u64,    # Creation time
    recipe_id: u32              # Source recipe ID
}

struct DrugInventory {
    player: ContractAddress,    # Player address
    drug_ids: Span<u32>,       # Array of drug IDs
    total_drugs: u32           # Total drugs owned
}
```

#### **Recipe Model** (`models/recipe.cairo`)
```cairo
struct Recipe {
    id: u32,                    # Unique recipe ID
    name: felt252,              # Recipe name
    drug_type: DrugType,        # Resulting drug type
    rarity: DrugRarity,         # Resulting drug rarity
    ingredients: Span<Ingredient>, # Required ingredients
    difficulty: u8,             # Crafting difficulty (1-10)
    base_experience: u16,       # Base XP reward
    success_rate: u8,           # Success percentage (5-95)
    is_active: bool,            # Recipe availability
    created_by: felt252,        # Creator address
    created_timestamp: u64      # Creation time
}
```

### Systems (ECS Systems)

#### **Player System** (`systems/player.cairo`)
- `spawn_player()` - Create new player account
- `get_player_stats()` - Retrieve player statistics
- Manages player progression and leveling

#### **Drug Crafting System** (`systems/drug_crafting.cairo`)
- `craft_drug(recipe_id: u32)` - Main crafting function
- Simulates crafting process with success/failure
- Awards experience points based on results
- Updates player statistics and reputation
- Manages drug inventory

#### **Recipe System** (`systems/recipe_system.cairo`)
- `create_recipe()` - Add new recipes to the world
- `get_recipe(recipe_id: u32)` - Retrieve specific recipe
- `get_all_recipes()` - Get all available recipes
- `set_recipe_active()` - Enable/disable recipes
- `initialize_default_recipes()` - Setup default recipes

### Types & Enums

#### **Drug Types** (`types/drug_type.cairo`)
```cairo
enum DrugType {
    Stimulant,      # Cocaine, Amphetamines
    Depressant,     # Heroin, Barbiturates
    Hallucinogen,   # LSD, Mushrooms
    Opioid,         # Morphine, Fentanyl
    Cannabis,       # Marijuana, Hash
    Synthetic       # MDMA, Synthetic drugs
}

enum DrugRarity {
    Common,         # Basic drugs
    Uncommon,       # Improved quality
    Rare,           # High-quality drugs
    Epic,           # Exceptional drugs
    Legendary       # Masterpiece drugs
}

enum DrugState {
    Raw,            # Initial state
    Processing,     # Being refined
    Refined,        # Processed
    Pure,           # High purity
    Masterpiece     # Perfect quality
}
```

#### **Recipe Types** (`types/recipe.cairo`)
```cairo
struct Ingredient {
    name: felt252,   # Ingredient name
    quantity: u32,   # Required amount
    purity: u8       # Required purity
}

enum CraftingResult {
    CriticalFailure, # Complete failure
    Failure,         # Failed attempt
    Success,         # Successful craft
    CriticalSuccess  # Perfect result
}
```

## Game Mechanics

### **Experience System**
- Players gain XP from successful drug crafting
- XP requirements increase exponentially per level
- Level ups provide reputation bonuses
- Maximum level: 255

### **Crafting System**
- Success rate based on recipe difficulty and player level
- Higher level players have better success rates
- Critical success/failure possibilities
- Purity affects final drug quality

### **Reputation System**
- Gained through successful crafting
- Higher rarity drugs provide more reputation
- Level ups provide reputation bonuses
- Affects player standing in the game

### **Randomness**
- Pseudo-random number generation using block data
- Deterministic but unpredictable results
- Fair distribution across all players

## Configuration

### **Constants** (`constants.cairo`)
- `BASE_LEVEL_EXPERIENCE = 100` - Base XP per level
- `LEVEL_EXPERIENCE_MULTIPLIER = 150` - XP scaling factor
- `MAX_PLAYER_LEVEL = 255` - Maximum player level
- `BASE_CRAFTING_EXPERIENCE = 25` - Base crafting XP
- `BASE_SUCCESS_RATE = 50` - Default success rate
- `MAX_SUCCESS_RATE = 95` - Maximum success rate
- `MIN_SUCCESS_RATE = 5` - Minimum success rate

### Running Tests
```bash
sozo test
```

## Deployment

### Prerequisites
- Cairo 2.10.1
- Dojo Engine v1.6.1
- Starknet network access

### Build
```bash
sozo build
```

### Deploy
```bash
sozo migrate --profile sepolia
```

## Technical Stack

- **Framework**: Dojo Engine v1.6.1
- **Language**: Cairo 2.10.1
- **Network**: Starknet
- **Architecture**: Entity-Component-System (ECS)
- **Testing**: Cairo Test Framework

---
