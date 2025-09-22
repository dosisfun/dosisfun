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
