use dosis_game::models::drug::{DrugAssert, ZeroableDrugTrait};

#[cfg(test)]
mod tests {
    use super::{DrugAssert, ZeroableDrugTrait};
    use dosis_game::models::drug::DrugInventory;

    #[test]
    #[available_gas(20000000)]
    fn test_drug_creation() {
        let mut drug = ZeroableDrugTrait::zero();
        drug.id = 1;
        drug.name = 'Cocaine';
        drug.drug_type = 0; // Stimulant
        drug.rarity = 2; // Rare
        drug.state = 2; // Refined
        drug.purity = 85;
        drug.quantity = 1;
        drug.creation_timestamp = 1000;
        drug.recipe_id = 1;

        assert(drug.id == 1, 'Drug ID should be 1');
        assert(drug.name == 'Cocaine', 'Drug name should be Cocaine');
        assert(drug.drug_type == 0, 'Drug type should be Stimulant');
        assert(drug.rarity == 2, 'Drug rarity should be Rare');
        assert(drug.state == 2, 'Drug state should be Refined');
        assert(drug.purity == 85, 'Drug purity should be 85');
        assert(drug.quantity == 1, 'Drug quantity should be 1');
        assert(drug.recipe_id == 1, 'Recipe ID should be 1');
    }

    #[test]
    #[available_gas(20000000)]
    fn test_drug_zero_address() {
        let drug = ZeroableDrugTrait::zero();
        assert(drug.owner == 0.try_into().unwrap(), 'Owner should be zero address');
    }

    #[test]
    #[available_gas(20000000)]
    fn test_drug_assert_exists() {
        let mut drug = ZeroableDrugTrait::zero();
        drug.id = 1;
        
        // This should not panic
        drug.assert_exists();
    }

    #[test]
    #[available_gas(20000000)]
    fn test_drug_inventory_creation() {
        let mut drug_ids = ArrayTrait::new();
        drug_ids.append(1);
        drug_ids.append(2);
        drug_ids.append(3);
        
        let inventory = DrugInventory {
            player: 0.try_into().unwrap(),
            drug_ids: drug_ids.span(),
            total_drugs: 3,
        };

        let drugs: Span<u32> = inventory.drug_ids;
        assert(drugs.len() == 3, 'Inventory should have 3 drugs');
        assert(inventory.total_drugs == 3, 'Total drugs should be 3');
    }

    #[test]
    #[available_gas(20000000)]
    fn test_drug_felt252_values() {
        let mut drug = ZeroableDrugTrait::zero();
        
        // Test felt252 values for drug types and states
        drug.drug_type = 0; // Stimulant
        drug.rarity = 0; // Common  
        drug.state = 0; // Raw
        
        assert(drug.drug_type == 0, 'Stimulant should be 0');
        assert(drug.rarity == 0, 'Common should be 0');
        assert(drug.state == 0, 'Raw should be 0');
        
        drug.drug_type = 5; // Synthetic
        drug.rarity = 4; // Legendary
        drug.state = 4; // Masterpiece
        
        assert(drug.drug_type == 5, 'Synthetic should be 5');
        assert(drug.rarity == 4, 'Legendary should be 4');
        assert(drug.state == 4, 'Masterpiece should be 4');
    }
}
