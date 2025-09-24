#[derive(Copy, Drop, Serde, Debug, PartialEq, Introspect)]
pub enum DrugType {
    Stimulant,
    Depressant,
    Hallucinogen,
    Opioid,
    Cannabis,
    Synthetic,
}

#[derive(Copy, Drop, Serde, Debug, PartialEq, Introspect)]
pub enum DrugRarity {
    Common,
    Uncommon,
    Rare,
    Epic,
    Legendary,
}

#[derive(Copy, Drop, Serde, Debug, PartialEq, Introspect)]
pub enum DrugState {
    Raw,
    Processing,
    Refined,
    Pure,
    Masterpiece,
}

// Helper functions to convert between enums and felt252 for storage compatibility
pub mod DrugTypeHelper {
    use super::DrugType;
    
    pub fn to_felt252(drug_type: DrugType) -> felt252 {
        match drug_type {
            DrugType::Stimulant => 0,
            DrugType::Depressant => 1,
            DrugType::Hallucinogen => 2,
            DrugType::Opioid => 3,
            DrugType::Cannabis => 4,
            DrugType::Synthetic => 5,
        }
    }
    
    pub fn from_felt252(value: felt252) -> DrugType {
        if value == 0 { DrugType::Stimulant }
        else if value == 1 { DrugType::Depressant }
        else if value == 2 { DrugType::Hallucinogen }
        else if value == 3 { DrugType::Opioid }
        else if value == 4 { DrugType::Cannabis }
        else if value == 5 { DrugType::Synthetic }
        else { DrugType::Stimulant } // Default fallback
    }
}

pub mod DrugRarityHelper {
    use super::DrugRarity;
    
    pub fn to_felt252(rarity: DrugRarity) -> felt252 {
        match rarity {
            DrugRarity::Common => 0,
            DrugRarity::Uncommon => 1,
            DrugRarity::Rare => 2,
            DrugRarity::Epic => 3,
            DrugRarity::Legendary => 4,
        }
    }
    
    pub fn from_felt252(value: felt252) -> DrugRarity {
        if value == 0 { DrugRarity::Common }
        else if value == 1 { DrugRarity::Uncommon }
        else if value == 2 { DrugRarity::Rare }
        else if value == 3 { DrugRarity::Epic }
        else if value == 4 { DrugRarity::Legendary }
        else { DrugRarity::Common } // Default fallback
    }
}

pub mod DrugStateHelper {
    use super::DrugState;
    
    pub fn to_felt252(state: DrugState) -> felt252 {
        match state {
            DrugState::Raw => 0,
            DrugState::Processing => 1,
            DrugState::Refined => 2,
            DrugState::Pure => 3,
            DrugState::Masterpiece => 4,
        }
    }
    
    pub fn from_felt252(value: felt252) -> DrugState {
        if value == 0 { DrugState::Raw }
        else if value == 1 { DrugState::Processing }
        else if value == 2 { DrugState::Refined }
        else if value == 3 { DrugState::Pure }
        else if value == 4 { DrugState::Masterpiece }
        else { DrugState::Raw } // Default fallback
    }
}

#[cfg(test)]
mod tests {
    use super::{DrugType, DrugRarity, DrugState};

    #[test]
    fn test_drug_type_creation() {
        let stimulant = DrugType::Stimulant;
        let depressant = DrugType::Depressant;
        let hallucinogen = DrugType::Hallucinogen;
        
        assert!(stimulant != depressant, "Different drug types should not be equal");
        assert!(depressant != hallucinogen, "Different drug types should not be equal");
    }

    #[test]
    fn test_drug_rarity_creation() {
        let common = DrugRarity::Common;
        let legendary = DrugRarity::Legendary;
        
        assert!(common != legendary, "Different rarities should not be equal");
    }

    #[test]
    fn test_drug_state_creation() {
        let raw = DrugState::Raw;
        let masterpiece = DrugState::Masterpiece;
        
        assert!(raw != masterpiece, "Different states should not be equal");
    }
}
