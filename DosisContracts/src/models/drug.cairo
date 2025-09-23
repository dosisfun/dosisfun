
use starknet::ContractAddress;
use core::num::traits::zero::Zero;

#[derive(Copy, Drop, Serde, Debug, PartialEq)]
#[dojo::model]
pub struct Drug {
    #[key]
    pub id: u32,
    pub owner: ContractAddress,
    pub name: felt252,
    pub drug_type: felt252, 
    pub rarity: felt252,    
    pub state: felt252,     
    pub purity: u8, // 0-100
    pub quantity: u32,
    pub creation_timestamp: u64,
    pub recipe_id: u32,
}

#[derive(Copy, Drop, Serde, Debug, PartialEq)]
#[dojo::model]
pub struct DrugInventory {
    #[key]
    pub player: ContractAddress,
    pub drug_ids: Span<u32>,
    pub total_drugs: u32,
}

#[generate_trait]
pub impl DrugAssert of AssertTrait {
    #[inline(always)]
    fn assert_exists(self: Drug) {
        assert(self.id > 0, 'Drug: Does not exist');
    }

    #[inline(always)]
    fn assert_not_exists(self: Drug) {
        assert(self.id == 0, 'Drug: Already exists');
    }
}

pub impl ZeroableDrugTrait of Zero<Drug> {
    #[inline(always)]
    fn zero() -> Drug {
        Drug {
            id: 0,
            owner: 0.try_into().unwrap(),
            name: '',
            drug_type: 0, // Default to 0 (e.g., Stimulant)
            rarity: 0,    // Default to 0 (e.g., Common)
            state: 0,     // Default to 0 (e.g., Raw)
            purity: 0,
            quantity: 0,
            creation_timestamp: 0,
            recipe_id: 0,
        }
    }

    #[inline(always)]
    fn is_zero(self: @Drug) -> bool {
        *self.id == 0
    }

    #[inline(always)]
    fn is_non_zero(self: @Drug) -> bool {
        !self.is_zero()
    }
}

#[cfg(test)]
mod tests {
    use super::{Drug, ZeroableDrugTrait};
    use starknet::ContractAddress;

    #[test]
    fn test_drug_creation() {
        let owner: ContractAddress = 0x123.try_into().unwrap();
        
        let drug = Drug {
            id: 1,
            owner,
            name: 'cocaine_pure',
            drug_type: 0, // Stimulant
            rarity: 2, // Rare  
            state: 3, // Pure
            purity: 95,
            quantity: 5,
            creation_timestamp: 1234567890,
            recipe_id: 1,
        };

        assert_eq!(drug.id, 1, "Drug ID should be 1");
        assert_eq!(drug.owner, owner, "Owner should match");
        assert_eq!(drug.purity, 95, "Purity should be 95");
        assert_eq!(drug.quantity, 5, "Quantity should be 5");
    }

    #[test]
    fn test_drug_zero_initialization() {
        let zero_drug: Drug = ZeroableDrugTrait::zero();
        
        assert_eq!(zero_drug.id, 0, "Zero drug ID should be 0");
        assert_eq!(zero_drug.purity, 0, "Zero drug purity should be 0");
        assert_eq!(zero_drug.quantity, 0, "Zero drug quantity should be 0");
    }

    #[test]
    fn test_drug_inventory_creation() {
        let player: ContractAddress = 0x456.try_into().unwrap();
        let mut drug_ids = ArrayTrait::new();
        drug_ids.append(1);
        drug_ids.append(2);
        drug_ids.append(3);
        
        // Test that we can create the data structure
        let drug_ids_span = drug_ids.span();
        assert(drug_ids_span.len() == 3, 'Should have 3 drug IDs');
        assert(player.into() != 0, 'Player should not be zero');
    }
}
